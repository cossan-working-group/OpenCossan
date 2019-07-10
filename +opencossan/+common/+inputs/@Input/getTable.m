function TableOutput = getTable(Xobj)
%GETTABLE This method returns the realizations of the random variables
%and the values of the parameters/Designvariable defined in the Input object.
%
% See Also: http://cossan.co.uk/wiki/index.php/GetTable@Input
%
% Author: Edoardo Patelli 
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

Crv     = Xobj.RandomVariableNames;
Crvsetname  = Xobj.RandomVariableSetNames;
Cfun    = Xobj.FunctionNames;
Cpar    = Xobj.ParameterNames;
Csp     = Xobj.StochasticProcessNames;
CdesignVariable   = Xobj.DesignVariableNames;

%% Validate 
if isempty([Crvsetname Cpar Csp CdesignVariable])
    error('openCOSSAN:input:getStructure',...
        'There are no variables defined');
end

if ~isempty([Crvsetname Csp]) && isempty(Xobj.Samples)
    error('openCOSSAN:input:getStructure',...
        'There are no samples available. \nTo retrieve default values use method getDefaultValuesTable.');
end

Cnames  = [Crv Cfun Cpar Csp CdesignVariable];

if isempty(Xobj.Samples)
    Nsamples=1;
else
    Nsamples    = Xobj.Samples.Nsamples;
end

%% Extract DesignVariable
if isempty(CdesignVariable)
    CdesignVariableValue={};
else
    if isempty(Xobj.Xsamples) || isempty(Xobj.Xsamples.MdoeDesignVariables)
        
        TdesignVariable=get(Xobj,'DesignVariableValues');
        
        % Create a cell array with the values
        % don´t forget to preallocate memory
        
        
        for ipar=1:length(CdesignVariable)
            for isample=1:Nsamples
                CdesignVariableValue{isample,ipar} = TdesignVariable.(CdesignVariable{ipar});
            end
        end
    else
        CdesignVariableValue = num2cell(Xobj.Samples.MdoeDesignVariables);
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
            Cparvalue{isample,ipar} = Xobj.Parameters.(Cpar{ipar}).Value;
        end
    end
    
end

%% Evaluate functions
if isempty(Cfun)
    Cfunvalue = {};
else
    % Return values of the function in a cell array
    Cfunvalue = evaluateFunction(Xobj);
end

%% Extract values of the RandomVariable
if isempty(Crv)
    Crvvalue = {};
else
    Crvvalue =num2cell(Xobj.Samples.MsamplesPhysicalSpace(:,1:Xobj.NrandomVariables));
end


%% Append stochastic processes
if isempty(Csp)
    Cspvalue = {};
else    
    % convert a matrix of Dataseries in a cell array where each element is 
    % a Dataseries containing a single samples
    Xds = Xobj.Xsamples.Xdataseries;
    Cspvalue = cell(Xds(1).Nsamples,size(Xds,2));
    for isample = 1:Nsamples
        Cspvalue(isample,:) = num2cell(Xds(isample,:));
    end
end

% Construct the structure
TableOutput=cell2table([Crvvalue Cfunvalue Cparvalue Cspvalue CdesignVariableValue], ...
    'VariableNames',cellstr(Cnames));
