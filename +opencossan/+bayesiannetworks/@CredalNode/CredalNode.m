classdef CredalNode < opencossan.bayesiannetworks.Node 
    % CREDALNODE constructs the object CredalNode class to be included
    % in CredalNetwork objects.
    % The CPD contains interval probabilities
    % Pay attention to the structure of the CPD!!!
    % See DiscreteNode for an example
    %
    % Author: Silvia Tolo
    % Institute for Risk and Uncertainty, University of Liverpool, UK
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
    
     properties 
        CPDLow          % Lower Bound of Conditional Distribution
        CPDUp           % Upper Bound of Conditional Distribution
     end   
%      
%      properties (Dependent=true, SetAccess = protected)
%         Size
%      end
    
    
    methods 
        function Size = getNodeSize(obj)
            Size = size(obj.CPDLow, length(size(obj.CPDLow)));
        end 
        function obj  = CredalNode(varargin)
            %CREDALNODE Constructor for CREDALNode object.

            if nargin == 0
                % Create empty object
                return
            else
                % Process inputs via inputParser
                node = inputParser;
                node.FunctionName = 'opencossan.bayesiannetworks.CredalNode';
                
                node.addParameter('Name',obj.Name);
                node.addParameter('Parents',obj.Parents);
                node.addParameter('CPDLow',obj.CPDLow);
                node.addParameter('CPDUp',obj.CPDUp);
                node.addParameter('StateBounds',obj.StateBounds);

                node.parse(varargin{:});
                
                % Assign input to objects properties
%                 obj.Description = node.Results.Description;
                obj.Name        = node.Results.Name;
                obj.Parents     = node.Results.Parents;
                obj.CPDLow      = node.Results.CPDLow;
                obj.CPDUp       = node.Results.CPDUp;
                obj.StateBounds = node.Results.StateBounds;
            end
        end
        
        
        
    end
    
end