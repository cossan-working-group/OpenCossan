function Xobj = poisson(Xobj)
%STUDENT compute missing parameters (if is possible) of the poisson
%                       distribution
% Input/Output is the structure of the random variable

Xobj.Cpar{1,1}    = 'lambda';
Xobj.Sdistribution='poisson';
% if Xobj.shift ~= 0;
%     error('openCOSSAN:rv:uniformdiscrete','shifted poisson distributions can not be defined');
% end
if ~isempty(Xobj.Vdata)
    
    error('openCOSSAN:RandomVariable:poisson',...
        'Vdata is not available for poisson distribution');
end

if ~isempty(Xobj.mean)
    Xobj.Cpar{1,2} = Xobj.mean;
end

if isempty(Xobj.Cpar{1,2})
    error('openCOSSAN:RandomVariable:poisson','poisson can be defined only via parameter1');
end


if Xobj.Cpar{1,2}<=0
    error('openCOSSAN:RandomVariable:poisson','the parameter defining poisson distribution must be greater than zero');
end


[Nmean,Nvar]=poisstat(Xobj.Cpar{1,2});


Xobj.mean = Nmean; 
Xobj.std  = sqrt(Nvar);
Xobj.lowerBound = 0;
