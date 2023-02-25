%% Cited from NSGA-II All rights reserved.
function f = initialize_variables(NP, M, D, LB, UB)

%% function f = initialize_variables(N, M, D, LB, UB) 
% This function initializes the population. Each individual has the
% following at this stage
%       * set of decision variables
%       * objective function values
% 
% where,
% NP - Population size
% M - Number of objective functions
% D - Number of decision variables
% min_range - A vector of decimal values which indicate the minimum value
% for each decision variable.
% max_range - Vector of maximum possible values for decision variables.

min = LB;
max = UB;

% K is the total number of array elements. For ease of computation decision
% variables and objective functions are concatenated to form a single
% array. For crossover and mutation only the decision variables are used
% while for selection, only the objective variable are utilized.


K = M + D;
f=zeros(NP,K);

%% Initialize each individual in population
% For each chromosome perform the following (N is the population size)
for i = 1 : NP
    % Initialize the decision variables based on the minimum and maximum
    % possible values. V is the number of decision variable. A random
    % number is picked between the minimum and maximum possible values for
    % the each decision variable.
    for j = 1 : D
        f(i,j) = min(j) + (max(j) - min(j))*rand(1);
    end % end for j
    % For ease of computation and handling data the chromosome also has the
    % vlaue of the objective function concatenated at the end. The elements
    % D + 1 to K has the objective function valued. 
    % The function evaluate_objective takes one individual at a time,
    % infact only the decision variables are passed to the function along
    % with information about the number of objective functions which are
    % processed and returns the value for the objective functions. These
    % values are now stored at the end of the individual itself.
    f(i,D + 1: K) = evaluate_objective(f(i,1:D));
end % end for i