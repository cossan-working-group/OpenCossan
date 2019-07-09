function Vpsi2 = psi2Hermite(Nrvs,Norder)
%psi2Hermite   evaluates <Psi_i^2>
%   psi2Hermite(Nrvs,Norder) returns the vector of coefficients <Psi_i^2>, for a PC basis
%   with dimension Nrvs and order Norder.
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================

% Generate the index sequences for the multidimensional Hermite polynomials
[alpha nalpha] = getindex_incl(Nrvs,Norder);

% Evaluate cijk for i=1 (corresponds to psi_1 = 1, shorter evaluation)
Vpsi2 = prod(factorial(alpha),2);
