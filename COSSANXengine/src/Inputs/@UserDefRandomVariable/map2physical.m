function VX = map2physical(Xrv,VU)
%MAP2PHYSICAL Maps the the specified RV to the physical space
%  MAP2PHYSICAL(Xrv,VU)
%
%  Usage: map2physical(Xrv,VU)
%  Example: VX = map2physical(Xrv,VU)
%
% =====================================================
% COSSAN-X COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM 
% =====================================================


if isempty(Xrv) || isempty(VU) || ~isa(VU,'numeric')
    error('Incorrect number of rguments');
end

 VX =icdf(Xrv.empirical_distribution, normcdf(VU));
end
