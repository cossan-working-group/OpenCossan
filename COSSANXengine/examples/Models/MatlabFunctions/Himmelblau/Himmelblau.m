% =========================================================================
%
%   Second Milestone Meeting - Quality Assurance
%
%   Optimization of Himmelblau Function using 
%   Simulated Annealing
%   
%   References:
%   (1) http://decsai.ugr.es/WSC7/presentations/presentation-55/node15.html
%   
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2007 IfM
% =========================================================================

function out=Himmelblau(x)
	out = (x(:,1).^2 + x(:,2) - 11).^2 + (x(:,1) + x(:,2).^2 -7).^2;
end
