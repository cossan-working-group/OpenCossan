function Vpdf_vX = evalpdf(Xr,Vx)
%EVALPDF Evaluates the pdf of an RV at the point Vx
%  evalpdf(rv1,vX)
%
%   - Xr     :  contains the information about the random variable
%   - Vx     :  realization where the pdf will be evaluated
%
%  Usage: evalpdf(rv1,vX)
%  Example: Vpdf_Vx = evalpdf(rv1,Vx)        
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2007 IfM
% =====================================================

%% 1.   Argument Verification
if not(nargin==2),
    error('openCOSSAN:rv:evalpdf','Incorrect number of arguments \n Usage: evalpdf(RVobject,Vector of values)');
end

        Vpdf_vX  =pdf(Xr.empirical_distribution,Vx);

end
   
