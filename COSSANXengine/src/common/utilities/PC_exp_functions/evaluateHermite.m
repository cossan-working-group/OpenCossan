function Mpsi = evaluateHermite(Mxi,Norder)
%evaluateHermite   Evaluate the Polynomial Chaos basis vectors Psi
%   MPSI = evaluateHermite (Mxi,Norder) returns a row vector 
%   with the evaluated P-C basis vectors PSI;
%   XI is a row vector of independent Gaussians;
%   Norder is the order of the PC;
%   (the dimensionality of the Chaos is determined automatically
%   by the number of independent XI's, i.e. by the number of columns)
%
%   For matrices XI, each row is considered a realization.
%   Hence evaluateHermite(XI,Norder) returns a matrix, where each row
%   contains the PC-evaluation for that realization.
%
%   NOTE: the sequence of the Chaos basis vectors forming PSI
%   is determined by the index sequences created by the routine
%   GETINDEX. To inspect this sequence, simply enter:
%   PSISYM = PCSYM(M,Norder), where M is the number of columns of XI,
%   and Q is the order of the PC; the cell array PSISYM then contains
%   the symbolic expressions for PSI, in terms of the Gaussians
%   xi1, xi2, ...
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

%% Evaluate the Hermite polynomials

CHermite = cell(Nrvs,1);
for k=1:Nrvs
    CHermite{k} = hermitePolynomials(Mxi(:,k),Norder);
end

%% Evaluate the PC expression

for i=1:nalpha
    for k=1:Nrvs
        Mpsi(:,i) = Mpsi(:,i).*CHermite{k}(:,Malpha(i,k)+1);
    end
end
