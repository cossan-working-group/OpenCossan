function Xobj = logistic(Xobj)
%LOGISTIC compute missing parameters (if is possible) of the logistic
%                       distribution
% Input/Output is the structure of the random variable

Xobj.Cpar{1,1}    = 'm';
Xobj.Cpar{2,1}    = 's';

Xobj.Sdistribution='LOGISTIC';

if Xobj.shift ~= 0;
    error('openCOSSAN:RandomVariable:logistic','shifted logistic distributions can not be defined, use parameter1 or mean');
end


if ~isempty(Xobj.Vdata)
    
            
    if min(size(Xobj.Vdata)) ~= 1 
            error('openCOSSAN:RandomVariable:beta',...
            'Vdata must be a vector');
    end

    logisticpdf = @(Vx,mu,sig)(exp(-(Vx-mu)/sig)./(sig*(1+exp(-(Vx-mu)/sig)).^2));
    
    if sum(Xobj.Vcensoring)
        error('openCOSSAN:RandomVariable:uniform',...
            'Censoring is not supported for the uniform distribution');
    end
    
    a= mle(Xobj.Vdata,'pdf',logisticpdf,'start',[mean(Xobj.Vdata) std(Xobj.Vdata)] ,'frequency',Xobj.Vfrequency, ...
      'alpha',Xobj. confidenceLevel);
    Xobj.Cpar{1,2}=a(1); Xobj.Cpar{2,2}=a(2);
    
    
end

if ~isempty(Xobj.Cpar{1,2}) && ~isempty(Xobj.Cpar{2,2})
    
    if Xobj.Cpar{2,2}<=0
            error('openCOSSAN:RandomVariable:logistic',...
            'The second parameter of the logistic distribution must be greater than zero');
    end
    
    Xobj.std   = Xobj.Cpar{2,2}*pi*sqrt(1/3);
    Xobj.mean=Xobj.Cpar{1,2}+Xobj.shift;
    
elseif ~isempty(Xobj.std) && ~isempty(Xobj.mean)
    

    Xobj.Cpar{1,2}    = Xobj.mean;
    Xobj.Cpar{2,2}    = sqrt(3)* Xobj.std/pi;
else
            error('openCOSSAN:RandomVariable:logistic',...
            'the distribution could not be created because of missing or invalid parameters');
end

