function Xobj = negativeBinomial(Xobj)
%WEIBULL compute missing parameters (if is possible) of the normal
%                       distribution
% Input/Output is the structure of the random variable

Xobj.Cpar{1,1}    = 'n';
Xobj.Cpar{2,1}    = 'p';
Xobj.Sdistribution='negative binomial';
% 
% if Xobj.shift ~= 0;
%     error('openCOSSAN:rv:binomial','shifted binomial distributions can not be defined');
% end
if ~isempty(Xobj.Vdata)
    
    error('openCOSSAN:RandomVariable:binomial',...
        'Vdata is not available for binomial distribution');
end


if isempty(Xobj.Cpar{1,2}) ||isempty(Xobj.Cpar{2,2})
    error('openCOSSAN:RandomVariable:binomial','binomial can be defined only via parameters');
end


if Xobj.Cpar{1,2}<=0 || Xobj.Cpar{2,2}<=0
    error('openCOSSAN:RandomVariable:binomial','the parameters defining binomial distribution must be greater than zero');
end


[Nmean,Nvar]=nbinstat(Xobj.Cpar{1,2},Xobj.Cpar{2,2});
% wblstat(A,B) returns the mean of and variance for the Weibull
% distribution with parameters specified by A and B. 
% help wblstat

Xobj.mean = Nmean; 
Xobj.std  = sqrt(Nvar);
Xobj.lowerBound=0;

