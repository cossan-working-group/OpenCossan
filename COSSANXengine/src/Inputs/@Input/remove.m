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
if isa(Xobject, 'Parameter')
    
    if isfield(Xinput.Xparameters,inputname(iobj+1)),
        Xinput.Xparameters  = rmfield(Xinput.Xparameters,inputname(iobj+1));
        OpenCossan.cossanDisp('Parameter object removed from Input');
    else
        warning('openCOSSAN:Input:remove', ...
            ['The object ' inputname(iobj+1) ' is not present in the Input object']);
    end
    
    % Add empty structure
    if isempty(fieldnames(Xinput.Xparameters)),
        Xinput.Xparameters = struct;     %.null     = '';
    end
 
elseif isa(Xobject, 'DesignVariable')
    
    if isfield(Xinput.XdesignVariable,inputname(iobj+1)),
        Xinput.XdesignVariable  = rmfield(Xinput.XdesignVariable,inputname(iobj+1));
        OpenCossan.cossanDisp('DesignVariable object removed from Input');
    else
        warning('openCOSSAN:Input:remove', ...
            ['The object ' inputname(iobj+1) ' is not present in the Input object']);
    end
    
    % Add empty structure
    if isempty(fieldnames(Xinput.XdesignVariable)),
        Xinput.XdesignVariable = struct;     %.null     = '';
    end
    
elseif isa(Xobject, 'StochasticProcess')
    
    if isfield(Xinput.Xsp,inputname(iobj+1)),
        Xinput.Xsp  = rmfield(Xinput.Xsp,inputname(iobj+1));
        OpenCossan.cossanDisp('StochasticProcess object removed from Xinput');
    else
        warning('openCOSSAN:Xinput:remove', ...
            ['The object ' inputname(iobj+1) ' is not present in the Xinput object']);
    end
    
    % remove the samples if some are present
    if ~isempty(Xinput.Xsamples)
        warning('openCOSSAN:Xinput:remove', ...
            'The samples present in the Xinput object will be removed');
        Xinput.Xsamples     = []; 
    end
    
    
    % Add empty structure
    if isempty(fieldnames(Xinput.Xsp)),
        Xinput.Xsp = struct;     %.null     = '';
    end
       
elseif isa(Xobject, 'RandomVariableSet') ||    isa(Xobject, 'rvsetiid')
    
    if isfield(Xinput.Xrvset,inputname(iobj+1)),
        Xinput.Xrvset   = rmfield(Xinput.Xrvset,inputname(iobj+1));
        OpenCossan.cossanDisp('RandomVariableSet object removed from Input object');
    else
        warning('openCOSSAN:Input:remove', ...
            ['The object ' inputname(iobj+1) ' is not present in the Input object']);
    end
    
    % remove the samples if some are present
    if ~isempty(Xinput.Xsamples)
        warning('openCOSSAN:Xinput:remove', ...
            'The samples present in the Xinput object will be removed');
        Xinput.Xsamples     = []; 
    end
    
    % Add empty structure
    if isempty(fieldnames(Xinput.Xrvset)),
        Xinput.Xrvset = struct;     %.null  = '';
    end
    
    
    
elseif isa(Xobject, 'Function')
    
    if isfield(Xinput.Xfunctions,inputname(iobj+1)),
        Xinput.Xfunctions   = rmfield(Xinput.Xfunctions,inputname(iobj+1));
        OpenCossan.cossanDisp('Function object removed from Input');

    else
        warning('openCOSSAN:Input:remove', ...
            ['The object ' inputname(iobj+1) ' is not present in the Input object']);
    end
    
    % Add null field
    if isempty(fieldnames(Xinput.Xfunctions)),
        Xinput.Xfunctions = struct;     %.null  = '';
    end
    
elseif isa(Xobject, 'Samples'),
    
%     Xinput.Xsamples     = [];
     error('openCOSSAN:Input:remove','The second argument MUST BE a Parameter/Function or an rvset object');

else
    error('openCOSSAN:Input:remove','The second argument MUST BE a Parameter/Function or an rvset object');
    
end
end
if Xinput.LcheckFunctions
    checkFunction( Xinput );
end
return