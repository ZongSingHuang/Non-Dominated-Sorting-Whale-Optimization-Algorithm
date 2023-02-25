%% Non Sorted Whale Optimization Algorithm (NSWOA)
% NSWOA is developed by Pradeep Jangir
%% Objective Function
% The objective function description contains information about the
% objective function. M is the dimension of the objective space, D is the
% dimension of decision variable space, LB and UB are the
% range for the variables in the decision variable space. User has to
% define the objective functions using the decision variables. Make sure to
% edit the function 'evaluate_objective' to suit your needs.
clc
clear all
D = 5; % Number of decision variables
M = 2; % Number of objective functions
K=M+D;
LB = ones(1, D).*0; %  LB - A vector of decimal values which indicate the minimum value for each decision variable.
UB = ones(1, D).*1; % UB - Vector of maximum possible values for decision variables.
Max_iteration = 100;  % Set the maximum number of generation (GEN)
SearchAgents_no = 100;      % Set the population size (Search Agent)
ishow = 10;
%% Initialize the population
% Population is initialized with random values which are within the
% specified range. Each chromosome consists of the decision variables. Also
% the value of the objective functions, rank and crowding distance
% information is also added to the chromosome vector but only the elements
% of the vector which has the decision variables are operated upon to
% perform the genetic operations like corssover and mutation.
chromosome = initialize_variables(SearchAgents_no, M, D, LB, UB);

%% Sort the initialized population
% Sort the population using non-domination-sort. This returns two columns
% for each individual which are the rank and the crowding distance
% corresponding to their position in the front they belong. At this stage
% the rank and the crowding distance for each chromosome is added to the
% chromosome vector for easy of computation.
intermediate_chromosome = non_domination_sort_mod(chromosome, M, D);

%% Perform Selection
% Once the intermediate population is sorted only the best solution is
% selected based on it rank and crowding distance. Each front is filled in
% ascending order until the addition of population size is reached. The
% last front is included in the population based on the individuals with
% least crowding distance
% Select NP fittest solutions using non dominated and crowding distance
% sorting and store in population
Population = replace_chromosome(intermediate_chromosome, M,D,SearchAgents_no);
%% Start the evolution process
% The following are performed in each generation
% * Select the parents which are fit for reproduction
% * Perfrom crossover and Mutation operator on the selected parents
% * Perform Selection from the parents and the offsprings
% * Replace the unfit individuals with the fit individuals to maintain a
%   constant population size.
Pareto = NSWOA(D,M,LB,UB,Population,SearchAgents_no,Max_iteration,ishow);
save Pareto.txt Pareto -ascii;  % save data for future use
%% Plot data
if M == 2
    plot_data2(M,D,Pareto)
elseif M == 3
    plot_data_TCQ(M,D,Pareto); 
end