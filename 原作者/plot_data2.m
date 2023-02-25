function plot_data2(M,D,Pareto)
% This function to plot Pareto solution
% symbol = ['o','s','^','v','<','>','d','p'];
% colors = ['b','g','r','c','m','y','k','b'];
pl_data= Pareto(:,D+1:D+M); % extract data to plot
pl_data=sortrows(pl_data,2);
X=pl_data(:,1);
Y=pl_data(:,2);
figure;
scatter(X, Y,'*','k');
% Add title and axis labels
title('Optimal Solution Pareto Set');
xlabel('Objective function value 1');
ylabel('Objective function value 2');
grid;
% Add a colorbar with tick labels
end

