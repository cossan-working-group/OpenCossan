classdef IntervalAnalysis
    % INTERVALANALYSIS  This class allows defining an object of type
    % IntervalAnalysis.
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/@IntervalAnalysis
    %
    % $Author:~Marco~de~Angelis$
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
    
    % Properties
    properties (SetAccess=public)
        Sdescription            % description of optimization problem
        SintervalOutputName     % name of the interval output
        VinitialSolution        % vector of the initial solution
        Xmodel                  % Model to be evaluated object
        Xinput                  % Input of the model (original with BoundedSet)
        XobjectiveFunction      % Objective function(s)
        Xmio                    % Matlab input/ouput object
        Xsolver                 % Solver of the interval analysis
        Nsamples                % number of montecarlo samples (SsolverType must be MonteCarlo)
    end
    
    properties (SetAccess=protected)
        StempPath               % temporary path where results are stored
        XinputEquivalent        % equivalent input objects where intervals are replaced with design variables
        CXMinMaxObjFunctions    % Objective functions for Min and Max
        CXMinMaxOptProblems     % Optimization problem for Min abd Max
        CintervalVariableNames  % Names of the interval variables
    end
    
    properties (Dependent = true, SetAccess = protected)
        Coutputnames            % Names of the generated outputs
        Cinputnames             % Names of the required inputs
        CobjectiveFunctionNames % Names of the objectiveFunction outputs
        CconstraintsNames       % Names of the constraint outputs
        CnamesIntervalVariables % names of the IntervalVariables
        NintervalVariables      % Total number of DesignVariable
        NobjectiveFunctions     % Total number of ObjectiveFunction
    end
    %% Methods
    methods
        
        display(Xobj)                               % shows the summary of the Xobj
        
        Xss=constructSolutionSequence(Xobj)
        
        Xobj=prepareOptimizationProblem(Xobj)       % create optimization problem objects
        
        varargout=extremize(Xobj,varargin)          % perform min/max search
        
        varargout=computeExtrema(Xobj,varargin)     % calculate optima
        
        Xextrema=extractOptima(Xobj,varargin)       % process the optimum objects
        
        varargout=validateOptima(Xobj,varargin)     % perform reliability analysis on definite input values
        
        function Xobj    = IntervalAnalysis(varargin)
            %INTERVALANALYSIS This method constructs an object of type IntervalAnalysis
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/@IntervalAnalysis
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
                    case 'xobjectivefunction'
                        assert(isa(varargin{k+1},'ObjectiveFunction'),...
                            'openCOSSAN:IntervalAnalysis',...
                            '%s must be an ObjectiveFunction ',inputname(k+1));
                        Xobj.XobjectiveFunction = varargin{k+1};
                    case {'vinitialsolution','minitialsolutions'}
                        Xobj.VinitialSolution   = varargin{k+1};
                    case 'xmodel'
                        assert(isa(varargin{k+1},'Model'),...
                            'openCOSSAN:IntervalAnalysis',...
                            '%s must be a Model ',inputname(k+1));
                        Xobj.Xmodel   = varargin{k+1};
                    case 'xinput'
                        assert(isa(varargin{k+1},'Input'),...
                            'openCOSSAN:IntervalAnalysis',...
                            '%s must be a Input ',inputname(k+1));
                        Xobj.Xinput   = varargin{k+1};
                    case 'xsolver'
                        Xobj.Xsolver  = varargin{k+1};
                    case 'xmio'
                        assert(isa(varargin{k+1},'Mio'),...
                            'openCOSSAN:IntervalAnalysis',...
                            '%s must be a Matlab Input-Output object: ',inputname(k+1));
                        Xobj.Xmio = varargin{k+1};
                    case 'sintervaloutputname'
                        Xobj.SintervalOutputName = varargin{k+1};
                    case 'nmcsamples'
                        Xobj.Nsamples = varargin{k+1};
                    case 'stemppath'
                        Xobj.StempPath = varargin{k+1};
                    otherwise
                        error('openCOSSAN:IntervalAnalysis',...
                            ['Field name (' varargin{k} ') is not valid']);
                end
            end
            %% Check temporary path existance
            if isempty(Xobj.StempPath)
                Xobj.StempPath=OpenCossan.getCossanWorkingPath;
            end
            %% Validate Constructor
            % Check if the input object contains intervals
            assert(~isempty(Xobj.Xinput.CnamesIntervalVariable), ...
                'openCOSSAN:IntervalAnalysis',...
                'The input object must contains at least 1 interval variable')
            
            % Check if the output names are unique
            Cout=Xobj.CobjectiveFunctionNames;
            
            % Check if the objective function names are unique
            assert(length(Cout)==length(unique(Cout)),...
                'openCOSSAN:IntervalAnalysis', ...
                'The name of the objective functions name must be unique!/n Outputnames: %s',...
                sprintf('\n* "%s"',Cout{:}))
            %% Prepare the Input
            % This method adds an input object to the constructor 
            % containing equivalent design variables
            Xobj=prepareInputObject(Xobj);
            %% Set default initial solution
            if isempty(Xobj.VinitialSolution)
                CnamesBset=Xobj.Xinput.CnamesBoundedSet;
                iiv=0;
                for ibset=1:length(CnamesBset)
                    Niv=Xobj.Xinput.Xbset.(CnamesBset{ibset}).Niv;
                    VinSolution(iiv+1:Niv)=Xobj.Xinput.Xbset.(CnamesBset{ibset}).VinteriorValues;
                    iiv=iiv+Niv;
                end
                Xobj.VinitialSolution= VinSolution;
            else
                assert(length(Xobj.Xinput.CnamesIntervalVariables)==size(Xobj.VinitialSolution,2), ...
                    'openCOSSAN:OptimizationProblem',...
                    ['The lenght of VinitialSolution (' num2str(size(Xobj.VinitialSolution,2)) ...
                    ') must be equal to the number of interval varibles (' ...
                    num2str(length(Xobj.Xinput.CnamesIntervalVariable)) ')' ] )
            end
            %% Prepare the objective function
            if ~isempty(Xobj.Xmodel)
                if isa(Xobj.Xmodel,'ProbabilisticModel')
                    % Interval analysis on a probabilistic model is not
                    % allowed
                    error('openCOSSAN:IntervalAnalysis:IntervalAnalysis',...
                        'An object of class %s is not allowed. Please use UncertaintyPropagation \n if you want to perform interval analysis on the failure probability',...
                        class(Xobj.Xmodel))
                else % in case a Model is provided
                    CoutputName=Xobj.Xmodel.Coutputnames;
                    
                    if isempty(Xobj.SintervalOutputName)
                        Xobj.SintervalOutputName='outIA';
                    end
                    
                    % TODO: loop over all the outputs of the model
                    assert(length(CoutputName)==1,...
                        'openCOSSAN:IntervalAnalysis:IntervalAnalysis',...
                        'Please provide a single output')
                    
                    % name the output of the Interval Analysis
                    Xobj.SintervalOutputName=CoutputName{1};
                    
                    % Create the objective function from the model
                    Xobjfun   = ObjectiveFunction('Sdescription','objective function', ...
                        'Sscript',...
                        strcat('for n=1:length(Tinput),',...
                        ['Toutput(n).outIA=#(Tinput(n).',CoutputName{1},');'],...
                        'end'),...
                        'CoutputNames',{'outIA'},...
                        'CinputNames',CoutputName);
                    
                    Xobj.Xmodel.Xinput=Xobj.XinputEquivalent;
                end
            elseif ~isempty(Xobj.Xmio)
                CoutputName=Xobj.Xmio.Coutputnames;
                
                % TODO: loop over all the outputs of the model
                assert(length(CoutputName)==1,...
                    'openCOSSAN:IntervalAnalysis:IntervalAnalysis',...
                    'Please provide a single output')
                
                % name the output of the Interval Analysis
                Xobj.SintervalOutputName=CoutputName{1};
                
                % Create the objective function from the Mio
                Xobjfun   = ObjectiveFunction('Sdescription','objective function', ...
                    'Sscript',...
                    strcat('for n=1:length(Tinput),',...
                    ['Toutput(n).outIA=#(Tinput(n).',CoutputName{1},');'],...
                    'end'),...
                    'CoutputNames',{'outIA'},...
                    'CinputNames',CoutputName);
                
                % Add the MIO object to an Evaluator object
                Xevaluator=Evaluator('CXmembers',{Xobj.Xmio},'CSmembers',{'Xmio'});
                
                %% Preparation of the Physical Model
                % Define a Model
                Xmdl=Model('Xinput',Xobj.XinputEquivalent,'Xevaluator',Xevaluator);
                Xobj.Xmodel=Xmdl;
                
            elseif ~isempty(Xobj.XobjectiveFunction)
                CoutputName=Xobj.XobjectiveFunction.Coutputnames;
                
                if isempty(Xobj.SintervalOutputName)
                    Xobj.SintervalOutputName='outIA';
                end
                
                % TODO: loop over all the outputs of the model
                assert(length(CoutputName)==1,...
                    'openCOSSAN:IntervalAnalysis:IntervalAnalysis',...
                    'Please provide a single output')
                
                % name the output of the Interval Analysis
                Xobj.SintervalOutputName=CoutputName{1};
                
                % Create the objective function from the Mio
                Xobjfun   = ObjectiveFunction('Sdescription','objective function', ...
                    'Sscript',...
                    strcat('for n=1:length(Tinput),',...
                    ['Toutput(n).outIA=#(Tinput(n).',CoutputName{1},');'],...
                    'end'),...
                    'CoutputNames',{'outIA'},...
                    'CinputNames',CoutputName);
                
                %% Preparation of the Physical Model
                XMIO=Mio('Sdescription','Mio object created by the IA constructor',...
                    'Sscript',Xobj.XobjectiveFunction.Sscript,...
                    'CinputNames',Xobj.XobjectiveFunction.Cinputnames,...
                    'CoutputNames',Xobj.XobjectiveFunction.Coutputnames);
                % Add the OjectiveFunction to an Evaluator object
                Xevaluator=Evaluator('CXmembers',{XMIO},'CSmembers',{'Xmio'});
                % Define a Model
                Xmdl=Model('Xinput',Xobj.XinputEquivalent,'Xevaluator',Xevaluator);
                Xobj.Xmodel=Xmdl;
                
            elseif false
                %TODO: add case with connector
            end
            Xobj.XobjectiveFunction=Xobjfun;
            %% Prepare the optimization problem
            Xobj=prepareOptimizationProblem(Xobj);
        end     %of constructor
        
        %% Dependent Fields
        
        function CnamesIntervalVariables=get.CnamesIntervalVariables(Xobj)
            CnamesIntervalVariables=Xobj.Xinput.CnamesIntervalVariable;
        end
        
        function NintervalVariables=get.NintervalVariables(Xobj)
            NintervalVariables=length(Xobj.Xinput.CnamesIntervalVariable);
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
        
        function CobjectiveFunctionNames = get.CobjectiveFunctionNames(Xobj)
            CobjectiveFunctionNames={};
            for n=1:length(Xobj.XobjectiveFunction)
                CobjectiveFunctionNames  = [CobjectiveFunctionNames Xobj.XobjectiveFunction(n).Coutputnames]; %#ok<AGROW>
            end
        end
        
        %         function NobjectiveFunctions = get.NobjectiveFunctions(Xobj)
        %             NobjectiveFunctions=length(Xobj.XobjectiveFunction);
        %         end
    end     %of methods
    
end     %of classdef
