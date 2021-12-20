classdef CredalNetwork < opencossan.bayesiannetworks.EnhancedBayesianNetwork
    % ENHANCEDBAYESIANNETWORK construct the object CredalNetwork.
    %
    %
    %
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
    
    
    properties (Dependent = true)
        IntervalNodes
        HybridNodes
        CredalNodes
    end
    
    
    methods
        %% constructor
        function obj = CredalNetwork(varargin)
            %CREDALNETWORK Constructor for EnhancedBayesianNetwork object.
            
            if nargin == 0
                % Create empty object
                return
            else
                % Process inputs via inputParser
                p = inputParser;
                p.FunctionName = 'opencossan.bayesiannetworks.CredalNetwork';
                
                % Class properties
                %p.addParameter('Description',obj.Description);
                p.addParameter('Nodes',obj.Nodes);
                p.addParameter('ObservedNodes',obj.ObservedNodes);

                p.parse(varargin{:});
                
                % Assign input to objects properties
                %obj.Description = p.Results.Description;
                obj.Nodes           = p.Results.Nodes;
                obj.ObservedNodes   = p.Results.ObservedNodes;
            end
        end
        
        
        function CredalNodes = get.CredalNodes(obj)
            CredalNodes=obj.NodesNames(arrayfun(@(s)isa(s,'opencossan.bayesiannetworks.CredalNode'),obj.Nodes));
        end
        
        function CPDs = getCPDs(obj)
            CPDs={obj.Nodes.CPD};
            for iCnode=find(cellfun(@isempty,CPDs))
                CPDs{iCnode}={obj.Nodes(iCnode).CPDLow,obj.Nodes(iCnode).CPDUp};
            end
        end
        
        function IntervalNodes = get.IntervalNodes(obj)
            IntervalNodes=obj.NodesNames(arrayfun(@(s)isa(s,'opencossan.bayesiannetworks.IntervalNode'),obj.Nodes));
        end
        
        function HybridNodes = get.HybridNodes(obj)
            HybridNodes=obj.NodesNames(arrayfun(@(s)isa(s,'opencossan.bayesiannetworks.HybridNode'),obj.Nodes));
        end     
        
        % Methods
        varargout       = discretizeIntervalNode(obj,varargin); % discretize node
        %varargout       = discretizeHybridNode(obj,varargin);   % TODO
        %varargout       = computeHybridNodes(obj,varargin); 
        varargout       = reduceCN(obj,varargin);               % reduce CN
        varargout       = computeIntervalNodes(obj,varargin); 

        
    end %of public methods
    
    %% Static methods
    methods (Static = true)
        [variable_states, variable_data] = read_data(filename, variable);
        [conf_lo, conf_hi] = confidence_box(k, n, c);
        [prob_low, prob_hi] = compute_marginals(states, data, conf);
        [prob_low, prob_hi] = compute_conditionals(parent_states, parent_data, node_states, node_data, conf);
    end
    
    %% Private methods
    methods (Hidden=true)
        function setNode4Graph(obj,graphObj)
            MaxSizeDiscrete=max(strlength(obj.NodesNames))*45;
            NodesNames=obj.NodesNames;
            set(graphObj.nodes(ismember(NodesNames,obj.DiscreteNodes)),'Shape','rectangle','Color',[0.5, 0.69, 0.5],'LineColor',[0.5, 0.69, 0.5],'Size',[MaxSizeDiscrete, MaxSizeDiscrete/4]);
            set(graphObj.nodes(ismember(NodesNames,obj.CredalNodes)),'Shape','rectangle','Color',[0.7, 0.69, 0.6],'LineColor',[0.7, 0.69, 0.6],'Size',[MaxSizeDiscrete, MaxSizeDiscrete/4]);
            set(graphObj.nodes(ismember(NodesNames,obj.ProbabilisticNodes)),'Shape','circle','Color',[0.79, 0.68, 0.07],'LineColor',[0.79, 0.68, 0.07]);
            set(graphObj.nodes(ismember(NodesNames,obj.IntervalNodes)),'Shape','ellipse','Color',[0.79, 0.42, 0.19],'LineColor',[0.79, 0.42, 0.19]);
            set(graphObj.nodes(ismember(NodesNames,obj.HybridNodes)),'Shape','trapezium','Color',[0.34, 0.62, 0.72],'LineColor',[0.34, 0.62, 0.72]);
        end
        varargout   = prepareHybridInput(obj, varargin)     % builds the input obj for the reliability analysis
        varargout   = hybridSRM(varargin);                  % method called in reduce2BN to solve the probabilistic problem        
        varargout   = buildNewImpreciseNodes(obj,varargin); % build new nodes object from the results of the reliability analysis
        varargout   = computeInference(obj,varargin);       % compute the inference over the query variable 
        varargout   = computeInferenceBNT(obj,varargin);    % uses BNToolbox for Matlab
    end
    
end




