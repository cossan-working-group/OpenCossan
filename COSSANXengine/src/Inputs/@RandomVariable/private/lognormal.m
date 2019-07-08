function Xobj = lognormal(Xobj)
%LOGNORMAL compute missing parameters (if is possible) of the lognormal
%                       distribution
% Input/Output is the structure of the random variable

% Do we need to define the lognormal distribution adopting the
% mean (muLN) and standard deviation (sigLN) of the associated normal distribution?

Xobj.Sdistribution='LOGNORMAL';

% see doc lognstat
Xobj.Cpar{1,1}    = 'mu';
Xobj.Cpar{2,1}    = 'sigma';


if ~isempty(Xobj.Vdata)
    
    if min(size(Xobj.Vdata)) ~= 1 
            error('openCOSSAN:RandomVariable:lognormal',...
            'Vdata must be a vector');
    end
    a= mle(Xobj.Vdata,'distribution','lognormal','frequency',Xobj.Vfrequency, 'censoring',  Xobj.Vcensoring, ...
      'alpha',Xobj. confidenceLevel);
    Xobj.Cpar{1,2}=a(1); Xobj.Cpar{2,2}=a(2);
 
end



if ~isempty(Xobj.Cpar{1,2}) && ~isempty(Xobj.Cpar{2,2})
    [Xobj.mean, var_rv]    =  lognstat(Xobj.Cpar{1,2},Xobj.Cpar{2,2});
    Xobj.std   = sqrt(var_rv);
    Xobj.mean=Xobj.mean+Xobj.shift;
else
    if Xobj.mean-Xobj.shift<=0
        error('openCOSSAN:rv:lognormal',...
            'It is not possible define a lognormal distribution with the mean <= shift');
    end
    if ~isempty(Xobj.CoV) && ~isempty(Xobj.mean)
        if Xobj.CoV<=0
                error('openCOSSAN:rv:lognormal',...
            'It is not possible define a lognormal distribution with the CoV <= 0');
        end 
        
        
        if Xobj.shift ~= 0;
            warning('openCOSSAN:rv:lognormal',...
                        'mean is computed considering shift, if possible use parameters to define shifted rv')
        end
        Xobj.std=abs(Xobj.mean-Xobj.shift)*Xobj.CoV;
        
    elseif ~isempty(Xobj.std) && ~isempty(Xobj.mean)
        if Xobj.shift ~= 0;
            warning('openCOSSAN:rv:lognormal',...
                        'mean is computed with shift, if possible use parameters to define shifted rv')
        end
        Xobj.CoV=Xobj.std/abs((Xobj.mean));
    else
        error('openCOSSAN:rv:lognormal','Not enough parameters defined to identify the distribution');
    end
    Xobj.Cpar{1,2}    = log( (Xobj.mean-Xobj.shift)^2 / sqrt(Xobj.std^2 + (Xobj.mean-Xobj.shift)^2));
    Xobj.Cpar{2,2}    = sqrt( log(Xobj.std^2 / (Xobj.mean-Xobj.shift)^2 + 1));
end
Xobj.lowerBound=Xobj.shift;