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
assert(isa(Xobj,'Input'), ...
    'openCOSSAN:Inputs:merge', ...
    'An object of type Input is required, provided object type %s', ...
    class(Xobj))

CoriginalNames=Xinput.Cnames;

%% Process Parameters
Vexcluded=ismember(Xobj.CnamesParameter,Xinput.CnamesParameter);
Cnames=Xobj.CnamesParameter;

if any(Vexcluded)
    warning('openCOSSAN:Inputs:merge','The following Parameter will not be merged: \n%s',...
        sprintf('"%s" ',Cnames{Vexcluded}))
    Cnames(Vexcluded)=[]; % Names of the RandomVariableSet to be merged
end

for n=1:length(Cnames)
       Xinput.Xparameters.(Cnames{n})=Xobj.Xparameters.(Cnames{n});
end

%% Process Design Variable
Vexcluded=ismember(Xobj.CnamesDesignVariable,Xinput.CnamesDesignVariable);
Cnames=Xobj.CnamesDesignVariable;

if  any(Vexcluded)
    warning('openCOSSAN:Inputs:merge','The following DesignVariable will not be merged: \n%s',...
        sprintf('"%s" ',Cnames{Vexcluded}))
    Cnames(Vexcluded)=[]; % Names of the RandomVariableSet to be merged
end

for n=1:length(Cnames)
       Xinput.XdesignVariable.(Cnames{n})=Xobj.XdesignVariable.(Cnames{n});
end

%% Process StochasticProcess
Vexcluded=ismember(Xobj.CnamesStochasticProcess,Xinput.CnamesStochasticProcess);
Cnames=Xobj.CnamesStochasticProcess;

if any(Vexcluded)
    warning('openCOSSAN:Inputs:merge','The following StochasticProcess will not be merged: \n%s',...
        sprintf('"%s" ',Cnames{Vexcluded}))
    Cnames(Vexcluded)=[]; % Names of the RandomVariableSet to be merged
end

for n=1:length(Cnames)
   Xinput.Xsp.(Cnames{n})=Xobj.Xsp.(Cnames{n});
end

%% Process Functions
Vexcluded=ismember(Xobj.CnamesFunction,Xinput.CnamesFunction);
Cnames=Xobj.CnamesFunction;

if any(Vexcluded)
    warning('openCOSSAN:Inputs:merge','The following Function will not be merged: \n%s',...
        sprintf('"%s" ',Cnames{Vexcluded}))
    Cnames(Vexcluded)=[]; % Names of the RandomVariableSet to be merged
end


for n=1:length(Cnames)
   Xinput.Xfunctions.(Cnames{n})=Xobj.Xfunctions.(Cnames{n});
end


%% Process RandomVariableSet/GaussianMixture
Vexcluded=ismember(Xobj.CnamesSet,Xinput.CnamesSet);
Cnames=Xobj.CnamesRandomVariableSet;

if any(Vexcluded)
    warning('openCOSSAN:Inputs:merge','The following RandomVariableSet/GaussianMixtureRandomVariableSet will not be merged: \n%s',...
        sprintf('"%s" ',Cnames{Vexcluded}))
    Cnames(Vexcluded)=[]; % Names of the RandomVariableSet to be merged
end

for n=1:length(Cnames)
    % Make merge
    Xinput.Xrvset.(Cnames{n})=Xobj.Xrvset.(Cnames{n});
end


%% Check dublicated names
assert(length(unique(Xinput.Cnames))==length(Xinput.Cnames), ...
    'openCOSSAN:Inputs:merge', ...
    strcat('It is not possible to merge the Input objects!\n', ...
    'Receiver object contains the following variables: %s\n', ...
    'The applied object contains the following variables: %s'), ...
    sprintf('"%s" ',CoriginalNames{:}),sprintf('"%s" ',Xobj.Cnames{:}))



%% Merge Description and remove samples
Xinput.Sdescription=strcat(Xinput.Sdescription,Xobj.Sdescription);
Xinput.Xsamples=[];

%% Validate Object
checkFunction( Xinput );



