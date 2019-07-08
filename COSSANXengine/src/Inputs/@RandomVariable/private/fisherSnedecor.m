function Trv = fisherSnedecor(Trv)
%LOGNORMAL compute missing parameters (if is possible) of the lognormal
%                       distribution
% Input/Output is the structure of the random variable

% Do we need to define the lognormal distribution adopting the
% mean (muLN) and standard deviation (sigLN) of the associated normal distribution?

Trv.Sdistribution='F';

% see doc lognstat
Trv.Cpar{1,1}    = 'p1';
Trv.Cpar{2,1}    = 'p2';


if ~isempty(Trv.Vdata)
    
            error('openCOSSAN:RandomVariable:FisherSnedecor',...
            'Vdata is not available for FisherSnedecor distribution');
end


if ~isempty(Trv.Cpar{1,2}) && ~isempty(Trv.Cpar{2,2})
    [mean_rv, var_rv]    =  fstat(Trv.Cpar{1,2},Trv.Cpar{2,2});
    Trv.std   = sqrt(var_rv);
    Trv.mean=mean_rv+Trv.shift;
else
      error('openCOSSAN:RandomVariable:F', ...
                ' F distribution must be defined using two parameters');
end
Trv.lowerBound=Trv.shift;