% =========================================================================
%
%   Rosenbrock Function in 10 Dimensions
%   
%   References:
%   (1) Wikipedia, http://en.wikipedia.org/wiki/Rosenbrock_function, for a
%   quick overview
%   
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2007 IfM
% =========================================================================

function out = Rosenbrock(x)

out   = sum( (1-x(:,1:end-1)).^2 , 2) + sum( 100*(x(:,2:end)-x(:,1:end-1).^2).^2 , 2);

return