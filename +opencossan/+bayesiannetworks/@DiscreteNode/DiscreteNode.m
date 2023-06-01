classdef DiscreteNode < opencossan.bayesiannetworks.Node 
    % DISCRETENODE construct the object DiscreteNode class to be included
    % in BayesianNetwork/EnhancedBayesianNetwork/CredalNetwork objects.
    % The CPD can contatin crisp or interval probabilities
    % Pay attention to the structure of the CPD!!!
    % This is best explained by example.
    % Consider the following directed acyclic graph
    %
    %     C
    %   /   \
    %  R     S
    %   \   /
    %     W
    %
    % where all arcs point down.
    % When we create the CPD for node W, we consider S as its first parent, and R as its
    % second, and hence write
    %
    %      S R W
    % CPD1{1,1,:} = [1.0 0.0];
    % CPD1{2,1,:} = [0.2 0.8];  % P(W=1 | R=1, S=2) = 0.2
    % CPD1{1,2,:} = [0.1 0.9];
    % CPD1{2,2,:} = [0.01 0.99];
    % Or in case of objects (RVs or BVs)
    % CPD1{1,1,:} = Xrv1;
    % CPD1{2,1,:} = Xrv2;  % Pdf(W | R=1, S=2) = Xrv2
    % CPD1{1,2,:} = Xrv3;
    % CPD1{2,2,:} = Xrv4;
    % THE ORDER OF THE PARENTS' NAMES IN CSPARENTS HAS TO BE RESPECTED IN
    % THE DEFINITION OF CPD
    %
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
        Values          % Parameter values associated with states
    end     
    properties (Dependent = true, SetAccess = protected)
        Lpar            % Flag for parameter value

    end   
  
    methods 
        function Size = getNodeSize(obj)
            Size = size(obj.CPD, length(size(obj.CPD)));
        end 
        
        function obj  = DiscreteNode(varargin)
            %DISCRETENODE Constructor for DiscreteNode object.

            if nargin == 0
                % Create empty object
                return
            else
                % Process inputs via inputParser
                node = inputParser;
                node.FunctionName = 'opencossan.bayesiannetworks.DiscreteNode';
                
                % Abstract Class properties
%                 node.addParameter('Description',obj.Description);
                % TOADD DESCRIPTION WHEN WE FIX DISPLAY FOR HETEROGENOUS
                % CLASSES
                node.addParameter('Name',obj.Name);
                node.addParameter('Parents',obj.Parents);
                node.addParameter('CPD',obj.CPD);
                node.addParameter('StateBounds',obj.StateBounds);
                node.addParameter('Values',obj.Values); 

                node.parse(varargin{:});
                
                % Assign input to objects properties
%                 obj.Description = node.Results.Description;
                obj.Name        = node.Results.Name;
                obj.Parents     = node.Results.Parents;
                obj.CPD         = node.Results.CPD;
                obj.StateBounds = node.Results.StateBounds;
                obj.Values      = node.Results.Values;
            end
        end
        
        % methods for dependent properties

        
        function Lpar = get.Lpar(obj)
            if ~isempty(obj.Values)
                Lpar = 1;
            else
                Lpar = 0;
            end
        end
        
    end
    
end