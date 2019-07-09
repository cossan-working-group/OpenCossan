function [alpha,varargout] = getindex_incl(M,p)
%GETINDEX_INCL   Get index sequences up to order p.
%   GETINDEX_INCL(M,p) returns all index sequences with M indices a_1,... a_M,
%   such that a_1 + a_2 + ... + a_M < p+1
%
%   [ALPHA, NALPHA] = GETINDEX_INCL(M,q) outputs the array of sequences ALPHA,
%   as well as the number of sequences NALPHA
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================

[alpha,nalpha] = getindex(M,0);

% Generate and assemble array alpha
for i=1:p,
    [tmp tmp2]= getindex(M,i);
    alpha = [alpha; tmp];
    nalpha = nalpha + tmp2;
end

% When 2 output arguments are given, output number of index sequences nalpha
if nargout==2
    varargout(1)={nalpha};
end
