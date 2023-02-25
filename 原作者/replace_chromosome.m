%% Cited from NSGA-II All rights reserved.
function f  = replace_chromosome(intermediate_chromosome, M,D,NP)

%% function f  = replace_chromosome(intermediate_chromosome,M,D,NP)
% This function replaces the chromosomes based on rank and crowding
% distance. Initially until the population size is reached each front is
% added one by one until addition of a complete front which results in
% exceeding the population size. At this point the chromosomes in that
% front is added subsequently to the population based on crowding distance.

[~,m]=size(intermediate_chromosome);
f=zeros(NP,m);

% Now sort the individuals based on the index
sorted_chromosome = sortrows(intermediate_chromosome,M + D + 1);

% Find the maximum rank in the current population
max_rank = max(intermediate_chromosome(:,M + D + 1));

% Start adding each front based on rank and crowing distance until the
% whole population is filled.
previous_index = 0;
for i = 1 : max_rank
    % Get the index for current rank i.e the last the last element in the
    % sorted_chromosome with rank i. 
    current_index = find(sorted_chromosome(:,M + D + 1) == i, 1, 'last' );
    % Check to see if the population is filled if all the individuals with
    % rank i is added to the population. 
    if current_index > NP
        % If so then find the number of individuals with in with current
        % rank i.
        remaining = NP - previous_index;
        % Get information about the individuals in the current rank i.
        temp_pop = ...
            sorted_chromosome(previous_index + 1 : current_index, :);
        % Sort the individuals with rank i in the descending order based on
        % the crowding distance.
        [~,temp_sort_index] = ...
            sort(temp_pop(:, M + D + 2),'descend');
        % Start filling individuals into the population in descending order
        % until the population is filled.
        for j = 1 : remaining
            f(previous_index + j,:) = temp_pop(temp_sort_index(j),:);
        end
        return;
    elseif current_index < NP
        % Add all the individuals with rank i into the population.
        f(previous_index + 1 : current_index, :) = ...
            sorted_chromosome(previous_index + 1 : current_index, :);
    else
        % Add all the individuals with rank i into the population.
        f(previous_index + 1 : current_index, :) = ...
            sorted_chromosome(previous_index + 1 : current_index, :);
        return;
    end % end if current_index
    % Get the index for the last added individual.
    previous_index = current_index;
end
