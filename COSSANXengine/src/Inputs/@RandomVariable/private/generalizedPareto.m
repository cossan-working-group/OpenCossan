function Xobj = generalizedPareto(Xobj)
%GENERALIZEDPARETO compute missing parameters (if is possible) of the
%general Pareto distribution
%                       
% Input/Output is the structure of the random variable

Xobj.Cpar{1,1}    = 'k';
Xobj.Cpar{2,1}    = 'sigma';
Xobj.Cpar{3,1}    = 'theta';

Xobj.Sdistribution='GENERALIZEDPARETO';


if ~isempty(Xobj.Vdata)
    %see doc gpfit
            error('openCOSSAN:RandomVariable:generalizedPareto',...
            'Vdata is not available for generalizedPareto distribution');
end




if isempty(Xobj.Cpar{1,2}) || isempty(Xobj.Cpar{2,2}) || isempty(Xobj.Cpar{3,2}) 
    error('openCOSSAN:RandomVariable:generalizedPareto','generalized Pareto distribution can be defined only via parameter1, parameter2 and parameter3');
end

if Xobj.Cpar{2,2}<=0 
    error('openCOSSAN:RandomVariable:generalizedPareto','The second parameter of generalized Pareto distribution must be more than zero');
end

[Nmean,Nvar]=gpstat(Xobj.Cpar{1,2},Xobj.Cpar{2,2},Xobj.Cpar{3,2});

Xobj.mean = Nmean+Xobj.shift; 
Xobj.std  = sqrt(Nvar);
%Xobj.CoV = Xobj.std/abs(Xobj.mean);
Xobj.lowerBound=Xobj.shift;

