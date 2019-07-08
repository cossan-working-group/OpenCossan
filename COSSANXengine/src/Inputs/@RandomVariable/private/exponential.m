function Xobj = exponential(Xobj)
%EXPONENTIAL compute missing parameters (if is possible) of the exponential
%                       distribution
% Input/Output is the structure of the random variable


Xobj.Cpar{1,1}    = '1/lambda';
Xobj.Cpar{2,1}    = 'shifting';

if ~isempty(Xobj.Vdata)
    
    if min(size(Xobj.Vdata)) ~= 1
        error('openCOSSAN:RandomVariable:exponential',...
            'Vdata must be a vector');
    end
    a= mle(Xobj.Vdata,'distribution','exponential','frequency',Xobj.Vfrequency, 'censoring',  Xobj.Vcensoring, ...
        'alpha',Xobj. confidenceLevel);
    Xobj.Cpar{1,2}=a(1);
    
    if length(Xobj.Vdata)>15 && chi2gof(Xobj.Vdata,'cdf',@(z)cdf('exp',z,a(1)),'nparams',1)
        warning('openCOSSAN:RandomVariable:exponential',...
            'The distribution may badly fit the input values');
    end
    
    
    
end


if Xobj.shift ~= 0;
    Xobj.Cpar{2,2}=Xobj.shift;
end
if Xobj.Cpar{2,2} ~= 0;
    Xobj.shift=Xobj.Cpar{2,2};
end
if ~isempty(Xobj.Cpar{1,2})
    Xobj.std       = Xobj.Cpar{1,2};
    if ~isempty(Xobj.Cpar{2,2}) % shifted exponential distribution
        Xobj.mean        = Xobj.Cpar{1,2} + Xobj.Cpar{2,2};
    else
        Xobj.mean        = Xobj.Cpar{1,2};
        Xobj.Cpar{2,2} = 0; % Assign null shifting if not defined by the user
    end
    %    Xobj.CoV=Xobj.std/abs(Xobj.mean);
else
    if ~isempty(Xobj.mean) && isempty(Xobj.std)
               Xobj.std=Xobj.mean;
        Xobj.Cpar{1,2}=Xobj.std;
        Xobj.Cpar{2,2}=Xobj.mean-Xobj.std;     
     elseif ~isempty(Xobj.std)  &&  isempty(Xobj.mean)
        Xobj.mean=Xobj.std;
        Xobj.Cpar{1,2}=Xobj.std;
        Xobj.Cpar{2,2}=Xobj.mean-Xobj.std;         
    elseif ~isempty(Xobj.CoV) && ~isempty(Xobj.mean)
        Xobj.std=Xobj.mean*Xobj.CoV;
        Xobj.Cpar{1,2}=Xobj.std;
        Xobj.Cpar{2,2}=Xobj.mean-Xobj.std;
    elseif ~isempty(Xobj.std) && ~isempty(Xobj.mean)
        Xobj.Cpar{1,2}=Xobj.std;
        Xobj.Cpar{2,2}=Xobj.mean-Xobj.std;
        Xobj.CoV=Xobj.std/(Xobj.mean);
    else
        error('openCOSSAN:rv:exponential', ...
            ' exponential distribution must be defined using a parameter');    
    end
    
    
    
end


Xobj.lowerBound=Xobj.shift;

