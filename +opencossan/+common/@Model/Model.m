classdef Model < opencossan.common.CossanObject
    % Model This class defines the model composed by an Input object and an
    % Evaluator object.
    % See also: https://cossan.co.uk/wiki/index.php/@Model
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    properties
        Input(1,1) opencossan.common.inputs.Input    % Input object
        Evaluator(1,1) opencossan.workers.Evaluator  % Evaluator object
    end
    
    properties (Dependent=true)
        InputNames    % Names of the output variables
        OutputNames   % Names of the input variables
    end
    
    methods
        function obj = Model(varargin)
            %MODEL Construct a new Model object
            
            if nargin == 0
                super_args = {};
            else
                [required, super_args] = ...
                    opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["input", "evaluator"], varargin{:});
            end
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.Input = required.input;
                obj.Evaluator = required.evaluator;
                
                % Check that all names required by the evaluator are
                % present in the input
                assert(all(ismember(obj.Evaluator.Cinputnames,...
                    obj.InputNames)),'OpenCossan:Model:MissingInputs',...
                    'The Input object must contain all inputs required by the Evaluator: ''%s''', ...
                    strjoin(obj.Evaluator.Cinputnames,''', '''));
            end
        end
        
        output = apply(obj, Pinput);                % Evaluate the Model
        output = deterministicAnalysis(obj);        % Perform deterministic analysis
        obj = setGridProperties(obj, varargin);     % Add execution details (i.e. Grid configuration)
        
        function names = get.OutputNames(obj)
            names = obj.Evaluator.Coutputnames;
        end
        
        function names = get.InputNames(obj)
            names = obj.Input.InputNames;
        end
    end
end
