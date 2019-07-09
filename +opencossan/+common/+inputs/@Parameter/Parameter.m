classdef Parameter < opencossan.common.CossanObject
    %PARAMETER This class defines an Object of type Parameter
    %
    %   The Parameter object is intended for containing numerical
    %   values. A Parameter object can be then attached to an Input
    %   object.
    %   For more detailed information, see <https://cossan.co.uk/wiki/index.php/@Parameter>.
    %
    %   PARAMETER Properties:
    %       Value - Value(s) of the parameter.
    %       Nelements - Number of elements defined in value.
    
    % ===================================================================== 
    % This file is part of *OpenCossan*: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % *OpenCossan* is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    properties % Public access
        Value {mustBeNumeric}   % Value(s) of the parameter
    end
    
    properties (Dependent)
        Nelements               % Number of elements defined in value
    end
    
    methods
        function obj  = Parameter(varargin)
            %PARAMETER Constructor for parameter object.
            %   Xpar = Parameter(varargin)
            %
            %   Parameters must be assigned as name-value-pairs of the kind
            %   Xpar = Parameter('description', STRING, 'value', VALUE).
            %   DESCRIPTION must be of type string. VALUE must be a numeric
            %   field.
            
            %% Process inputs
            if nargin == 0
                % Create empty object
                return
            else
                % Process inputs via inputParser
                p = inputParser;
                p.FunctionName = 'opencossan.common.inputs.Parameter';
                
                % Use default values
                p.addParameter('Description',obj.Description);
                p.addParameter('Value',obj.Value);
                
                p.parse(varargin{:});
                
                % Assign input to objects properties
                obj.Description = p.Results.Description;
                obj.Value = p.Results.Value;
            end
        end
        
        function Nelements = get.Nelements(obj)
            %GET.NELEMENTS Getter method for dependent field Nelements
            Nelements = numel(obj.Value);
        end
    end
    
    methods (Access = protected)
        function groups = getPropertyGroups(obj)
            %GETPROPERTYGROUPS Prop. groups for disply method
            import matlab.mixin.util.PropertyGroup;
            if ~isscalar(obj)
                propList = {'Description', 'Nelements', 'Value'};
            else
                propList = struct();
                propList.Nelements = obj.Nelements;
                propList.Dimension = size(obj.Value);
                propList.Values = obj.Value(1:obj.Nelements);
            end
            groups = PropertyGroup(propList);
        end
    end
    
end

