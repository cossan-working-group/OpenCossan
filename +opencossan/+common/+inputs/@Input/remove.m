function Xinput = remove(Xinput,varargin)
%REMOVE   Removes the Xrvset/Xparametes/Xfunction/Xrv from the object Xinput
%
%   MANDATORY ARGUMENTS:
%       Xinput              The Input object (mandatory)
%   
%   OPTIONNAL ARGUMENTS:
%       Xrvset              The rvset object to remove
%       Xparameters         The parameters object to remove
%       XDesignVariable     The design variable object to remove
%       Xfunction           The parameters object to remove
%       Xamples             The Sample object to remove
%       StochasticProcess   The StochasticProcess object to remove
%
%
%   OUTPUT ARGUMENT
%        Xinput             Input object (where the objects(s) have been removed)
%
%  
%
%   Usage:  Xi  = remove(Xi,Xrvset)
%           Xi  = remove(Xi,Xparameter)
%
%   see also: RandomVariable, RandomVariableSet, Input, Parameter, StochasticProcess

%% 1. Processing Inputs
for iobj=1:length(varargin)
    Xobject=varargin{iobj};
% Check inputs
if isa(Xobject, 'opencossan.common.inputs.Parameter')
    
    if isfield(Xinput.Parameters,inputname(iobj+1))
        Xinput.Parameters  = rmfield(Xinput.Parameters,inputname(iobj+1));
        opencossan.OpenCossan.cossanDisp('Parameter object removed from Input');
    else
        warning('openCOSSAN:Input:remove', ...
            ['The object ' inputname(iobj+1) ' is not present in the Input object']);
    end
    
    % Add empty structure
    if isempty(fieldnames(Xinput.Parameters))
        Xinput.Parameters = struct;     %.null     = '';
    end
 
elseif isa(Xobject, 'opencossan.optimization.DesignVariable')
    
    if isfield(Xinput.XdesignVariable,inputname(iobj+1))
        Xinput.DesignVariables  = rmfield(Xinput.DesignVariables,inputname(iobj+1));
        opencossan.OpenCossan.cossanDisp('DesignVariable object removed from Input');
    else
        warning('openCOSSAN:Input:remove', ...
            ['The object ' inputname(iobj+1) ' is not present in the Input object']);
    end
    
    % Add empty structure
    if isempty(fieldnames(Xinput.DesignVariables))
        Xinput.DesignVariables = struct;     %.null     = '';
    end
    
elseif isa(Xobject, 'opencossan.common.inputs.StochasticProcess')
    
    if isfield(Xinput.Xsp,inputname(iobj+1))
        Xinput.StochasticProcesses  = rmfield(Xinput.StochasticProcesses,inputname(iobj+1));
        opencossan.OpenCossan.cossanDisp('StochasticProcess object removed from Xinput');
    else
        warning('openCOSSAN:Xinput:remove', ...
            ['The object ' inputname(iobj+1) ' is not present in the Xinput object']);
    end
    
    % remove the samples if some are present
    if ~isempty(Xinput.Samples)
        warning('openCOSSAN:Xinput:remove', ...
            'The samples present in the Xinput object will be removed');
        Xinput.Samples     = []; 
    end
    
    
    % Add empty structure
    if isempty(fieldnames(Xinput.StochasticProcesses))
        Xinput.StochasticProcesses = struct;     %.null     = '';
    end
       
elseif isa(Xobject, 'opencossan.common.inputs.RandomVariableSet') ||    isa(Xobject, 'rvsetiid')
    
    if isfield(Xinput.RandomVariableSets,inputname(iobj+1))
        Xinput.RandomVariableSets   = rmfield(Xinput.RandomVariableSets,inputname(iobj+1));
        opencossan.OpenCossan.cossanDisp('RandomVariableSet object removed from Input object');
    else
        warning('openCOSSAN:Input:remove', ...
            ['The object ' inputname(iobj+1) ' is not present in the Input object']);
    end
    
    % remove the samples if some are present
    if ~isempty(Xinput.Samples)
        warning('openCOSSAN:Xinput:remove', ...
            'The samples present in the Xinput object will be removed');
        Xinput.Samples     = []; 
    end
    
    % Add empty structure
    if isempty(fieldnames(Xinput.RandomVariableSets))
        Xinput.RandomVariableSets = struct;     %.null  = '';
    end
    
    
    
elseif isa(Xobject, 'opencossan.common.inputs.Function')
    
    if isfield(Xinput.Functions,inputname(iobj+1))
        Xinput.Functions   = rmfield(Xinput.Functions,inputname(iobj+1));
        opencossan.OpenCossan.cossanDisp('Function object removed from Input');

    else
        warning('openCOSSAN:Input:remove', ...
            ['The object ' inputname(iobj+1) ' is not present in the Input object']);
    end
    
    % Add null field
    if isempty(fieldnames(Xinput.Functions))
        Xinput.Functions = struct;     %.null  = '';
    end
    
elseif isa(Xobject, 'opencossan.common.Samples')
    
%     Xinput.Xsamples     = [];
     error('openCOSSAN:Input:remove','The second argument MUST BE a Parameter/Function or a RandomVariableSet object');

else
    error('openCOSSAN:Input:remove','The second argument MUST BE a Parameter/Function or an RandomVariableSet object');
    
end
end
if Xinput.DoFunctionsCheck
    checkFunction( Xinput );
end
return