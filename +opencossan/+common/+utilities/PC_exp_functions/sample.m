function Mrealizations = sample(Sbasis,Mpccoefficients,Norder,Mxi)
%PCREALIZEHERMITE   create realizations of random variable/process
%   Mrealizations = PCrealizeHermite(Mpccoefficients,Norder,Mxi) returns the realizations of u
%   corresponding to the Gaussian vectors XI;
%   Mpccoefficients must contain the PC coefficients columnwise, each column c.t. a
%   different variate;
%   Norder denotes the order of the expansion
%   XI contains the Gaussian realizations; the number of columns in
%   determines the dimensionality of the PC given by Mpccoefficients
%
%   Note: the sequence in which the PC-coefs are stored in Mpccoefficients must
%   correspond to the one used by the routine PCEVALUATEHERMITE.
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================

%% Check if input is consistent

[Npccoefficients Nresponses] = size(Mpccoefficients); 
[Nsamples Nrvs]              = size(Mxi);

if Npccoefficients ~= pcnumber(Nrvs,Norder)
    error('COSSAN:P-C: Please make sure that the no of P-C Coefficients is consistent with the dimension and order')
end

%% Initialize

Mpsi          = zeros(Nsamples,Npccoefficients);  %#ok<*NASGU>
Mrealizations = zeros(Nsamples,Nresponses);

%% Evaluate the realizations of the P-C expression for the Mxi input

if strcmp(Sbasis,'Hermite')
    Mpsi = evaluateHermite(Mxi,Norder);
elseif strcmp(Sbasis,'Legendre')
    Mpsi = evaluateLegendre(Mxi,Norder);
end
Mrealizations  = Mpsi*Mpccoefficients;

