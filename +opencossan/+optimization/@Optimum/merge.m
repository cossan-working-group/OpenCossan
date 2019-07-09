function Xobj = merge(Xobj,Xobj2)
%MERGE merge 2 Optimium objects
%
%   MANDATORY ARGUMENTS
%   - Xobj2: Optimum object
%
%   OUTPUT
%   - Xobj: object of class Optimum
%
%   USAGE
%   Xobj = Xobj.merge(Xobj2)
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/Merge@Optimum

% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================
% Author: Edoardo Patelli


%%    Argument Check
assert(isa(Xobj2,'Optimum'), ...
    'openCOSSAN:Optimum:merge',...
    ' The object passed to this function is of type %s\nRequired type Optimum.', class(Xobj2));


%% Merge Properties
Xobj.Sdescription=strcat(Xobj.Sdescription,' | ', Xobj2.Sdescription); % Description of the object
Xobj.Sexitflag=strcat(Xobj.Sexitflag,' | ', Xobj2.Sexitflag);       % exit flag of optimization algorithm
Xobj.totalTime=Xobj.totalTime+Xobj2.totalTime;                      % time required to solve problem

assert(all(ismember(Xobj.CdesignVariableNames,Xobj2.CdesignVariableNames)),...
        'openCOSSAN:Optimum:merge',...
        strcat('The two optimum objects must contain the same designvaliable name',...
        '\nObj1: Design Variable name %s\nObj1: Design Variable name %s'), ...
        sprintf(Xobj.CdesignVariableNames{:}),sprintf(Xobj2.CdesignVariableNames{:}))
    
    
% names of the Design Variables
for n=1:size(Xobj.XdesignVariable,2) 
Xobj.XdesignVariable(n)=Xobj.XdesignVariable(n).addData('Mdata',Xobj2.XdesignVariable(n).Vdata,...
    'Mcoord',Xobj2.XdesignVariable(n).Mcoord); % values design variables
end

for n=1:size(Xobj.XobjectiveFunction,2)
    Xobj.XobjectiveFunction(n)=Xobj.XobjectiveFunction(n).addData ...
         ('Mdata',Xobj2.XobjectiveFunction(n).Vdata,'Mcoord',Xobj2.XobjectiveFunction(n).Mcoord); 
end

for n=1:size(Xobj.XobjectiveFunctionGradient,2) 
    Xobj.XobjectiveFunctionGradient(n)=Xobj.XobjectiveFunctionGradient(n).addData ...
         ('Mdata',Xobj2.XobjectiveFunctionGradient(n).Vdata,...
         'Mcoord',Xobj2.XobjectiveFunctionGradient(n).Mcoord); 
end

for n=1:size(Xobj.Xconstrains,2) 
    Xobj.Xconstrains(n)=Xobj.Xconstrains(n).addData ...
         ('Mdata',Xobj2.Xconstrains(n).Vdata,...
         'Mcoord',Xobj2.Xconstrains(n).Mcoord); 
end

for n=1:size(Xobj.XconstrainsGradient,2) 
    Xobj.XconstrainsGradient(n)=Xobj.XconstrainsGradient(n).addData ...
         ('Mdata',Xobj2.XconstrainsGradient(n).Vdata,...
          'Mcoord',Xobj2.XconstrainsGradient(n).Mcoord); 
end











