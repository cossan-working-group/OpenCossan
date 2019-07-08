%**************************************************************************
%
%   Rastrigin's Function
%
%   References:
%   (1) http://tracer.lcc.uma.es/problems/rastrigin/rastrigin.html#TZ89
%   (2) A. Törn and A. Zilinskas. "Global Optimization". Lecture Notes in 
%   Computer Science, Nº 350, Springer-Verlag, Berlin,1989.
%   (3) H. Mühlenbein, D. Schomisch and J. Born. "The Parallel Genetic 
%   Algorithm as Function Optimizer ". Parallel Computing, 17, 
%   pages 619-632,1991.
%
%**************************************************************************


function f = rastriginsfcn(x)

f   = 20 + x(:,1).^2 + x(:,2).^2 - 10*( cos(2*pi*x(:,1)) + cos(2*pi*x(:,2)) );



return