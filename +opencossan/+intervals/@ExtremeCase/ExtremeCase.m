classdef ExtremeCase
    % EXTREMECASE This class is used to define an Extreme Case analysis
    %
    % See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@ExtremeCase
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
    
    
    properties (SetAccess = public)
        VgradientDescend                % gradient computed at first iteration
        VconjugateDirection             % conjugate direction resulting from the analysis (updated during the analysis)
    end
    
    properties (SetAccess = protected)
        Sdescription                    % description of optimization problem
        StempPath                       % temporary path where all results from the simulations are stored
        SexistingResultsPath            % path where previous simulations files are stored
        SfailureProbabilityName         % Name associated to the failure probability
        
        
        XprobabilisticModel             % ProbabilisticModel used to compute the failure probability
        XadaptiveLineSampling           % Adaptive Line Sampling object
        XsolutionSequence               % object containing the solution sequence
        %         Xgradient
        
        XgeneticAlgorithms              % Genetic Algorithm object used if LuseGA is set true
        Xdoe                            % Design of Experiment object used if LuseDoE is set true (optional)
        
        
        %        LiniAsGradAtCentre           =false % condition to initialise the conjugate direction using the gradient computed at the centre of the epistemic space
        LiniAsGradAtFirstRealisation =true  % condition to initialise the conjugate direction using the gradient computed using the first realisation
        LiniUsingMC                  =false % condition to initialise the conjugate direction using Monte Carlo
        LuseExistingDirection        =false % condition to initialise the conjugate direction using an existing direction provided by the user
        
        LuserDefinedConjugateDirection       =false % the search will not be performed: upper and lower bound will be obtained by looking at the sign of the provided direction
        
        LsearchByDoE=false              % condition to use Design of Experiment to explore the epistemic space
        LsearchByGA =false              % condition to use Genetic Algorithms to explore the epistemic sapce
        LsearchByLHS=false              % condition to use Monte Carlo (Latin Hypercube) to perform an euristic search in the epistemic space
        
        LuseMCtoFinalise=false          % condition to finalise the analysis using Monte Carlo to increase accuracy
        
        %        LuseFailPoints  =false          % condition to use points in the failure domain to update the conjugate direction
        %        LuseStatePoints =false          % condition to use the state boundary (limit state) points to update the conjugate direction
        LuseInfoPreviousSimulations=true % use points in the failure domain and on the state boundary to update the conjugate and the important directions
        
        LminMax=false                   % condition is set true if the genetic algorithms search for min and max simultaneously
        
        LdeleteSimulationResults =false % delete automatically generated folders containg results of the simulation
        
        LwriteTextFiles=true            % write partial results on text files, if this is false results will be written on binary files
        
        NiniMCsamples                   % number of MC samples used if condition LuseMCtoInitialise is set true
        NfinMCsamples                   % number of MC samples used to finalise the analysis used if LuseMCtoFinalise is set true
        NlhsSamples                     % number of samples used by LHS to explore the epistemic space
        
        NmaxIterations=Inf              % upper limit to the number of iterations (termination criterion)
        NmaxEvaluations=Inf             % upper limit to the total number of samples (termination criterion)
        
        NmonteCarloSamples              % Number of samples for the final Monte Carlo simulation
        
        CdesignMapping                  % Names of the variables to be mapped and property name
        %         CintervalVariableNames        % Names of the interval variables
        
        
        VinitialRealization             % epistemic realization provided by the user to kick start the analysis
        VexistingDirection              % initial conjugate direction provided by the user
        VuserDefinedConjugateDirection  % conjugate direction provided by the user
        MstandardDeviationCheckPoints   % user defined 
    end
    
    properties (SetAccess = private, Hidden = false)
        SstringTxtInnerLoop
        SstringTxtOuterLoop
        
        XinputMapping
        XinputProbabilistic
        XinputParameters
        XinputOriginal
        Xmodel                          % The model here is a solution sequence
%        CXoptimizationProblem
        CXMinMaxOptProblems
    end
    
    
    properties (Dependent = true, SetAccess = protected)
        Coutputnames                % Names of the generated outputs
        Cinputnames                 % Names of the required inputs
        
        %        CobjectiveFunctionNames     % Names of the objectiveFunction outputs
        
        CnamesIntervalVariable      % names of the IntervalVariables
        NintervalVariables          % Total number of DesignVariable
        
        NrandomVariables
        NrandomVariablesInnerLoop
        NintervalOuterLoop
        
        %         NobjectiveFunctions     % Total number of ObjectiveFunction
    end
    
    %%  Methods inherited from the superclass
    methods
        
        display(Xobj)                                       % show the summary of the object
        
        Xobj=prepareInputs(Xobj)                            % modify inputs to allow for design variables
        Xobj=prepareOptimizationProblem(Xobj)               % create optimization problem objects
        Xss=constructSolutionSequence(Xobj)                 % construct solution sequence
        
        Xextrema=computeExtrema(Xobj,varargin)              % calculate optima and construct the output
        
        varargout=extremize(Xobj,varargin)                  % perform min/max search
        
        varargout=validateOptima(Xobj,varargin)             % perform reliability analysis on definite input values
        
        
        function Xobj = ExtremeCase(varargin)
            % This is the constructor of the class ExtremeCase. Please
            % refer to the documentation to see how the method performs.
            %
            % See Also
            % http://cossan.cfd.liv.ac.uk/wiki/index.php/@ExtremeCase
            %
            % Author:~Marco~de~Angelis
            %% Construct empty object
            if nargin==0
                return
            end
            %% Validate Inputs
            OpenCossan.validateCossanInputs(varargin{:})
            
            %% Process inputs arguments
            for k=1:2:length(varargin),
                switch lower(varargin{k}),
                    case 'sdescription'
                        Xobj.Sdescription   = varargin{k+1};
                    case 'stemppath'
                        Xobj.StempPath=varargin{k+1};
                    case 'sexistingresultspath'
                        Xobj.SexistingResultsPath=varargin{k+1};
                    case 'sfailureprobabilityname'
                        Xobj.SfailureProbabilityName=varargin{k+1};
                    case {'xprobabilisticmodel' 'xmodel'}
                        assert(isa(varargin{k+1},'opencossan.reliability.ProbabilisticModel'), ...
                            'openCOSSAN:ExtremeCase',...
                            ['The object provided after the PropertyName %s',...
                            ' must be a reliability.ProbabilisticModel,',...
                            'while is of class %s'],varargin{k},class(varargin{k+1}));
                        Xobj.XprobabilisticModel=varargin{k+1};
                    case 'xadaptivelinesampling'
                        assert(isa(varargin{k+1},'opencossan.simulations.AdaptiveLineSampling'), ...
                            'openCOSSAN:ExtremeCase',...
                            ['The object provided after the PropertyName %s',...
                            ' must be a  simulations.AdvancedLineSampling,',...
                            'while is of class %s'],varargin{k},class(varargin{k+1}));
                        Xobj.XadaptiveLineSampling=varargin{k+1};
                    case 'xgeneticalgorithms'
                        assert(isa(varargin{k+1},'GeneticAlgorithms'), ...
                            'openCOSSAN:ExtremeCase',...
                            'The object provided after the PropertyName',...
                            'XgeneticAlgorithm must be a GeneticAlgorithms,',...
                            'while is of class %s',class(varargin{k+1}));
                        Xobj.XgeneticAlgorithms=varargin{k+1};
                    case {'xdoe','xdesignofexperiments'}
                        assert(isa(varargin{k+1},'DesignOfExperiments'), ...
                            'openCOSSAN:ExtremeCase',...
                            'The object provided after the PropertyName',...
                            'Xdoe must be a DesignOfExperiments,',...
                            'while is of class %s',class(varargin{k+1}));
                        Xobj.Xdoe=varargin{k+1};
                    case 'liniasgradatfirstrealisation'
                        Xobj.LiniAsGradAtFirstRealisation=varargin{k+1};
                    case 'liniusingmc'
                        Xobj.LiniUsingMC=varargin{k+1};
                    case 'luseexistingdirection'
                        Xobj.LuseExistingDirection=varargin{k+1};
                    case 'lsearchbydoe'
                        Xobj.LsearchByDoE=varargin{k+1};
                    case 'lsearchbyga'
                        Xobj.LsearchByGA=varargin{k+1};
                    case 'lsearchbylhs'
                        Xobj.LsearchByLHS=varargin{k+1};
                    case 'lusemctofinalise'
                        Xobj.LuseMCtoFinalise=varargin{k+1};
                    case 'nmontecarlosamples'
                        Xobj.NmonteCarloSamples=varargin{k+1};
                    case 'luseinfoprevioussimulations'
                        Xobj.LuseInfoPreviousSimulations=varargin{k+1};
                    case 'luserdefinedconjugatedirection'
                        Xobj.LuserDefinedConjugateDirection=varargin{k+1};
                    case 'ldeletesimulationresults'
                        Xobj.LdeleteSimulationResults=varargin{k+1};
                    case 'lwritetextfiles'
                        Xobj.LwriteTextFiles=varargin{k+1};
                    case 'nlhssamples'
                        Xobj.NlhsSamples=varargin{k+1};
                    case 'nmaxiterations'
                        Xobj.NmaxIterations=varargin{k+1};
                    case 'nmaxevaluations'
                        Xobj.NmaxEvaluations=varargin{k+1};
                    case 'ninimcsamples'
                        Xobj.NiniMCsamples=varargin{k+1};
                    case 'nfinmcsamples'
                        Xobj.NfinMCsamples=varargin{k+1};
                    case 'cdesignmapping'
                        Xobj.CdesignMapping=varargin{k+1};
                    case 'vinitialrealization'
                        Xobj.VinitialRealization=varargin{k+1};
                    case 'vexistingdirection'
                        Xobj.VexistingDirection=varargin{k+1};
                    case 'vuserdefinedconjugatedirection'
                        Xobj.VuserDefinedConjugateDirection=varargin{k+1};
                    case 'mstandarddeviationcheckpoints'
                        Xobj.MstandardDeviationCheckPoints=varargin{k+1};
                    otherwise
                        error('openCOSSAN:ExtremeCase',...
                            'PropertyName %s not allowed', varargin{k})
                end
            end
            %% Make sure the specified directories do not exist already
            % if the directory DOES exist DO NOT return an error
            if isempty(Xobj.StempPath)
                Xobj.StempPath=fullfile(OpenCossan.getCossanWorkingPath,'ExtremeCase#1');
                
                [~,mess]=mkdir(Xobj.StempPath);

                if strcmpi(mess,'Directory already exists.')
                    % the directory existed
                    inum=0;
                    while strcmpi(mess,'Directory already exists.')
                        inum=1+inum;
                        Xobj.StempPath=fullfile(OpenCossan.getCossanWorkingPath,['ExtremeCase#',num2str(inum)]);
                        [~,mess]=mkdir(Xobj.StempPath);
                    end
                    rmdir(Xobj.StempPath,'s'); % this directory will be later created if the analysis is performed
                else
                    % the directory did not exist
                    rmdir(Xobj.StempPath,'s'); % this directory will be later created if the analysis is performed
                end
            end
            
            % if the directory DOES NOT exist DO NOT return an error
            [~,mess]=mkdir(Xobj.SexistingResultsPath);
            if strcmpi(mess,'Directory already exists.')
                % ok the directory already existed
            else
                error('openCOSSAN:ExtremeCase',...
                    'The directory where the existing results are stored does not exist!')
            end
            
            lists=dir(Xobj.SexistingResultsPath);
            assert(length(lists)>2,...
                'openCOSSAN:ExtremeCase',...
                'There are no results saved in the directory %s!',Xobj.SexistingResultsPath)
                
          
            
        %% Validate Constructor
        assert(~isempty(Xobj.XprobabilisticModel),...
            'openCOSSAN:ExtremeCase', ...
            'A Probabilistic Model is required to define an ExtremeCase analysis')
        
        assert(~isempty(Xobj.XadaptiveLineSampling),...
            'openCOSSAN:ExtremeCase', ...
            'An Adaptive Line Sampling object is required to define an ExtremeCase analysis')
        
        assert(~isempty(Xobj.XprobabilisticModel.Xinput.CnamesIntervalVariable), ...
            'openCOSSAN:ExtremeCase',...
            'The input object must contains at least 1 interval variable')
        
        assert(~isempty(Xobj.SfailureProbabilityName),...
            'openCOSSAN:ExtremeCase', ...
            'It is necessary to define the name of the failure probability')
        
        % initialisation of conjugate direction
        if Xobj.LiniAsGradAtFirstRealisation+Xobj.LiniUsingMC == 3
            warning('openCOSSAN:ExtremeCase',...
                'Only one initialisation option is required,\n either using Gradient, MonteCarlo or Existing Direction: the conjugate direction will be initialised with the gradient')
            Xobj.LiniUsingMC=false;
        elseif +Xobj.LiniAsGradAtFirstRealisation+Xobj.LiniUsingMC == 2
            warning('openCOSSAN:ExtremeCase',...
                'Only one initialisation option is required,\n either using Gradient, MonteCarlo or Existing Direction: the conjugate direction will be initialised with the gradient')
            Xobj.LiniUsingMC=false;
        elseif Xobj.LiniAsGradAtFirstRealisation+Xobj.LiniUsingMC+Xobj.LuseExistingDirection+Xobj.LuseExistingDirection == 0
            warning('openCOSSAN:ExtremeCase',...
                'The conjugate direction has not been initialised: the gradient will be calulated in SNS at every step of the search')
            % default option
        end
        
        % options for the global search
        if Xobj.LsearchByDoE + Xobj.LsearchByGA + Xobj.LsearchByLHS == 3
            warning('openCOSSAN:ExtremeCase',...
                'Just one option is required to explore the epistemic domain: the search will be performed by LHS')
            Xobj.LsearchByGA=false;
            Xobj.LsearchByDoE=false;
            Xobj.NlhsSamples=100;
        elseif Xobj.LsearchByDoE + Xobj.LsearchByGA + Xobj.LsearchByLHS == 2
            warning('openCOSSAN:ExtremeCase',...
                'Just one option is required to explore the epistemic domain: the search will be performed by LHS')
            Xobj.LsearchByGA=false;
            Xobj.LsearchByDoE=false;
            Xobj.LsearchByLHS=true;
            Xobj.NlhsSamples=100;
        elseif Xobj.LsearchByDoE + Xobj.LsearchByGA + Xobj.LsearchByLHS == 0
            Xobj.LsearchByLHS=true;
            Xobj.NlhsSamples=100;
        end
        
        if Xobj.LuserDefinedConjugateDirection
            assert(~isempty(Xobj.VuserDefinedConjugateDirection),...
                'openCOSSAN:ExtremeCase',...
                'Please provide a conjugate direction')
        end
        
        if Xobj.LuseMCtoFinalise==true
            assert(~isempty(Xobj.NmonteCarloSamples),...
                'openCOSSAN:ExtremeCase',...
                'Provide the number of samples for the MonteCarlo simulation!')
        end
            
        
        %% Create the GA object in case it does not exist
        if Xobj.LsearchByGA && isempty(Xobj.XgeneticAlgorithms)
            XGA=GeneticAlgorithms('NPopulationSize',10,'NStallGenLimit',5,...
                'SMutationFcn','mutationadaptfeasible');
            Xobj.XgeneticAlgorithms=XGA;
        end
        %% 
        %%
        %             % options for updating direction
        %             if Xobj.LuseFailPoints + Xobj.LuseStatePoints == 2
        %                 warning('openCOSSAN:ExtremeCase',...
        %                             'Just one option must be chosen to update the conjugate direction, \n either using failure or limit state points: State points will be used as default option')
        %                 Xobj.LuseStatePoints = true;
        %             elseif Xobj.LuseFailPoints + Xobj.LuseStatePoints == 0
        %                 % in this case an important direction is computed at each
        % %               % iteration
        %             end
        
        %% Prepare the input object and do the input mapping
        % This method creates three input objects. The first one is the
        % original input provided by the user. The other two are
        % created for the ExtremeCase, both with no interval varaibles.
        % The second input object is created replacing the intervals
        % with normal random variables (with interval mean values),
        % while the third input object is created replacing the
        % intervals with design varaibles.
        Xobj=Xobj.prepareInputs();
        Xinput0=Xobj.XinputOriginal;
        Xinput1=Xobj.XinputProbabilistic;
        Xinput2=Xobj.XinputMapping;
        
        %% Set default initial solution
        if isempty(Xobj.VinitialRealization)
            if Xobj.LsearchByGA
                % generate initial population
                Xlhs=LatinHypercubeSampling('Nsamples',Xobj.XgeneticAlgorithms.NPopulationSize);
                Xsamples=Xlhs.sample('Xinput',Xinput2);
                MinitialPupulation=Xsamples.MdoeDesignVariables;
                Xobj.VinitialRealization=MinitialPupulation;
            elseif Xobj.LsearchByDoE
                % initial reliazation is not required
                CnamesBset=Xinput0.CnamesBoundedSet;
                istart=1;
                for ibset=1:length(CnamesBset)
                    Niv=Xinput0.Xbset.(CnamesBset{ibset}).Niv;
                    VinSolution(istart:istart+Niv-1)=Xinput0.Xbset.(CnamesBset{ibset}).VinteriorValues;
                    istart=istart+Niv;
                end
                Xobj.VinitialRealization= VinSolution;
            end
        else
            assert(length(Xinput1.CnamesIntervalVariable)==size(Xobj.VinitialRealization,2), ...
                'openCOSSAN:ExtremeCase',...
                ['The lenght of VinitialSolution (' num2str(size(Xobj.VinitialRealization,2)) ...
                ') must be equal to the number of interval varibles (' ...
                num2str(length(Xinput1.CnamesIntervalVariable)) ')' ] )
        end
        
        %% specify precision to store results from the inner loop
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
        %% Construct SolutionSequence object
        Xss=Xobj.constructSolutionSequence();
        Xev=opencossan.workers.Evaluator('XsolutionSequence',Xss);
        Xobj.XsolutionSequence=Xss;
        Xobj.Xmodel=opencossan.common.Model('Xevaluator',Xev,'Xinput',Xobj.XinputMapping);
        %% Set up the optimization problem
        % This method sets up the optimization problem for the
        % ExtremeCase analysis.
        Xobj=Xobj.prepareOptimizationProblem();
    end     %of constructor
    
    % dependent property
    function NrandomVariablesInnerLoop=get.NrandomVariablesInnerLoop(Xobj)
    % this must be equal to the number of rvs in the original
    % input plus the number of structural intervals
    NrandomVariablesInnerLoop=length(Xobj.XinputProbabilistic.CnamesRandomVariable);
    end
    
    % dependent property
    function NintervalOuterLoop=get.NintervalOuterLoop(Xobj)
    % this must be equal to the number of intervals in the original
    % input
    NintervalOuterLoop=length(Xobj.XinputMapping.Cnames);
    end
    
end     %of methods

end     %of classdef
