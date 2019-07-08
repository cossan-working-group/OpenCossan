classdef ProbabilisticModel
    %PROBABILISTICMODEL COSSAN class to perform reliability analysis
    %   This class define a probabilistic model as a combination of a
    %   physical model (Model) and a performance function (PerformanceFunction).
    %   This class allows to estimate the failure probability associated to the
    %   Probabilistic Model adopting different Simulation objects
    %
    % $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
    % Author: Edoardo Patelli 
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
    properties % Public access
        Sdescription              % Description of the Probabilistic Model
        Xmodel                    % Model Object
        XperformanceFunction      % PerformanceFunction object
    end
    
    properties (Dependent)
        Cinputnames    % Required inputs to evaluate the ProbabilisticModel
        Coutputnames   % Output variables created by the ProbabilisticModel
    end
    
    %% Public Methods
    methods
        display(Xobj)            % Show a summary of the ProbabilisticModel
        
        Xo=apply(Xobj,Pinput)  % Analyse the ProbabilisticModel (perform analysis)
        
        Xo=setGridProperties(Xobj,varargin)   % Add execution details (i.e. Grid configuration)
        
        [Xpf, Xout]=computeFailureProbability(Xobj,Xsimulation)     % Estimate the failure probability
        % associated to the ProbabilisticModel
        
        [XdesignPoint, Xopt]=designPointIdentification(Xobj,varargin) % Estimate the so called
        % "design point" associate to the ProbabilisticModel
        
        [XdesignPoint, Xopt]=HLRF(Xobj,varargin) % Estimate the so called
        % "design point" associate to the ProbabilisticModel
        
        Xo=deterministicAnalysis(Xobj)  % Performe deterministi analysis
        % of the ProbabilisticModel
        
        %Exact line search
        %locate the possible point on the limit state for the simulated directions
        [beta, MPoints, VpfValues] = lineSearch(Xobj,varargin)
        %% constructor
        function Xobj=ProbabilisticModel(varargin)
            %PROBABILISTICMODEL COSSAN class to perform reliability analysis
            %   This class define a probabilistic model as a combination of a
            %   physical model (Model) and a performance function (PerformanceFunction).
            %   This class allows to perform reliability analysis and uncertainty quantification
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@ProbabilisticModel
            %
            % Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
            % Author: Edoardo-Patelli
            
            
            % Check varargin
            OpenCossan.validateCossanInputs(varargin{:})
            
            if nargin==0
                % Create an empty object
                return
            end
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'xmodel'
                        Xobj.Xmodel=varargin{k+1};
                    case 'cxmodel'
                        Xobj.Xmodel=varargin{k+1}{1};
                    case 'xperformancefunction'
                        Xobj.XperformanceFunction=varargin{k+1};
                    case 'cxperformancefunction'
                        Xobj.XperformanceFunction=varargin{k+1}{1};
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case 'cxmembers' % Pass the object by names
                        for imem=1:length(varargin{k+1})
                            Xmem=evalin('base',varargin{k+1}{imem});
                            if isa(Xmem,'Model')
                                Xobj.Xmodel=Xmem;
                            elseif isa(Xmem,'PerformanceFunction')
                                Xobj.XperformanceFunction=Xmem;
                            else
                                error('openCOSSAN:reliability:ProbabilisticModel',...
                                    [' The object (' varargin{k+1}{imem} ' must be a Model or a PerformanceFunction ']);
                            end
                        end
                        
                    otherwise
                        error('openCOSSAN:reliability:ProbabilisticModel',...
                            ['Field name (' varargin{k} ') not allowed']);
                end
            end
            
            % Check Performance Function
            assert(~isempty(Xobj.XperformanceFunction), ...
                'openCOSSAN:reliability:ProbabilisticModel',...
                'PerformanceFunction not defined.');
            
            assert(isa(Xobj.XperformanceFunction,'PerformanceFunction'),...
                'openCOSSAN:reliability:ProbabilisticModel',...
                ['Wrong type of PerformanceFunction ( ' class(Xobj.XperformanceFunction) ')']);
            
            % Check the Model
            if isempty(Xobj.Xmodel)
                warning('openCOSSAN:reliability:ProbabilisticModel',...
                    'Model not defined. ');
            else
                assert(isa(Xobj.Xmodel,'Model')||isa(Xobj.Xmodel,'MetaModel'), ...
                    'openCOSSAN:reliability:ProbabilisticModel',...
                    'Only Model and MetaModel can be used to define a ProbabilisticModel');
            end
        end % End constructor
        
        
        function Cinputnames=get.Cinputnames(Xobj)
            Cinputnames=Xobj.Xmodel.Cinputnames;
        end
        
        function Coutputnames=get.Coutputnames(Xobj)
            % Outputs of the Model
            CoutputModel=Xobj.Xmodel.Coutputnames;
            % Output of the Performance function
            CoutputPerformanceFunction=Xobj.XperformanceFunction.Soutputname;
            Coutputnames=[CoutputModel CoutputPerformanceFunction];
        end
        
    end % End methods
    
    %% Private Method
    methods (Access=private)
        Xop=prepareOptimizationProblem(Xpm,Mu0) % Transform a Probabilistic Model into a Optimization Model
    end
    
end % End classdef

