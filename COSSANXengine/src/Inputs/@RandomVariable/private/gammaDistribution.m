function Xobj = gammaDistribution(Xobj)
%GAMMMA compute missing parameters (if is possible) of the gamma
%                       distribution
% Input/Output is the structure of the random variable

Xobj.Cpar{1,1}    = 'k';
Xobj.Cpar{2,1}    = 'theta';

Xobj.Sdistribution='GAMMA';

if ~isempty(Xobj.Vdata)
    
    if min(size(Xobj.Vdata)) ~= 1 
            error('openCOSSAN:RandomVariable:gamma',...
            'Vdata must be a vector');
    end
    a= mle(Xobj.Vdata,'distribution','gamma','frequency',Xobj.Vfrequency, 'censoring',  Xobj.Vcensoring, ...
      'alpha',Xobj. confidenceLevel);
  
    Xobj.Cpar{1,2}=a(1); Xobj.Cpar{2,2}=a(2);
 
    if length(Xobj.Vdata)>15 && chi2gof(Xobj.Vdata,'cdf',@(z)cdf('gamma',z,a(1),a(2)),'nparams',2)
       warning('openCOSSAN:RandomVariable:normal',...
            'The distribution may badly fit the input values'); 
    end
    
end

if ~isempty(Xobj.Cpar{1,2}) && ~isempty(Xobj.Cpar{2,2})
    
    if Xobj.Cpar{1,2}<=0 || Xobj.Cpar{2,2}<=0
            error('openCOSSAN:RandomVariable:gamma',...
            'The parameters of the gamma distribution must be greater than zero');
    end
    
    
    [Xobj.mean, var_rv]    =  gamstat(Xobj.Cpar{1,2},Xobj.Cpar{2,2});
    Xobj.std   = sqrt(var_rv);
    Xobj.mean=Xobj.mean+Xobj.shift;
    
elseif ~isempty(Xobj.std) && ~isempty(Xobj.mean)
    
    if Xobj.mean-Xobj.shift<=0
        error('openCOSSAN:RandomVariable:gamma',...
            'It is not possible define a beta distribution with the mean <= shift');
    end
    
   % if  ~isempty(Xobj.std) && ~isempty(Xobj.mean)
        std = Xobj.std;
        m = Xobj.mean - Xobj.shift;
        %
        %     elseif ~isempty(Xobj.CoV) && ~isempty(Xobj.mean)
        %         std = Xobj.CoV * Xobj.mean;
        %         m = Xobj.mean;
        %
        %     elseif ~isempty(Xobj.CoV) && ~isempty(Xobj.std)
        %         %TODO
   % end
    
    Xobj.Cpar{1,2}    = (m/std)^2;
    Xobj.Cpar{2,2}    =  std^2/m;
else
            error('openCOSSAN:RandomVariable:gamma',...
            'invalid input');
end

Xobj.lowerBound=Xobj.shift;
