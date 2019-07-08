function Tout = getStructure(Xinput)
%GETSTRUCTURE This method returns the realizations of the random variables
%and the values of the parameters/Designvariable defined in the Input object.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/GetStructure@Input
%
% ==============================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% ==============================================================================      
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli Pierre Beaurepaire

Crv     = Xinput.CnamesRandomVariable;
Cin     = Xinput.CnamesIntervalVariable;
Crvsetname  = Xinput.CnamesSet;
CboundedSet = Xinput.CnamesBoundedSet;
Cfun    = Xinput.CnamesFunction;
Cpar    = Xinput.CnamesParameter;
Csp     = Xinput.CnamesStochasticProcess;
CdesignVariable   = Xinput.CnamesDesignVariable;

%% Validate 
if isempty([Crvsetname CboundedSet Cpar Csp CdesignVariable])
    error('openCOSSAN:input:getStructure',...
        'There are no variables defined');
end

if ~isempty([Crvsetname Csp]) && isempty(Xinput.Xsamples)
    error('openCOSSAN:input:getStructure',...
        'There are no samples available. To retrieve default values use method getDefaultValuesStructure.');
end

Cnames  = [Crv Cin Cfun Cpar Csp CdesignVariable];

if isempty(Xinput.Xsamples)
    Nsamples=1;
else
    Nsamples    = Xinput.Xsamples.Nsamples;
end

%% Extract DesignVariable
if isempty(CdesignVariable)
    CdesignVariableValue={};
else
    if isempty(Xinput.Xsamples) || isempty(Xinput.Xsamples.MdoeDesignVariables)
        
        TdesignVariable=get(Xinput,'designVariableValue');
        
        % Create a cell array with the values
        % don´t forget to preallocate memory
        
        
        for ipar=1:length(CdesignVariable)
            for isample=1:Nsamples
                CdesignVariableValue{isample,ipar} = TdesignVariable.(CdesignVariable{ipar});
            end
        end
    else
        CdesignVariableValue   = num2cell(Xinput.Xsamples.MdoeDesignVariables);
    end
end


%% Extract parameters
if isempty(Cpar)
    Cparvalue={};
else
    % Create a cell array with the values
    % don´t forget to preallocate memory
    Cparvalue   = cell(Nsamples,length(Cpar));
    
    for ipar=1:length(Cpar)
        for isample=1:Nsamples
            Cparvalue{isample,ipar} = Xinput.Xparameters.(Cpar{ipar}).value;
        end
    end
    
end

%% Evaluate functions
if isempty(Cfun)
    Cfunvalue = {};
else
    % Return values of the function in a cell array
    Cfunvalue = evaluateFunction(Xinput);
end

%% Extract values of the RandomVariable
if isempty(Crv)
    Crvvalue = {};
else
    Crvvalue =num2cell(Xinput.Xsamples.MsamplesPhysicalSpace);
end

%% Extract values of the IntervalVariable
if isempty(Cin)
    Civvalue = {};
else
    Civvalue = num2cell(Xinput.Xsamples.MsamplesEpistemicSpace);
end

%% Append stochastic processes
if isempty(Csp)
    Cspvalue = {};
else    
    % convert a matrix of Dataseries in a cell array where each element is 
    % a Dataseries containing a single samples
    Xds = Xinput.Xsamples.Xdataseries;
    Cspvalue = cell(size(Xds,1),size(Xds,2));
    for isample = 1:Nsamples
        Cspvalue(isample,:) = num2cell(Xds(isample,:));
    end
end

% Construct the structure
Tout=cell2struct([Crvvalue Civvalue Cfunvalue Cparvalue Cspvalue CdesignVariableValue] , Cnames, 2);
