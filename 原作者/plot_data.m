function plot_data( M,D,Pareto)
% This function to plot Pareto solution
pl_data= Pareto(:,D+1:D+M); % extract data to plot
pl_data(:,3)=-pl_data(:,3);
pl_data=sortrows(pl_data,3);
X=pl_data(:,1);
Y=pl_data(:,2);
Z=pl_data(:,3);
n=length(Z);
c=linspace(65,100,n);
figure;
scatter3(X, Y, Z,30,c,'o', 'filled');
view(-30, 20);
% Add title and axis labels
title('Optimal Solution Pareto Set');
xlabel('Objective function value 1');
ylabel('Objective function value 2');
zlabel('Objective function value 3');
% Add a colorbar with tick labels
colorbar('location', 'EastOutside', 'XTickLabel',...
    {'65 %', '70 %', '75 %', '80 %', ...
     '85 %', '90 %', '100 %'});
end

