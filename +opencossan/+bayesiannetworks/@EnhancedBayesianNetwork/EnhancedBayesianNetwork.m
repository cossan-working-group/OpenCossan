classdef EnhancedBayesianNetwork < opencossan.bayesiannetworks.BayesianNetwork
    % ENHANCEDBAYESIANNETWORK construct the object EnhancedBayesianNetwork.
    %   Author: Silvia Tolo
    %   Institute for Risk and Uncertainty, University of Liverpool, UK
    %   email address: openengine@cossan.co.uk
    %   Website: http://www.cossan.co.uk
    
    %   =====================================================================
    %   This file is part of openCOSSAN.  The open general purpose matlab
    %   toolbox for numerical analysis, risk and uncertainty quantification.
    %
    %   openCOSSAN is free software: you can redistribute it and/or modify
    %   it under the terms of the GNU General Public License as published by
    %   the Free Software Foundation, either version 3 of the License.
    %
    %   openCOSSAN is distributed in the hope that it will be useful,
    %   but WITHOUT ANY WARRANTY; without even the implied warranty of
    %   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %   GNU General Public License for more details.
    %
    %   You should have received a copy of the GNU General Public License
    %   along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    properties 
        ObservedNodes   string          % nodes that will receive evidence and need to be kept in the reduced network
        Correlation     double = []     % correlation matrix 
    end
    
    properties (Dependent = true)
        ProbabilisticNodes
        DiscreteNodes
    end
    
    
    methods
        %% constructor
        function obj = EnhancedBayesianNetwork(varargin)
            %ENHANCEDBAYESIANNETWORK Constructor for EnhancedBayesianNetwork object.
            
            if nargin == 0
                % Create empty object
                return
            else
                % Process inputs via inputParser
                p = inputParser;
                p.FunctionName = 'opencossan.bayesiannetworks.EnhancedBayesianNetwork';
                
                % Class properties
                %p.addParameter('Description',obj.Description);
                p.addParameter('Nodes',obj.Nodes);
                p.addParameter('ObservedNodes',obj.ObservedNodes);
                p.addParameter('Correlation',obj.Correlation);

                p.parse(varargin{:});
                
                % Assign input to objects properties
                %obj.Description = p.Results.Description;
                obj.Nodes           = p.Results.Nodes;
                obj.ObservedNodes   = p.Results.ObservedNodes;
                obj.Correlation   = p.Results.Correlation;
            end
        end
        
        function DiscreteNodes = get.DiscreteNodes(obj)
            DiscreteNodes=obj.NodesNames(arrayfun(@(s)isa(s,'opencossan.bayesiannetworks.DiscreteNode'),obj.Nodes));
        end
        
        function ProbabilisticNodes = get.ProbabilisticNodes(obj)
            ProbabilisticNodes=obj.NodesNames(arrayfun(@(s)isa(s,'opencossan.bayesiannetworks.ProbabilisticNode'),obj.Nodes));
        end     
        
        % Methods
%       varargout       = introduceEvidence(obj,varargin);   % TODO
        varargout       = discretizeProbabilisticNode(obj,varargin);        % discretize node
        varargout       = reduce2BN(obj,varargin);             % reduce to BayesianNetwork
        varargout       = computeProbabilisticNodes(obj,varargin); %compute non-discrete nodes children of a least one non-discrete parent
    end %of public methods
    
    
    %% Private methods
    methods (Hidden=true)
        function setNode4Graph(obj,graphObj)
            MaxSizeDiscrete=max(strlength(obj.DiscreteNodes))*45;
            set(graphObj.nodes(ismember(obj.NodesNames,obj.DiscreteNodes)),'Shape','rectangle','Color',[0.5, 0.69, 0.5],'LineColor',[0.5, 0.69, 0.5],'Size',[MaxSizeDiscrete, MaxSizeDiscrete/4]);
            set(graphObj.nodes(ismember(obj.NodesNames,obj.ProbabilisticNodes)),'Shape','circle','Color',[0.79, 0.68, 0.07],'LineColor',[0.79, 0.68, 0.07]);
        end
        varargout   = probabilisticInput(obj, varargin)  % builds the input obj for the reliability analysis
        varargout   = buildNewCrispNodes(obj,varargin)   % build new nodes object from the results of the reliability analysis
        varargout   = probabilisticSRM(obj,varargin);    % method called in reduce2BN to solve the probabilistic problem
        varargout   = barrenNodes(obj);                  % identifies barren nodes
        varargout   = nodes2compute(obj,varargin)        % identifies discrete nodes to compute thorugh reliability analysis        
        varargout   = defineMenvelope(varargin)          % identify Markov envelope
    end
    
end




