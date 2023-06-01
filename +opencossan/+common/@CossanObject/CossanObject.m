classdef (Abstract) CossanObject < matlab.mixin.CustomDisplay
    % COSSANOBJECT Base object for any CossanObject
    %   The class contains the description every object should have and
    %   overrides the display header to show that description
    %
    %   COSSANOBJECT Properties:
    %       Description - Description of object
    %    
    %   COSSANOBJECT Methods:
    %       getHeader - Build and return display header text
    %
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
    
    properties
        Description(1,1) string % Description of the object
    end
    
    methods
        function obj = CossanObject(varargin)
            if nargin == 0
                return;
            end
            
            persistent p
            if isempty(p)
                p = inputParser;
                p.addParameter('Description',"");
            end
            
            p.parse(varargin{:});
            
            obj.Description = p.Results.Description;
        end
    end
    
    methods (Access = protected)
        function header = getHeader(obj)
        %GETHEADER Build and return display header text     
            if ~isscalar(obj)
                header = getHeader@matlab.mixin.CustomDisplay(obj);
            else
                header = '%s - Description: %s\n';
                header = sprintf(header,...
                    matlab.mixin.CustomDisplay.getClassNameForHeader(obj),...
                    obj.Description);
            end
        end
    end    
end

