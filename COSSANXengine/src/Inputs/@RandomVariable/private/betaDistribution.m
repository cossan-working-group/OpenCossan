function Xobj = betaDistribution(Xobj)
%BETA compute missing parameters (if is possible) of the beta
%                       distribution
% Input/Output is the structure of the random variable

Xobj.Cpar{1,1}    = 'a';
Xobj.Cpar{2,1}    = 'b';

Xobj.Sdistribution='BETA';


if ~isempty(Xobj.Vdata)
    
    if min(size(Xobj.Vdata)) ~= 1 
            error('openCOSSAN:RandomVariable:beta',...
            'All values of Vdata must be within the closed interval [0,1].');
    end
    
    if min(Xobj.Vdata) <= 0 ||  max(Xobj.Vdata) >= 1
        
    end
    
    if sum(Xobj.Vcensoring)
        error('openCOSSAN:RandomVariable:beta',...
            'Censoring is not supported for the uniform distribution');
    end
    
    a= mle(Xobj.Vdata,'distribution','beta','frequency',floor(Xobj.Vfrequency),  ...
      'alpha',Xobj. confidenceLevel);
    Xobj.Cpar{1,2}=a(1); Xobj.Cpar{2,2}=a(2);
    
    
    if length(Xobj.Vdata)<200 || chi2gof(Xobj.Vdata,'cdf',@(z)cdf('beta',z,a(1),a(2)),'nparams',2)

      warning('openCOSSAN:RandomVariable:normal',...
            'The distribution may badly fit the input values'); 
    end
    
end

if ~isempty(Xobj.Cpar{1,2}) && ~isempty(Xobj.Cpar{2,2})
    if  ( Xobj.Cpar{1,2}  <=0) || Xobj.Cpar{2,2}  <=0 
        error('openCOSSAN:RandomVariable:beta',...
            'The parameters of beta distribution must be (strictly) greater than zero');
    end
    [Xobj.mean, var_rv]    =  betastat(Xobj.Cpar{1,2},Xobj.Cpar{2,2});
    Xobj.std   = sqrt(var_rv);
    Xobj.mean=Xobj.mean+Xobj.shift;
elseif ~isempty(Xobj.std) && ~isempty(Xobj.mean)
    
    
    if  ~isempty(Xobj.std) && ~isempty(Xobj.mean)
        std = Xobj.std;
        m = Xobj.mean - Xobj.shift;
        %
        %     elseif ~isempty(Xobj.CoV) && ~isempty(Xobj.mean)
        %         std = Xobj.CoV * Xobj.mean;
        %         m = Xobj.mean;
        %
        %     elseif ~isempty(Xobj.CoV) && ~isempty(Xobj.std)
        %         %TODO
    end
    
    Xobj.Cpar{1,2}    = m * (m*(1-m)/std^2-1);
    Xobj.Cpar{2,2}    = (1-m) * (m*(1-m)/std^2-1);
    if  ( Xobj.Cpar{1,2}  <=0) || Xobj.Cpar{2,2}  <=0
        error('openCOSSAN:RandomVariable:beta',...
            'The parameters of beta distribution could not be computed with input data');
    end
else
    error('openCOSSAN:RandomVariable:beta',...
        'invalid input');
end

if   Xobj.Cpar{1,2}  <=0 ||  Xobj.Cpar{2,2}  <=0
    error('openCOSSAN:RandomVariable:beta',...
        'invalid input');
end

Xobj.lowerBound=Xobj.shift;
Xobj.upperBound=Xobj.shift+1;