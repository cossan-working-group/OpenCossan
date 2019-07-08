function VU = map2stdnorm(Xrv,VX)
%MAP2STDNORM Maps the specified RV to the standart normal space  
%  MAP2STDNORM(Xrv,VX) 
%
%  Usage: map2stdnorm(Xrv,VX)
%  Example: VU = map2stdnorm(Xrv,VX)         
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================

if isempty(Xrv) || isempty(VX) || ~isa(VX,'numeric')
    error('Incorrect number of rguments');
end


VU =norminv( cdf(Xrv.empirical_distribution,VX));
end

