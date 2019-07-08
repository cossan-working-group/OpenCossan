function VX = map2physical(Xrv,VU)
%MAP2PHYSICAL Maps the the specified RandomVariable to the physical space
% 
%  MANDATORY ARGUMENTS:
%    - Xrv: the RandomVariable object
%    - VU: array containing the values in the standard normal space to be
%          mapped in the physical space 
%
%  OUTPUT ARGUMENTS
%    - VX: array containing the values mapped in the physical space
%
%  Usage: VX = map2physical(Xrv,VU)
%
%  See also: RandomVariable, map2stdnorm
%
% =====================================================
% COSSAN-X COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM 
% =====================================================

if not(nargin==2),
    error('Incorrect number of arguments');
end

switch lower(Xrv.Sdistribution)
    case {'ln','lognormal'}
        VX = logninv(normcdf(VU),Xrv.Cpar{1,2},Xrv.Cpar{2,2})+Xrv.shift;
    case {'norm','normal'}
        VX = VU * Xrv.std + Xrv.mean;
    case {'exp','exponential'}
        VX = expinv(normcdf(VU),Xrv.Cpar{1,2})+Xrv.Cpar{2,2};  
    case {'uni','uniform'}
        VX = unifinv(normcdf(VU),Xrv.lowerBound,Xrv.upperBound);
    case {'rayleigh'}
        VX = raylinv(normcdf(VU),Xrv.Cpar{1,2})+Xrv.shift; 
    case {'small-i','sml','small1'}
        small_alpha = pi/(sqrt(6)*Xrv.std);
        small_u = Xrv.mean+0.5772156/small_alpha;
        VX = small_u+log(-log(1-normcdf(VU)))/small_alpha+Xrv.shift;
    case {'large-i','lar','gumbel-i','gumbeli'}
        large_alpha = pi/(sqrt(6)*Xrv.std);
        large_u = Xrv.mean-0.5772156/large_alpha;
        VX = large_u-log(-log(normcdf(VU)))/large_alpha+Xrv.shift;     
    case {'large-ii','frechet'}
        VX = Xrv.shift + Xrv.Cpar{2,2}*(-log(normcdf(VU))).^(-1/Xrv.Cpar{1,2});
    case {'student','t'}
        VX =tinv(normcdf(VU),Xrv.Cpar{1,2})+Xrv.shift; 
    case {'gamma'}
        VX =gaminv(normcdf(VU),Xrv.Cpar{1,2},Xrv.Cpar{2,2})+Xrv.shift;
    case {'f'}
        VX =finv(normcdf(VU),Xrv.Cpar{1,2},Xrv.Cpar{2,2})+Xrv.shift;
    case {'beta'}
        VX =betainv(normcdf(VU),Xrv.Cpar{1,2},Xrv.Cpar{2,2})+Xrv.shift;
    case {'logistic'}
        VX = Xrv.Cpar{1,2} + Xrv.Cpar{2,2} * log(normcdf(VU)./(1-normcdf(VU)))+ Xrv.shift;
    case {'generalizedpareto'}
        VX =gpinv(normcdf(VU),Xrv.Cpar{1,2},Xrv.Cpar{2,2},Xrv.Cpar{3,2})+Xrv.shift;
    case {'chi2'}
        VX =chi2inv(normcdf(VU),Xrv.Cpar{1,2})+Xrv.shift;
    case {'weibull'}
        VX =wblinv(normcdf(VU), Xrv.Cpar{1,2}, Xrv.Cpar{2,2})+Xrv.shift;
    case {'normt','truncnormal','normal truncated','truncated normal'}
        p=normcdf(VU);
        m=Xrv.Cpar{1,2};
        s=Xrv.Cpar{2,2};
        a=Xrv.lowerBound;
        b=Xrv.upperBound;
        %invert CDF of normal truncated distribution
        clft=normcdf(a,m,s);
        crgt=normcdf(b,m,s);
        if length(p) == 1
            res=norminv(p*(crgt-clft)+clft,m,s);
        else
            res = norminv(p.*(crgt-clft)+clft,m,s);
        end;
        tL= (res < a);
        tR= (res > b);
        ok=(res >= a) & (res <= b);
        if a==-Inf
            VX=res.*ok + b*tR;
        elseif b==Inf
            VX=res.*ok+a*tL;
        else
           VX=res.*ok+a*tL + b*tR;
        end
    case {'uniform discrete','unid','uniformdiscrete'}
        VX = Xrv.lowerBound + icdf('unid',normcdf(VU),Xrv.upperBound-Xrv.lowerBound);
    case {'poisson','geometric'}
         VX = icdf(Xrv.Sdistribution,normcdf(VU),Xrv.Cpar{1,2} )+Xrv.shift;
    case {'binomial','negative binomial'}
        VX = icdf(Xrv.Sdistribution, normcdf(VU),Xrv.Cpar{1,2},Xrv.Cpar{2,2})+Xrv.shift;
        case {'hypergeometric'}
        VX = icdf(Xrv.Sdistribution, normcdf(VU),Xrv.Cpar{1,2},Xrv.Cpar{2,2},Xrv.Cpar{3,2})+Xrv.shift;
    otherwise
        error('openCOSSAN:RandomVariable:evalpdf',['distribution ' Xrv.Sdistribution ' not available']);
end
