classdef HybridNode < opencossan.bayesiannetworks.Node
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
        Mapping (1,3)cell  % 
    end

    methods
        function Size = getNodeSize(obj)
            Size = size(obj.CPD, length(size(obj.CPD)));
        end 
        
    function obj  = HybridNode(varargin)
        
        %HYBRIDNODE Constructor for HybridNode object.

            if nargin == 0
                % Create empty object
                return
            else
                % Process inputs via inputParser
                node = inputParser;
                node.FunctionName = 'opencossan.bayesiannetworks.HybridNode';
                
                % Class properties
                node.addParameter('Name',obj.Name);
                node.addParameter('Parents',obj.Parents);
                node.addParameter('CPD',obj.CPD);
                node.addParameter('Mapping',obj.CPD);

                node.parse(varargin{:});
                
                % Assign input to objects properties
                obj.Name    = node.Results.Name;
                obj.Parents = node.Results.Parents;
                obj.CPD     = node.Results.CPD;
                obj.Mapping = node.Results.Mapping;
            end
        end
        [CXNewNode,Vbounds] = discretize(obj,varargin)     % TODO discretize hybrid node
        varargout           = computeBounds(obj, varargin) % defines bounds for the discretization process
    end
    
end