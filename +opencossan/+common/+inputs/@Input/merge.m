function Xinput = merge(Xinput,Xobj)
%MERGE This method merges 2 objects of type Input.
%
%  See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Merge@Input
%
%   Usage:  Xi  = Xobj.merge(Xobj2)
%           Xi  = Xobj.add(Xparameter,Xrvset)
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 

%% Processing Inputs
assert(isa(Xobj,'opencossan.common.inputs.Input'), ...
    'openCOSSAN:Inputs:merge', ...
    'An object of type Input is required, provided object type %s', ...
    class(Xobj))

CoriginalNames=Xinput.Names;

%% Process Parameters
Vexcluded=ismember(Xobj.ParameterNames,Xinput.ParameterNames);
Cnames=Xobj.ParameterNames;

if any(Vexcluded)
    warning('openCOSSAN:Inputs:merge','The following Parameter will not be merged: \n%s',...
        sprintf('"%s" ',Cnames{Vexcluded}))
    Cnames(Vexcluded)=[]; % Names of the RandomVariableSet to be merged
end

for n=1:length(Cnames)
       Xinput.Parameters.(Cnames{n})=Xobj.Parameters.(Cnames{n});
end

%% Process Design Variable
Vexcluded=ismember(Xobj.DesignVariableNames,Xinput.DesignVariableNames);
Cnames=Xobj.DesignVariableNames;

if  any(Vexcluded)
    warning('openCOSSAN:Inputs:merge','The following DesignVariable will not be merged: \n%s',...
        sprintf('"%s" ',Cnames{Vexcluded}))
    Cnames(Vexcluded)=[]; % Names of the RandomVariableSet to be merged
end

for n=1:length(Cnames)
       Xinput.DesignVariables.(Cnames{n})=Xobj.DesignVariables.(Cnames{n});
end

%% Process StochasticProcess
Vexcluded=ismember(Xobj.StochasticProcessNames,Xinput.StochasticProcessNames);
Cnames=Xobj.StochasticProcessNames;

if any(Vexcluded)
    warning('openCOSSAN:Inputs:merge','The following StochasticProcess will not be merged: \n%s',...
        sprintf('"%s" ',Cnames{Vexcluded}))
    Cnames(Vexcluded)=[]; % Names of the RandomVariableSet to be merged
end

for n=1:length(Cnames)
   Xinput.StochasticProcesses.(Cnames{n})=Xobj.StochasticProcesses.(Cnames{n});
end

%% Process Functions
Vexcluded=ismember(Xobj.FunctionNames,Xinput.FunctionNames);
Cnames=Xobj.FunctionNames;

if any(Vexcluded)
    warning('openCOSSAN:Inputs:merge','The following Function will not be merged: \n%s',...
        sprintf('"%s" ',Cnames{Vexcluded}))
    Cnames(Vexcluded)=[]; % Names of the RandomVariableSet to be merged
end


for n=1:length(Cnames)
   Xinput.Functions.(Cnames{n})=Xobj.Functions.(Cnames{n});
end


%% Process RandomVariableSet/GaussianMixture
Vexcluded=ismember(Xobj.RandomVariableSetNames,Xinput.RandomVariableSetNames);
Cnames=Xobj.RandomVariableSetNames;

if any(Vexcluded)
    warning('openCOSSAN:Inputs:merge','The following RandomVariableSet/GaussianMixtureRandomVariableSet will not be merged: \n%s',...
        sprintf('"%s" ',Cnames{Vexcluded}))
    Cnames(Vexcluded)=[]; % Names of the RandomVariableSet to be merged
end

for n=1:length(Cnames)
    % Make merge
    Xinput.RandomVariableSets.(Cnames{n})=Xobj.RandomVariableSets.(Cnames{n});
end


%% Check dublicated names
assert(length(unique(Xinput.Names))==length(Xinput.Names), ...
    'openCOSSAN:Inputs:merge', ...
    strcat('It is not possible to merge the Input objects!\n', ...
    'Receiver object contains the following variables: %s\n', ...
    'The applied object contains the following variables: %s'), ...
    sprintf('"%s" ',CoriginalNames{:}),sprintf('"%s" ',Xobj.Names{:}))



%% Merge Description and remove samples
Xinput.Description=strcat(Xinput.Description,Xobj.Description);
Xinput.Samples=[];

%% Validate Object
checkFunction( Xinput );



