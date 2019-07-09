function Tout = getStructure(Xinput)
%GETSTRUCTURE This method returns the realizations of the random variables
%and the values of the parameters/Designvariable defined in the Input object.
%
% See Also: http://cossan.co.uk/wiki/index.php/GetStructure@Input
%
% Author: Edoardo Patelli Pierre Beaurepaire
% Copyright~1993-2015, COSSAN Working Group, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

% Preload names of dependent fields 
Crv     = Xinput.RandomVariableNames;
Crvsetname  = Xinput.RandomVariableSetNames;
Cfun    = Xinput.FunctionNames;
Cpar    = Xinput.ParameterNames;
Csp     = Xinput.StochasticProcessNames;
CdesignVariable   = Xinput.DesignVariableNames;
Cnames  = cellstr(Xinput.Names);

%% Validate 
assert(Xinput.Ninputs>0,'openCOSSAN:Input:getStructure:noInput',...
        'There are no variables defined in the Input object');

if ~isempty([Crvsetname Csp]) && isempty(Xinput.Samples)
    error('openCOSSAN:Input:getStructure:noSamples',...
        'There are no samples available. To retrieve default values use method getDefaultValuesStructure.');
end

if isempty(Xinput.Samples)
    Nsamples=1;
else
    Nsamples = Xinput.Samples.Nsamples;
end

%% Extract DesignVariable
if isempty(CdesignVariable)
    CdesignVariableValue={};
else
    if isempty(Xinput.Samples) || isempty(Xinput.Samples.MdoeDesignVariables)
        
        TdesignVariable=get(Xinput,'DesignVariableValues');
        
        % Create a cell array with the values
        % don´t forget to preallocate memory
        
        
        for ipar=1:length(CdesignVariable)
            for isample=1:Nsamples
                CdesignVariableValue{isample,ipar} = TdesignVariable.(CdesignVariable{ipar});
            end
        end
    else
        CdesignVariableValue   = num2cell(Xinput.Samples.MdoeDesignVariables);
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
            Cparvalue{isample,ipar} = Xinput.Parameters.(Cpar{ipar}).Value;
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
    Crvvalue =num2cell(Xinput.Samples.MsamplesPhysicalSpace(:,1:Xinput.NrandomVariables));
end


%% Append stochastic processes
if isempty(Csp)
    Cspvalue = {};
else    
    % convert a matrix of Dataseries in a cell array where each element is 
    % a Dataseries containing a single samples
    Xds = Xinput.Samples.Xdataseries;
    Cspvalue = cell(Xds(1).Nsamples,size(Xds,2));
    for isample = 1:Nsamples
        Cspvalue(isample,:) = num2cell(Xds(isample,:));
    end
end

% Construct the structure
Tout=cell2struct([Crvvalue Cfunvalue Cparvalue Cspvalue CdesignVariableValue] , Cnames, 2);
