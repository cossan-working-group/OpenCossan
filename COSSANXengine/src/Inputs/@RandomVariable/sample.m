function VX = sample(Xrv,varargin)
%SAMPLE Generates samples for the specified RV
%  SAMPLE(rv1,varargin)
%
%   USAGE:  Px=SAMPLE(Xrv,'PropertyName', PropertyValue, ...)
%
%   The sample method produce a vector or a matrix of samples from the RV
%   object.
%   The method takes a variable number of token value pairs.  These
%   pairs set properties (optional values) of the run method.
%
%   MANDATORY ARGUMENTS
%       - Xrv: the random variable to sample
%
%   OPTIONNAL ARGUMENTS
%       - Nsamples: number of samples
%       - Vsamples: array containing respectively the number of rows and the number of
%                   columns of the output matrix of sample
%
%   OUTPUT ARGUMENTS
%       - VX: array or matrix containing numerical values of samples of the
%             input random variable
%
%
%  Example:
% * Vx=sample(Xrv,'Nsamples',m) produces m samples for the specified RV
% * Vx=sample(Xrv) produces a single sample
% * Mx=sample(Xrv,'Vsamples',[m n]) produces a sample matrix mxn
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Sample@RandomVariable
%
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria

OpenCossan.validateCossanInputs(varargin{:});
m = 1;
n = 1;
for k=1:2:length(varargin)
    if ~isa(varargin{k},'char')
        warning('openCOSSAN:RandomVariable:sample',...
            'Please pass the arguments list in pairs (PropertyName, PropertyValue)')
        if nargin < 1
            error('openCOSSAN:rv:samplerv','Requires at least one input argument.\n');
        elseif nargin == 1
            m = 1; n = m;
        elseif nargin == 2
            m = varargin{1}; n = m;
        elseif nargin == 3
            m = varargin{1}; n = varargin{2};
        else
            error('openCOSSAN:rv:samplerv','TooManyInputs: Requires at most three input arguments.');
        end
    else
        if length(varargin) >2
            error('openCOSSAN:rv:samplerv','Too many inputs arguments');
        end
        switch lower(varargin{k})
            case {'nsamples'}
                m = varargin{k+1};
                n = 1;
            case {'vsamples'}
                m = varargin{k+1}(1);
                n = varargin{k+1}(2);
            otherwise
                error('openCOSSAN:rv:samplerv','Invalid input argument');
                
        end
    end
end

switch lower(Xrv.Sdistribution)
    case {'ln','lognormal'}
        VX = lognrnd(Xrv.Cpar{1,2},Xrv.Cpar{2,2},m,n) + Xrv.shift*ones(m,n) ;
    case {'norm','normal'}
        VX = normrnd(Xrv.mean,Xrv.std,m,n);
    case {'exp','exponential'}
        VX = exprnd(Xrv.Cpar{1,2},m,n)+Xrv.Cpar{2,2};
    case {'uni','uniform'}
        VX = unifrnd(Xrv.lowerBound,Xrv.upperBound,m,n);
    case {'rayleigh'}
        VX = raylrnd(Xrv.Cpar{1,2},m,n) + Xrv.shift*ones(m,n);
    case {'small-i','sml','small1'}
        small_alpha = pi/(sqrt(6)*Xrv.std);
        small_u = Xrv.mean-Xrv.shift+0.5772156/small_alpha;
        VX = small_u+log(-log(1-rand(m,n)))/small_alpha + Xrv.shift*ones(m,n);
    case {'large-i','lar','gumbel-i','gumbeli','gumbel-max'}
        if isempty(Xobj.Cpar)
            large_alpha=Xobj.Cpar{1,2};
            large_u=Xobj.Cpar{2,2};
        else    
            large_alpha = pi/(sqrt(6)*Xrv.std);
            large_u = Xrv.mean-Xrv.shift-0.5772156/large_alpha;
        end
        VX = large_u-log(-log(rand(m,n)))/large_alpha + Xrv.shift*ones(m,n);     
    case {'large-ii','frechet'}
        VX = Xrv.shift*ones(m,n) + Xrv.Cpar{2,2}*(-log(rand(m,n))).^(-1/Xrv.Cpar{1,2});
    case {'weibull'}
        VX = wblrnd(Xrv.Cpar{1,2},Xrv.Cpar{2,2},m,n) + Xrv.shift*ones(m,n);
    case {'f'}
        VX = frnd(Xrv.Cpar{1,2},Xrv.Cpar{2,2},m,n) + Xrv.shift*ones(m,n);
    case {'generalizedpareto'}
        VX = gprnd(Xrv.Cpar{1,2},Xrv.Cpar{2,2},Xrv.Cpar{3,2},m,n) + Xrv.shift*ones(m,n);
    case {'student','t'}
        VX = trnd(Xrv.Cpar{1,2},m,n) + Xrv.shift*ones(m,n);
    case {'gamma'}
        VX = gamrnd(Xrv.Cpar{1,2},Xrv.Cpar{2,2},m,n) + Xrv.shift*ones(m,n);
    case {'beta'}
        VX = betarnd(Xrv.Cpar{1,2},Xrv.Cpar{2,2},m,n) + Xrv.shift*ones(m,n);
    case {'chi2'}
        VX = chi2rnd(Xrv.Cpar{1,2},m,n)  + Xrv.shift*ones(m,n);
    case {'unid'}
        VX = Xrv.lowerBound + random('unid',Xrv.upperBound-Xrv.lowerBound,m,n );
    case {'poisson','geometric'}
        VX = random(Xrv.Sdistribution,Xrv.Cpar{1,2},m,n );
    case {'binomial','negative binomial'}
        VX = random(Xrv.Sdistribution,Xrv.Cpar{1,2},Xrv.Cpar{2,2},m,n )+ Xrv.shift*ones(m,n);
    case {'hypergeometric'}
        VX = random(Xrv.Sdistribution,Xrv.Cpar{1,2},Xrv.Cpar{2,2},Xrv.Cpar{3,2},m,n )+ Xrv.shift*ones(m,n);
    case {'logistic'}
        VZ = normcdf(normrnd(0,1,m,n));
        VX = Xrv.Cpar{1,2} + Xrv.Cpar{2,2} * log(VZ./(1-VZ))+ Xrv.shift*ones(m,n);
    case {'normt','truncnormal','normal truncated','truncated normal'}
        p=unifrnd(0,1,m,n);
        %parameters of the untruncated normal distribution
        m=Xrv.Cpar{1,2};
        s=Xrv.Cpar{2,2};
        % truncation limits
        a=Xrv.lowerBound;
        b=Xrv.upperBound;
        %invert CDF of normal truncated distribution
        clft=normcdf(a,m,s);
        crgt=normcdf(b,m,s);
        if length(p) == 1
            VX=norminv(p*(crgt-clft)+clft,m,s);
        else
            VX = norminv(p.*(crgt-clft)+clft,m,s);
        end;
    otherwise
        error('openCOSSAN:RandomVariable:sample',['distribution ' Xrv.Sdistribution ' not available']);
end


