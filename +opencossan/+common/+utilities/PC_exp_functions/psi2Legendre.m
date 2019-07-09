function Vpsi2 = psi2Legendre(Nrvs,Norder)
%psi2Legendre   evaluates <Psi_i^2>
%   psi2Legendre (M,p) returns the vector of coefficients <Psi_i^2>, for a PC basis
%   constructed with Legendre Polynomials (dimension M and order p)
%
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================

%% Calculate the Legendre Polynomials

% Currently DMCS with 2,000,000 samples is employed for calculation
Nsamples   = 2000000;
% Obtain the germs with uniform distribution (-1,1)
Vxi        = -1 + (1-(-1)).*rand(Nsamples,Nrvs);
% Calculate the polynomials
Mlegendre  = evaluateLegendre(Vxi,Norder); 

%% Calculate the Vpsii^2 terms

Vpsi2 = mean(Mlegendre.^2);
