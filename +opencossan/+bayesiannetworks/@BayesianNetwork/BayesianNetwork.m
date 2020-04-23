classdef BayesianNetwork < opencossan.common.CossanObject
    % BAYESIANNETWORK construct the object BayesianNetwork.
    %   MANDATORY ARGUMENTS
    %   - Nodes          Cellarray of nodes objects
    %
    %   EXAMPLE:
    %
    %  BN = BayesianNetwork('Sdescription','Burglar alarm example',...
    %           'Nodes',{XE, XB, XR, XA, XC});
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
    
    
    properties %Public access
        Nodes opencossan.bayesiannetworks.Node  % Cellarray of node objects
    end
    
    properties (Dependent = true)
        Nnodes              % Number of nodes
        NodesNames          % Name of nodes
        TopologicalOrder    % Topological order of nodes (parents before children)
        ParentNodes         % Cell of Parent nodes
        Roots               % Name of root nodes
        ChildNodes          % Cell of Child nodes
        CPDs                % Cellarray of nodes CPDs
        NodesSize           % Vector of nodes size
        DAG                 % Adjacency matrix        
    end
    
    
    methods
        %% constructor
        function obj = BayesianNetwork(varargin)
            %BAYESIANNETWORK Constructor for BayesianNetwork object.
            
            if nargin == 0
                % Create empty object
                return
            else
                % Process inputs via inputParser
                
                p = inputParser;
                p.FunctionName = 'opencossan.bayesiannetworks.BayesianNetwork';
                
                % Class properties
%                 p.addParameter('Description',obj.Description);
                p.addParameter('Nodes',obj.Nodes);
                
                p.parse(varargin{:});
                
                % Assign input to objects properties
%                 obj.Description = p.Results.Description;
                obj.Nodes = p.Results.Nodes;
            end
        end
        
        function Nnodes = get.Nnodes(obj)
            Nnodes = length(obj.Nodes);
        end
        
        function NodesNames = get.NodesNames(obj)
            NodesNames=[obj.Nodes.Name];
        end
        
        function TopologicalOrder = get.TopologicalOrder(obj)
            TopologicalOrder=graphtopoorder(sparse(obj.DAG));
        end
        
        function ParentNodes = get.ParentNodes(obj)
            ParentNodes={obj.Nodes.Parents};
        end
        
        function ChildNodes = get.ChildNodes(obj)
            ChildNodes=cell(1,obj.Nnodes);
            for inode=1:obj.Nnodes
                ChildNodes{inode} = obj.NodesNames(obj.DAG(inode,:)==1);                
            end
        end
        
        function CPDs = get.CPDs(obj)
            CPDs=getCPDs(obj);
        end
        
        function CPDs = getCPDs(obj)
            CPDs={obj.Nodes.CPD};
        end
        
        function NodesSize = get.NodesSize(obj)
            NodesSize=[obj.Nodes.Size];
        end
        
        function Roots = get.Roots(obj)
            Roots=obj.NodesNames(logical([obj.Nodes.Lroot]));
        end
                      
        function DAG= get.DAG(obj)
          
            
            DAG=zeros(obj.Nnodes);
            for inode=1:obj.Nnodes
                if ~isempty(obj.ParentNodes{inode})
                    [~,iparents]=intersect(obj.NodesNames,obj.ParentNodes{inode},'stable');
                    DAG(iparents,inode) =1;
                end
            end
            % Check the object is an acyclic graph
            assert(graphisdag(sparse(DAG)),...
                'openCOSSAN:BayesianNetwork:BayesianNetwork',...
                'Graph must be acyclic')
        end
                 
 
    % Methods
    makeGraph(obj);                                        % Graphical visualization of the net
    obj             = introduceEvidence(obj,varargin);     % introduce evidence
    obj             = removeNodes(obj,varargin);           % remove node from the net
    obj             = addNodes(obj,varargin);              % add node to the net
    varargout       = computeBNInference(obj,varargin)
    
end %of public methods

%% Private methods
methods (Hidden=true)
    function setNode4Graph(~,graphObj)
        set(graphObj.nodes,'Shape','rectangle','Color',[0.5, 0.69, 0.5],'LineColor',[0.5, 0.69, 0.5]);
    end
    varargout           = useBNT(obj,varargin);                 % links to BayesToolbox for matlab for the inference computation
    TbucketBig          = combinePotentials(obj,varargin);
    varargout           = computeMarginal(obj,varargin)
    varargout           = marginalizeJointP(obj,varargin)
    varargout           = computeJointProbability(obj,varargin)
    varargout           = isConnected(obj,varargin)            % check if the net is connected
    varargout           = computeInferenceBNT(obj,varargin)
    varargout           = markovBlanket(obj,varargin)
end

end




