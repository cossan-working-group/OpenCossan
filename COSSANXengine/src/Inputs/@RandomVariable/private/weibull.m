function Xobj = weibull(Xobj)
%WEIBULL compute missing parameters (if is possible) of the normal
%                       distribution
% Input/Output is the structure of the random variable

Xobj.Cpar{1,1}    = 'a';
Xobj.Cpar{2,1}    = 'b';
Xobj.Sdistribution='WEIBULL';
if ~isempty(Xobj.Vdata)
    
    if min(size(Xobj.Vdata)) ~= 1 
            error('openCOSSAN:RandomVariable:weibull',...
            'Vdata must be a vector');
    end
    a= mle(Xobj.Vdata,'distribution','weibull','frequency',Xobj.Vfrequency, 'censoring',  Xobj.Vcensoring, ...
      'alpha',Xobj. confidenceLevel);
    
    Xobj.Cpar{1,2}=a(1); Xobj.Cpar{2,2}=a(2);
    
elseif isempty(Xobj.Cpar{1,2}) || isempty(Xobj.Cpar{2,2}) 
    error('openCOSSAN:RandomVariable:weibull','Weibull has to be defined only via parameter1 and parameter2');
end

[Nmean,Nvar]=wblstat(Xobj.Cpar{1,2},Xobj.Cpar{2,2});
% wblstat(A,B) returns the mean of and variance for the Weibull
% distribution with parameters specified by A and B. 
% help wblstat

Xobj.mean = Nmean+Xobj.shift; 
Xobj.std  = sqrt(Nvar);
Xobj.lowerBound=Xobj.shift;

