classdef UncertaintyPropagation
    % UNCERTAINTYPROPAGATION  This class allows defining an object of type
    % UncertatintyPropagation.
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/@UncertaintyPropagation
    %
    % $Author:~Marco~de~Angelis$
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
    
    % Properties
    
    properties (SetAccess = public)
        Sdescription                    % description of optimization problem
        StempPath                       % temporary path where all results from the simulations are stored
        SstatisticalQuantityName        % Statistical quantity of interest (e.g. mean, variance, etc.)
        LwriteTextFiles=false           % if true stores results on a text file
        LdeleteSimulationResults=false  % if true deletes the folders with the simulations results
    end
    
    properties (SetAccess=protected)
        VinitialSolution        % vector of initial values to kick start the optimization
        
        Xmodel                  % Model to be evaluated object
        XprobabilisticModel     % Probabilistic model object
        
        Xsolver                 % Solver of the interval analysis
        Xsimulator              % Method used to estimate statistical quantity
        
        %        NmaxIterations          % maximum number of outer loop iterations
        %        NmaxEvaluations         % maximum number of model (inner) evaluations
        
        %        LkeepFailurePoints=false % store the evaluation points in the (Physical) failure domain
        
        LminMax=false           % Condition for minimization and maximization at the same time (only available for GA)
        
        CdesignMapping          % Names of the variables to be mapped and property name
        
        CXMinMaxOptProblems     % Optimization problem for Min abd Max
    end
    
    properties (SetAccess = private, Hidden = false)
        SstringTxtInnerLoop
        SstringTxtOuterLoop
        
        XinputOriginal          % Original input object (with BoundedSet)
        XinputEquivalent        % Equivalent input object (with RandomVariables)
        XinputMapping           % Input for the mapping (with DesignVariables)
        
        XsolutionSequence       % object containing the solution sequence
    end
    
    properties (Dependent = true, SetAccess = protected)
        Coutputnames            % Names of the generated outputs
        Cinputnames             % Names of the required inputs
        
        CintervalVariableNames  % names of the IntervalVariables
        
        NintervalVariables      % Total number of IntervalVariables/DesignVariables
        NrandomVariables        % Total number of RandomVariables
        
        NrandomVariablesInnerLoop
        NintervalOuterLoop
    end
    
    %%   Methods inherited from the superclass
    methods
        
        display(Xobj)                                   % shows the summary of the Xobj
        
        Xobj=prepareInputs(Xobj)                        % modify inputs to allow for design variables
        Xobj=prepareOptimizationProblem(Xobj)           % create optimization problem objects
        
        Xss=constructSolutionSequence(Xobj)
        
        Xextrema=computeExtrema(Xobj,varargin)           % calculate optima
        varargout=extremize(Xobj,varargin)               % perform min/max search
        
        varargout=validateOptima(Xobj)
        %        Xextrema=extractOptima(Xobj,varargin)               % process the optimum objects
        %        Xextrema=useOptima2refine(Xobj,Xextrema,varargin)   % recompute the failure probabilities on the argument optima
        
        
        function Xobj    = UncertaintyPropagation(varargin)
            %UNCERTAINTYPROPAGATION This method constructs an object of
            %type Uncertainty propagation
            %
            % See Also:
            % http://cossan.cfd.liv.ac.uk/wiki/@UncertaintyPropagation
            %
            % $Author:~Marco~de~Angelis$
            
            %% Construct empty object
            if nargin==0
                return
            end
            
            %% Validate Inputs
            OpenCossan.validateCossanInputs(varargin{:});
            
            %% Process inputs arguments
            for k=1:2:length(varargin),
                switch lower(varargin{k}),
                    %2.1.   Description of the object
                    case 'sdescription'
                        Xobj.Sdescription   = varargin{k+1};
                    case {'xprobabilisticmodel' }
                        assert(or(isa(varargin{k+1},'ProbabilisticModel'),isa(varargin{k+1},'Model')), ...
                            'openCOSSAN:UncertaintyPropagation',...
                            'The object provided after the PropertyName Xprobabilisticmodel is of class %s',class(varargin{k+1}));
                        Xobj.XprobabilisticModel=varargin{k+1};
                    case 'xmodel'
                        assert(isa(varargin{k+1},'Model'), ...
                            'openCOSSAN:UncertaintyPropagation',...
                            'The object provided after the PropertyName Xprobabilisticmodel is of class %s',class(varargin{k+1}));
                        Xobj.Xmodel=varargin{k+1};
                    case 'xsolver'
                        SsuperClass=superclasses(varargin{k+1});
                        assert(strcmpi(SsuperClass,'Optimizer') || strcmpi(SsuperClass,'Simulations') || strcmpi(SsuperClass,'Sensitivity'),...
                            'openCOSSAN:UncertaintyPropagation',...
                            'The object Xsolver must be either of class Optimizer or Simulations or Sensitivity')
                        Xobj.Xsolver=varargin{k+1};
                    case 'xsimulator'
                        SsuperClass=superclasses(varargin{k+1});
                        assert(strcmpi(SsuperClass,'Simulations'), ...
                            'openCOSSAN:UncertaintyPropagation',...
                            'The object provided after the PropertyName Xsimulator is of superclass %s, (it must be of superclass Simulations) ',SsuperClass);
                        Xobj.Xsimulator=varargin{k+1};
                    case 'sstatisticalquantityname'
                        Xobj.SstatisticalQuantityName = varargin{k+1};
                    case {'vinitialsolution','minitialsolution'}
                        Xobj.VinitialSolution = varargin{k+1};
                    case 'lminmax'
                        Xobj.LminMax=varargin{k+1};
                    case 'lwritetextfiles'
                        Xobj.LwriteTextFiles=varargin{k+1};
                    otherwise
                        error('openCOSSAN:UncertaintyPropagation',...
                            ['Field name (' varargin{k} ') is not valid']);
                end
            end
            %% Make sure the specified directories do not exist already
            % if the directory DOES exist return an error
            if isempty(Xobj.StempPath)
                Xobj.StempPath=fullfile(OpenCossan.getCossanWorkingPath,'UncertaintyPropagation#1');
                
                [~,mess]=mkdir(Xobj.StempPath);
                
                if strcmpi(mess,'Directory already exists.')
                    % the directory existed
                    inum=0;
                    while strcmpi(mess,'Directory already exists.')
                        inum=1+inum;
                        Xobj.StempPath=fullfile(OpenCossan.getCossanWorkingPath,['UncertaintyPropagation#',num2str(inum)]);
                        [~,mess]=mkdir(Xobj.StempPath);
                    end
                    rmdir(Xobj.StempPath,'s'); % this directory will be later created if the analysis is performed
                else
                    % the directory did not exist
                    rmdir(Xobj.StempPath,'s'); % this directory will be later created if the analysis is performed
                end
            end
            
            %% Validate Constructor
            assert(~isempty(Xobj.XprobabilisticModel),...
                'openCOSSAN:UncertaintyPropagation', ...
                'A Probabilistic Model is required to define an UncertaintyPropagation analysis')
            
            assert(~isempty(Xobj.Xmodel) || ~isempty(Xobj.XprobabilisticModel),...
                'openCOSSAN:UncertaintyPropagation', ...
                'Either a Model or a Probabilistic Model is required to define the Uncertainty Propagation analysis')
            
            assert(~isempty(Xobj.XprobabilisticModel.Xmodel.Xinput.CnamesIntervalVariable), ...
                'openCOSSAN:UncertaintyPropagation',...
                'The input object must contains at least 1 interval variable')
            
            assert(~isempty(Xobj.SstatisticalQuantityName),...
                'openCOSSAN:UncertaintyPropagation',...
                'The name of the satistical quantity of interest must be specified.')
            
            %% Prepare the input object and do the input mapping
            % This method creates three input objects.
            % The first one is the original input provided by the user.
            % The other two are created for the UncertaintyPropagation,
            %  both with no interval varaibles.
            % The second input object is created replacing the intervals
            % with parameters (fixed values),
            % while the third input object is created replacing the
            % intervals with design varaibles (only design variables here).
            Xobj=Xobj.prepareInputs();
            Xinput1=Xobj.XinputOriginal;
            Xinput2=Xobj.XinputMapping;
            
            %% Set default initial solution
            if isempty(Xobj.VinitialSolution)
                if strcmpi(class(Xobj.Xsolver),'GeneticAlgorithms')
                    % generate initial population
                    Xlhs=LatinHypercubeSampling('Nsamples',Xobj.Xsolver.NPopulationSize);
                    Xsamples=Xlhs.sample('Xinput',Xinput2);
                    MinitialPupulation=Xsamples.MdoeDesignVariables;
                    Xobj.VinitialSolution=MinitialPupulation;
                else
                    CnamesBset=Xinput1.CnamesBoundedSet;
                    iiv=0;
                    for ibset=1:length(CnamesBset)
                        Niv=Xinput1.Xbset.(CnamesBset{ibset}).Niv;
                        VinSolution(iiv+1:iiv+Niv)=Xinput1.Xbset.(CnamesBset{ibset}).VinteriorValues;
                        iiv=iiv+Niv;
                    end
                    Xobj.VinitialSolution= VinSolution;
                end
            else
                assert(length(Xinput1.CnamesIntervalVariable)==size(Xobj.VinitialSolution,2), ...
                    'openCOSSAN:UncertaintyPropagation',...
                    ['The lenght of VinitialSolution (' num2str(size(Xobj.VinitialSolution,2)) ...
                    ') must be equal to the number of interval varibles (' ...
                    num2str(length(Xinput1.CnamesIntervalVariable)) ')' ] )
            end
            
            %% specify precision to store results from the inner loop
            if Xobj.LwriteTextFiles
                s='%1.12e';
                if Xobj.NrandomVariablesInnerLoop == 1
                    Xobj.SstringTxtInnerLoop=['\n ',s];
                else
                    ss=[s,' '];
                    Xobj.SstringTxtInnerLoop=['\n',repmat(ss,1,Xobj.NrandomVariablesInnerLoop-1),s];
                end
                % specify precision to store results from the outer loop
                if Xobj.NintervalOuterLoop == 1
                    Xobj.SstringTxtOuterLoop=['\n ',s];
                else
                    ss=[s,' '];
                    Xobj.SstringTxtOuterLoop=['\n',repmat(ss,1,Xobj.NintervalOuterLoop-1),s];
                end
            end
            %% Construct SolutionSequence object
            Xss=Xobj.constructSolutionSequence();
            Xev=Evaluator('XsolutionSequence',Xss);
            Xobj.XsolutionSequence=Xss;
            Xobj.Xmodel=Model('Xevaluator',Xev,'Xinput',Xobj.XinputMapping);
            
            %% Set up the optimization problem
            % This method sets up the optimization problem for the
            % ExtremeCase analysis.
            Xobj=Xobj.prepareOptimizationProblem();
            
        end     %of constructor
        
        function CintervalVariableNames=get.CintervalVariableNames(Xobj)
            CintervalVariableNames=Xobj.XinputOriginal.CnamesIntervalVariable;
        end
        
        % dependent property
        function NrandomVariablesInnerLoop=get.NrandomVariablesInnerLoop(Xobj)
            % this must be equal to the number of rvs in the original
            % input plus the number of structural intervals
            NrandomVariablesInnerLoop=length(Xobj.XinputEquivalent.CnamesRandomVariable);
        end
        
        % dependent property
        function NintervalOuterLoop=get.NintervalOuterLoop(Xobj)
            % this must be equal to the number of intervals in the original
            % input
            NintervalOuterLoop=length(Xobj.XinputMapping.Cnames);
        end
        
        function Cinputnames = get.Cinputnames(Xobj)
            Cinputnames={};
            % Collect inputs required by the Objective function(s)
            for n=1:length(Xobj.XobjectiveFunction)
                Cinputnames=[Cinputnames Xobj.XobjectiveFunction(n).Cinputnames]; %#ok<AGROW>
            end
            % Collect Inputs required by the model
            if ~isempty(Xobj.Xmodel)
                Cinputnames=[Cinputnames Xobj.Xmodel.Cinputnames];
            end
            % Remove duplicates
            Cinputnames= unique(Cinputnames);
        end
        
        function Coutputnames = get.Coutputnames(Xobj)
            Coutputnames=[];
            %Coutputnames=[Xobj.CobjectiveFunctionNames Xobj.CconstraintsNames];
            if ~isempty(Xobj.Xmodel)
                Coutputnames=[Coutputnames Xobj.Xmodel.Coutputnames];
            elseif ~isempty(Xobj.XobjectiveFunction)
                Coutputnames=[Coutputnames Xobj.XobjectiveFunction.Coutputnames];
            end
        end
        
    end     %of methods
    
end     %of classdef
