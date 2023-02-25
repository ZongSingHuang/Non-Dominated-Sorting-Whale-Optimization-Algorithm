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
population = Pop(:,1:K+1); % ���N
offspring = zeros(SearchAgents_no,K); % �l�N
%% Optimization Circle
Iteration = 1;
while Iteration<=Max_iteration % ���N�� Max_iteration   
    for i = 1:SearchAgents_no %  ���M�Ҧ����N���H��
        % �q�Ĥ@�e�t�Ѥ��H���D�@���H�� whale_best
        best_front = population((find(population(:,K+1)==1)),:);
        ri =  floor(size(best_front,1)*rand())+1;
        whale_best = population(ri,1:D);

        % �s�H�� = ���N[i] + rand(D) �� (whale_best - SF �� ���N[i])
        SF=round(1+rand); % SF ���O 1 �N�O 2
        whale_new = population(i,1:D)+rand(1,D).*(whale_best-SF.*population(i,1:D));

        % �s�H������ɳB�z
        whale_new = bound(whale_new(:,1:D),UB,LB); 

        % �s�H�����A���ȭp�� 
        whale_new(:,D + 1: K) = evaluate_objective(whale_new(:,1:D));

        % ��t�P�w
        all_condition = all(whale_new(:,D+1:D+M)<=population(i,D+1:D+M));
        any_condition = any(whale_new(:,D+1:D+M)<population(i,D+1:D+M));
        % �Y�s�H������N[i]�٭n�n
        if all_condition == 1 && any_condition == 1
            offspring(i,1:K) = population(i,1:K); % ���N[i]��J�l�N[i]
            population(i,1:K) = whale_new(:,1:K); % �s�H����J���N[i]
        % �_�h
        else
            offspring(i,1:K)= whale_new; % �s�H����J�l�N[i]
        end

        % �q���N�H���D��@���H�� whale_rand�A���H�����i�H�O���N[i]
        j = floor(rand()* SearchAgents_no) + 1;
        while j==i
            j = floor(rand()* SearchAgents_no) + 1;
        end
        whale_rand = population(j, :);

        % �ͦ��s�H��(�ѷ� Seyedali Mirjalili �� WOA)
        % �Y��
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

        % �s�H������ɳB�z
        whale_new = bound(whale_new(:,1:D),UB,LB);

        % �s�H�����A���ȭp��
        whale_new(:,D + 1: K) = evaluate_objective(whale_new(:,1:D));

        % ��t�P�w
        all_condition = all(whale_new(:,D+1:D+M)<=population(i,D+1:D+M));
        any_condition = any(whale_new(:,D+1:D+M)<population(i,D+1:D+M));
        % �Y�s�H������N[i]�٭n�n
        if all_condition == 1 && any_condition == 1
            offspring(i,1:K) = population(i,1:K); % ���N[i]��J�l�N[i]
            population(i,1:K) = whale_new(:,1:K); % �s�H����J���N[i]
        % �_�h
        else
            offspring(i,1:K)= whale_new;  % �s�H����J�l�N[i]
        end

        % �q���N�H���D��@���H�� whale_rand�A���H�����i�H�O���N[i]
        j = floor(rand()* SearchAgents_no) + 1;
        while j==i
            j = floor(rand()* SearchAgents_no) + 1;
        end
        whale_rand = population(j, :);

        % ���ܵ���
        % �O���N[i] �� whale_mutate
        whale_mutate=population(i,1:D);
        % �ͦ��@�ӥ� 1~D �զ����üƼƦC seed
        seed=randperm(D);
        % seed �u���e ceil(rand*D) ��
        pick=seed(1:ceil(rand*D));
        % �� whale_mutate ���S�w���׶i�����
        whale_mutate(:,pick)=rand(1,length(pick)).*(UB(pick)-LB(pick))+LB(pick);

        % whale_mutate ���A���ȭp��
        whale_mutate(:,D + 1: K) = evaluate_objective(whale_mutate(:,1:D));

        % ��t�P�w
        all_condition = all(whale_mutate(:,D+1:D+M)<=whale_rand(D+1:D+M));
        any_condition = any(whale_mutate(:,D+1:D+M)<whale_rand(D+1:D+M));
        % �Y whale_mutate �� whale_rand �٭n�n
        if all_condition == 1 && any_condition == 1
            offspring(j,1:K) = whale_rand(1:K); % whale_rand ��J�l�N[i]
            population(j,1:K) = whale_mutate(:,1:K); % whale_mutate ��J���N[i]
        % �_�h
        else
            offspring(j,1:K)= whale_mutate;  % whale_mutate ��J�l�N[i]
        end
    end

    if rem(Iteration, ishow) == 0
        fprintf('Generation: %d\n', Iteration);        
    end
    
    % ���N�P�l�N�X��
    population_com = [population(:,1:K) ; offspring];

    % �ֳt�D��t�Ƨ�
    intermediate_population = non_domination_sort_mod(population_com, M, D);

    % �H�׭^�����ͦ��s���N
    Pop  = replace_chromosome(intermediate_population, M,D,SearchAgents_no);
    population=Pop(:,1:K+1);

    % ���N + 1
    Iteration = Iteration+1;
end 
f= population;

% Check the boundary limit
function a=bound(a,ub,lb)
a(a>ub)=ub(a>ub); a(a<lb)=lb(a<lb);