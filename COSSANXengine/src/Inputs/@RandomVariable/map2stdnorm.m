function VU = map2stdnorm(Xrv,VX)
%MAP2STDNORM Maps the specified RandomVariable to the standart normal space  
% 
%  MANDATORY ARGUMENTS:
%    - Xrv: the RandomVariable object
%    - VX: Vector containing the values in the physical space to be mapped
%          in the standard normal space 
%
%  OUTPUT ARGUMENTS
%    - VU: array containing the values mapped in the standard normal space
%
%  Usage: VU = map2stdnorm(Xrv,VX)
%
%  See also: RandomVariable, map2physical
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================

if not(nargin==2),
    error('Incorrect number of arguments');
end


switch lower(Xrv.Sdistribution)
    case {'ln','lognormal'}
        VU = norminv(logncdf(VX,Xrv.Cpar{1,2},Xrv.Cpar{2,2}));
    case {'norm','normal'}
        VU = (VX - Xrv.mean) / Xrv.std;
    case {'exp','exponential'}
        VU = norminv(expcdf((VX-Xrv.Cpar{2,2}),Xrv.Cpar{1,2})); 
    case {'uni','uniform'}
        VU = norminv(unifcdf(VX-Xrv.shift,Xrv.lowerBound,Xrv.upperBound));
    case {'rayleigh'}
        VU = norminv(raylcdf((VX-Xrv.shift-(Xrv.mean-Xrv.std*1.91305838027110)),Xrv.std/sqrt(2-pi/2)));
    case {'small-i','sml','small1'}
        small_alpha = pi/(sqrt(6)*Xrv.std^2);
        small_u = Xrv.mean+0.5772156/small_alpha;
        VU = norminv(1-exp(-exp(small_alpha*(VX-Xrv.shift-small_u))));    
    case {'large-i','lar','gumbel-i','gumbeli'}
    large_alpha = pi/(sqrt(6)*Xrv.std);
    large_u = Xrv.mean-0.5772156/large_alpha;
    VU = norminv(exp(-exp(-large_alpha*(VX-large_u)))); 
    case {'large-ii','frechet'}
        VU = norminv(exp(-((VX - Xrv.shift)/Xrv.Cpar{2,2}).^(-Xrv.Cpar{1,2})));
    case {'weibull'}
        VU = norminv(wblcdf(VX-Xrv.shift, Xrv.Cpar{1,2}, Xrv.Cpar{2,2}));
    case {'student','t'}
        VU =norminv(tcdf(VX-Xrv.shift,Xrv.Cpar{1,2})); 
    case {'gamma'}
        VU =norminv(gamcdf(VX-Xrv.shift,Xrv.Cpar{1,2},Xrv.Cpar{2,2})); 
    case {'f'}
        VU =norminv(fcdf(VX-Xrv.shift,Xrv.Cpar{1,2},Xrv.Cpar{2,2}));
    case {'beta'}
        VU =norminv(betacdf(VX-Xrv.shift,Xrv.Cpar{1,2},Xrv.Cpar{2,2}));
    case {'generalizedpareto'}
        VU =norminv(gpcdf(VX-Xrv.shift,Xrv.Cpar{1,2},Xrv.Cpar{2,2},Xrv.Cpar{3,2}));
    case {'logistic'}
        VU =norminv(1./(1+exp((-VX-Xrv.shift+Xrv.Cpar{1,2})/Xrv.Cpar{2,2})));
    case {'chi2'}
        VU =norminv(chi2cdf(VX-Xrv.shift,Xrv.Cpar{1,2}));
    case {'normt','truncnormal','normal truncated','truncated normal'}
        %parameters of the untruncated normal distribution
        m=Xrv.Cpar{1,2};
        s=Xrv.Cpar{2,2};
        % truncation limits
        a=Xrv.lowerBound;
        b=Xrv.upperBound;
        % truncation limits in the normal space
        aa = (a-m)/s;
        bb = (b-m)/s;
        mm=m*ones(size(VX));
        if (VX<a)
            VU=-Inf;
        elseif (VX>b)
            VU=Inf;
        else
             VU=norminv( (normcdf((VX-mm)/s,0,1) - normcdf(aa)*ones(size(VX)))/(normcdf(bb,0,1) - normcdf(aa,0,1)));
        end
    case {'unid'}
        VU = norminv(cdf('unid',VX- Xrv.lowerBound,Xrv.upperBound - Xrv.lowerBound));
    case {'poisson','geometric'}
        VU = norminv(cdf(Xrv.Sdistribution,VX-Xrv.shift, Xrv.Cpar{1,2}));
    case {'binomial','negative binomial'}
        VU = norminv(cdf(Xrv.Sdistribution, VX-Xrv.shift, Xrv.Cpar{1,2}, Xrv.Cpar{2,2}));
     case {'hypergeometric'}
        VU = norminv(cdf(Xrv.Sdistribution, VX-Xrv.shift, Xrv.Cpar{1,2}, Xrv.Cpar{2,2}, Xrv.Cpar{3,2}));   
        
    otherwise
        error('openCOSSAN:RandomVariable:evalpdf',['distribution ' Xrv.Sdistribution ' not available']);
end

