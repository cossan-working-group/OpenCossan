function Npcterms = pcnumber(Nrvs,Norder)
%PCNUMBER   computes the number of terms in the PC expansion
%   PCNUMBER(Nrvs,Norder) computes the number of terms for a PC basis
%   with dimension Nrvs and order Norder.
%
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================

Npcterms = 0;

for q=0:Norder,
    nbox = Nrvs+q-1;
    Npcterms = Npcterms + nchoosek(nbox,q);
end
