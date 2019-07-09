classdef ConvexModel < opencossan.common.Model
    %CONVEXMODEL COSSAN class to perform non-probabilistic reliability analysis
    %   This class define a convex model as combination of a physical model
    %   and a performance function object.
    %   This class allows to estimate the possibility of failure associated to the
    %   ConvexModel adopting several optimization algorithms. The
    %   reliability analysis is carried out adopting from the probabilistic
    %   approach the concept of reliability index.
    %   Please remember that the non-probabilisitc reliability index has not
    %   the same meaning of the probabilistic approach, no probability of
    %   failure can be quantified with the current approach.
    %
    %   See also: ConvexSet
    %
    %   Bibliographic Reference: Jiang et al.,2011
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
    
    %% Properties
    properties (Dependent=true) % Public access
        PerformanceFunctionVariable    % Name of the output of the performance function
        StdDeviationIndicatorFunction   % stdDeviationIndicatorFunction of the Performance Function
    end
    
    %% Public Methods
    methods
        
        [beta, Vp]=computeReliability(Xobj,varargin)    % Estimate the "non-probabilistic design point" and then the possibility of failure
        
        %% constructor
        function obj = ConvexModel(varargin)
            % CONVEXMODEL Constructs a HybridModel object.
            %  obj = HybridModel(PerformanceFunction,varargin)
            %
            % Permitted parameters are:
            %  - Model
            %
            % See also opencossan.common.Model
            
            if nargin==0
                super_args = {};
            else
                p = inputParser;
                p.KeepUnmatched = true;
                p.FunctionName = 'opencossan.reliability.ConvexModel.ConvexModel';
                
                p.addParameter('PerformanceFunction',{},@(x) validateattributes(x,...
                    {'opencossan.reliability.PerformanceFunction','cell'},{'nonempty'}));
                p.addParameter('Model',{},@(x) validateattributes(x,...
                    {'opencossan.common.Model','opencossan.metamodel.MetaModel','cell'},{'nonempty'}));
                
                p.parse(varargin{:});
                
                if isempty(p.Results.PerformanceFunction)
                    error('OpenCossan:ConvexModel:MissingRequiredParameter',...
                        'PerformanceFunction is a required parameter');
                end
                
                super_args = opencossan.common.utilities.parseUnmatchedArguments(p.Unmatched);
                
                if ~isempty(p.Results.Model)
                    if isa(p.Results.Model,'cell')
                        Model = p.Results.Model{1};
                    else
                        Model = p.Results.Model;
                    end
                    
                    super_args{end+1} = 'Xevaluator';
                    super_args{end+1} = Model.Xevaluator;
                    
                    super_args{end+1} = 'Xinput';
                    super_args{end+1} = Model.Xinput;
                end
            end
            
            obj = obj@opencossan.common.Model(super_args{:});
            
            if nargin > 0
                % Add PerformanceFunction to Evaluator
                % This is only for compatibility
                if isa(p.Results.PerformanceFunction,'cell')
                    PerformanceFunction = p.Results.PerformanceFunction{1};
                else
                    PerformanceFunction = p.Results.PerformanceFunction;
                end
                
                if isempty(obj.Xevaluator.CXsolvers)
                    obj.Xevaluator = obj.Xevaluator.add('Xmember',PerformanceFunction);
                else
                    obj.Xevaluator = obj.Xevaluator.add('Xmember',PerformanceFunction,'Sname','N/A','Nslots',Inf,...
                        'Nconcurrent',Inf,'Shostname','localhost','Squeue','','SparallelEnvironment','');
                end
            end
        end
        
        function PerformanceFunctionVariable = get.PerformanceFunctionVariable(obj)
            % Return the name of the output of the performance function
            Ctype = cell(length(obj.Xevaluator.CXsolvers),1);
            for n = 1:length(obj.Xevaluator.CXsolvers)
                Ctype{n} = class(obj.Xevaluator.CXsolvers{n});
            end
            Vindex = ismember(Ctype,'opencossan.reliability.PerformanceFunction');
            PerformanceFunctionVariable = obj.Xevaluator.CXsolvers{Vindex}.Coutputnames{:};
        end
        
        function StdDeviationIndicatorFunction = get.StdDeviationIndicatorFunction(obj)
            % Return the name of the output of the performance function
            Ctype = cell(length(obj.Xevaluator.CXsolvers),1);
            for n = 1:length(obj.Xevaluator.CXsolvers)
                Ctype{n} = class(obj.Xevaluator.CXsolvers{n});
            end
            Vindex = ismember(Ctype,'opencossan.reliability.PerformanceFunction');
            
            StdDeviationIndicatorFunction = obj.Xevaluator.CXsolvers{Vindex}.StdDeviationIndicatorFunction;
        end
        
    end % End public methods
    
    %% Private Method
    methods (Access=private)
        Xop=prepareOptimizationProblem(Xobj,Mu0)               % Transform a Convex Model into a Optimization Model
        [XMCout ,varargout]=computeGradientDeltaSpace(varargin)
    end
    
end % End classdef

