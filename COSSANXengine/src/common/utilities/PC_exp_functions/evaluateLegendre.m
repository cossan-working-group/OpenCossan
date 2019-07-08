function Mpsi = evaluateLegendre(Mxi,Norder)
%evaluateLegendre   Evaluate the Polynomial Chaos basis vectors Psi (Legendre)
%   MPSI = evaluateLegendre(Mxi,Norder) returns a row vector 
%   with the evaluated P-C basis vectors PSI;
%   Mxi is a row vector of independent uniform RVs;
%   Norder is the order of the PC;
%   (the dimensionality of the Chaos is determined automatically
%   by the number of independent xi's, i.e. by the number of columns)
%
%   For matrices xi, each row is considered a realization.
%   Hence evaluateLegendre(Mxi,Norder) returns a matrix, where each row
%   contains the PC-evaluation for that realization.
%
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================

%% Initialize

[Nsamples Nrvs] = size(Mxi);

%Get index sequences
[Malpha,nalpha] = getindex_incl(Nrvs,Norder);

%Initialize psi
Mpsi=ones(Nsamples,nalpha);

%% Evaluate the Legendre polynomials

CLegendre = cell(Nrvs,1);
for k=1:Nrvs
    CLegendre{k} = legendrePolynomials(Mxi(:,k),Norder);
end

%% Evaluate the PC expression

for i=1:nalpha
    for k=1:Nrvs
        Mpsi(:,i) = Mpsi(:,i).*CLegendre{k}(:,Malpha(i,k)+1);
    end
end
