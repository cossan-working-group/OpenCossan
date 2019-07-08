function Xobj = hypergeometric(Xobj)
%STUDENT compute missing parameters (if is possible) of the poisson
%                       distribution
% Input/Output is the structure of the random variable

Xobj.Cpar{1,1}    = 'N';
Xobj.Cpar{2,1}    = 'm';
Xobj.Cpar{3,1}    = 'n';
Xobj.Sdistribution='hypergeometric';
% if Xobj.shift ~= 0;
%     error('openCOSSAN:rv:hypergeometric','shifted hypergeometric distributions can not be defined');
% end
if ~isempty(Xobj.Vdata)
    
    error('openCOSSAN:RandomVariable:hypergeometric',...
        'Vdata is not available for hypergeometric distribution');
end
% 
% if ~isempty(Xobj.mean)
%     Xobj.Cpar{1,2} = Xobj.mean;
% end
 
if isempty(Xobj.Cpar{1,2}) || isempty(Xobj.Cpar{2,2}) || isempty(Xobj.Cpar{3,2}) 
    error('openCOSSAN:RandomVariable:hypergeometric','hypergeometric can be defined only via 3 parameters');
end


[Nmean,Nvar]=hygestat(Xobj.Cpar{1,2},Xobj.Cpar{2,2},Xobj.Cpar{3,2});


Xobj.mean = Nmean; 
Xobj.std  = sqrt(Nvar);
Xobj.lowerBound = 0;
