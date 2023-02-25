function f = NSWOA(D,M,LB,UB,Pop,SearchAgents_no,Max_iteration,ishow)
%% Non Sorted Whale Optimization Algorithm (NSWOA)
% NSWOA is developed by Pradeep Jangir
% f - optimal fitness
% X - optimal solution
% D  Dimensional of problem at hand   
% M Number of objective function
% population is a matrix consists of all individuals
% SearchAgents_no is number of individual in populationsystem
% LB lower boundary constraint
% UB upper boundary constraint
%% Algorithm Variables
K = D+M;
population = Pop(:,1:K+1); % 父代
offspring = zeros(SearchAgents_no,K); % 子代
%% Optimization Circle
Iteration = 1;
while Iteration<=Max_iteration % 迭代至 Max_iteration   
    for i = 1:SearchAgents_no %  掃遍所有父代的鯨魚
        % 從第一前緣解中隨機挑一條鯨魚 whale_best
        best_front = population((find(population(:,K+1)==1)),:);
        ri =  floor(size(best_front,1)*rand())+1;
        whale_best = population(ri,1:D);

        % 新鯨魚 = 父代[i] + rand(D) × (whale_best - SF × 父代[i])
        SF=round(1+rand); % SF 不是 1 就是 2
        whale_new = population(i,1:D)+rand(1,D).*(whale_best-SF.*population(i,1:D));

        % 新鯨魚的邊界處理
        whale_new = bound(whale_new(:,1:D),UB,LB); 

        % 新鯨魚的適應值計算 
        whale_new(:,D + 1: K) = evaluate_objective(whale_new(:,1:D));

        % 支配判定
        all_condition = all(whale_new(:,D+1:D+M)<=population(i,D+1:D+M));
        any_condition = any(whale_new(:,D+1:D+M)<population(i,D+1:D+M));
        % 若新鯨魚比父代[i]還要好
        if all_condition == 1 && any_condition == 1
            offspring(i,1:K) = population(i,1:K); % 父代[i]放入子代[i]
            population(i,1:K) = whale_new(:,1:K); % 新鯨魚放入父代[i]
        % 否則
        else
            offspring(i,1:K)= whale_new; % 新鯨魚放入子代[i]
        end

        % 從父代隨機挑選一隻鯨魚 whale_rand，該鯨魚不可以是父代[i]
        j = floor(rand()* SearchAgents_no) + 1;
        while j==i
            j = floor(rand()* SearchAgents_no) + 1;
        end
        whale_rand = population(j, :);

        % 生成新鯨魚(參照 Seyedali Mirjalili 的 WOA)
        % 係數
        a=2-Iteration*((2)/Max_iteration ); % a decreases linearly fron 2 to 0 in Eq. (2.3)
        a2=-1+Iteration*((-1)/Max_iteration );
        r1=rand(); % r1 is a random number in [0,1]
        r2=rand(); % r2 is a random number in [0,1]       
        A=2*a*r1-a;  % Eq. (2.3) in the paper
        C=2*r2;      % Eq. (2.4) in the paper 
        b=1;               %  parameters in Eq. (2.5)
        t=(a2-1)*rand+1;   %  parameters in Eq. (2.5)
        p = rand();        % p in Eq. (2.6) 
        if p<0.5
            whale_new = population(i,1:D)+whale_best-A.*abs(C*whale_best-whale_rand(1:D));
        elseif p>=0.5  
            whale_new = population(i,1:D)+abs(whale_best-whale_rand(1:D))*exp(b.*t).*cos(t.*2*pi)+whale_best;
        end

        % 新鯨魚的邊界處理
        whale_new = bound(whale_new(:,1:D),UB,LB);

        % 新鯨魚的適應值計算
        whale_new(:,D + 1: K) = evaluate_objective(whale_new(:,1:D));

        % 支配判定
        all_condition = all(whale_new(:,D+1:D+M)<=population(i,D+1:D+M));
        any_condition = any(whale_new(:,D+1:D+M)<population(i,D+1:D+M));
        % 若新鯨魚比父代[i]還要好
        if all_condition == 1 && any_condition == 1
            offspring(i,1:K) = population(i,1:K); % 父代[i]放入子代[i]
            population(i,1:K) = whale_new(:,1:K); % 新鯨魚放入父代[i]
        % 否則
        else
            offspring(i,1:K)= whale_new;  % 新鯨魚放入子代[i]
        end

        % 從父代隨機挑選一隻鯨魚 whale_rand，該鯨魚不可以是父代[i]
        j = floor(rand()* SearchAgents_no) + 1;
        while j==i
            j = floor(rand()* SearchAgents_no) + 1;
        end
        whale_rand = population(j, :);

        % 突變策略
        % 令父代[i] 為 whale_mutate
        whale_mutate=population(i,1:D);
        % 生成一個由 1~D 組成的亂數數列 seed
        seed=randperm(D);
        % seed 只取前 ceil(rand*D) 個
        pick=seed(1:ceil(rand*D));
        % 對 whale_mutate 的特定維度進行突變
        whale_mutate(:,pick)=rand(1,length(pick)).*(UB(pick)-LB(pick))+LB(pick);

        % whale_mutate 的適應值計算
        whale_mutate(:,D + 1: K) = evaluate_objective(whale_mutate(:,1:D));

        % 支配判定
        all_condition = all(whale_mutate(:,D+1:D+M)<=whale_rand(D+1:D+M));
        any_condition = any(whale_mutate(:,D+1:D+M)<whale_rand(D+1:D+M));
        % 若 whale_mutate 比 whale_rand 還要好
        if all_condition == 1 && any_condition == 1
            offspring(j,1:K) = whale_rand(1:K); % whale_rand 放入子代[i]
            population(j,1:K) = whale_mutate(:,1:K); % whale_mutate 放入父代[i]
        % 否則
        else
            offspring(j,1:K)= whale_mutate;  % whale_mutate 放入子代[i]
        end
    end

    if rem(Iteration, ishow) == 0
        fprintf('Generation: %d\n', Iteration);        
    end
    
    % 父代與子代合併
    population_com = [population(:,1:K) ; offspring];

    % 快速非支配排序
    intermediate_population = non_domination_sort_mod(population_com, M, D);

    % 以菁英策略生成新父代
    Pop  = replace_chromosome(intermediate_population, M,D,SearchAgents_no);
    population=Pop(:,1:K+1);

    % 迭代 + 1
    Iteration = Iteration+1;
end 
f= population;

% Check the boundary limit
function a=bound(a,ub,lb)
a(a>ub)=ub(a>ub); a(a<lb)=lb(a<lb);