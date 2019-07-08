function Xobj = geometric(Xobj)
%STUDENT compute missing parameters (if is possible) of the poisson
%                       distribution
% Input/Output is the structure of the random variable

Xobj.Cpar{1,1}    = 'lambda';
Xobj.Sdistribution='geometric';
% if Xobj.shift ~= 0;
%     error('openCOSSAN:rv:geometric','shifted geometric distributions can not be defined');
% end
if ~isempty(Xobj.Vdata)
    
    error('openCOSSAN:RandomVariable:geometric',...
        'Vdata is not available for geometric distribution');
end
% 
% if ~isempty(Xobj.mean)
%     Xobj.Cpar{1,2} = Xobj.mean;
% end

if isempty(Xobj.Cpar{1,2})
    error('openCOSSAN:RandomVariable:geometric','geometric can be defined only via parameter1');
end


if Xobj.Cpar{1,2}<=0
    error('openCOSSAN:RandomVariable:poisson','the parameter defining geometric distribution must be greater than zero');
end


[Nmean,Nvar]=geostat(Xobj.Cpar{1,2});


Xobj.mean = Nmean; 
Xobj.std  = sqrt(Nvar);
Xobj.lowerBound = 0;
