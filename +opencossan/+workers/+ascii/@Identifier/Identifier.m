classdef Identifier < opencossan.common.CossanObject
    % class Identifier
    %
    % Objects of the class Identifier contains information for Injector to
    % find data to inject. The properties of the Identifier objects can be
    % populated by scanning an ASCII input file that contains COSSAN
    % identifier (see Injector for additional information)
    
    %{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2020 COSSAN WORKING GROUP

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
        Name(1,:) char                    % Name of the associate COSSAN variable quantity (can be an input or an output of a worker)
        Index(1,1) double                 % Index of the variable (only for vector and matrix)
        FieldFormat(1,1) string           % Format string '%' +  Maximum field width + conversion character (see fscanf for more information)
        Position(1,1) double              % Absolute position inside the input file
        OriginalString(1,1) string        % Original text in the ASCII file
    end
    
    properties (Dependent=true)
        OriginalValue                     % Original value of the identifier
    end
    
    methods
        function obj = Identifier(varargin)
            % IDENTIFIER
            
            %% Process inputs
            if nargin == 0
                super_args={};
            else
                [required, super_args] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["name", "index", "fieldformat", "originalstring", "position"], varargin{:});
            end
            
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.Name = required.name;
                obj.Index = required.index;
                obj.FieldFormat = required.fieldformat;
                obj.OriginalString = required.originalstring;
                obj.Position = required.position;
            end
                        
        end %end constructor
        
        function Noriginal = get.OriginalValue(obj)
            
            import opencossan.common.utilities.*
            % convert the string to a number. The function mystr2double is
            % used to convert also number in nastran format.
            Noriginal = mystr2double(obj.OriginalString);
        end
        
        replaceValues(obj,varargin) % replace the value of the injection quantities in the file
    end
    
end
