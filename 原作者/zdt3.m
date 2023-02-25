%% Zitzler1 function (ZDT3)
function f = zdt3 (x)
% Number of objective is 2.
% Number of variables is 30. Range x [0,1]
f = [];
n=length(x);
g=1+9*sum(x(2:n))/(n-1);
f(1)=x(1);
f(2)=1-sqrt(x(1)/g)-(x(1)/g)*sin(10*pi*x(1));