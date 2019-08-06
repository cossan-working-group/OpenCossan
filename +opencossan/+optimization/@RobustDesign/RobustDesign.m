classdef RobustDesign < opencossan.optimization.OptimizationProblem
    %RobustDesign This is class used to define a robust design problem.
    % It extends the class OptimizationProblem,
    
    properties
        XinnerLoopModel         % Model used to compute the "robust output"
        Xsimulator              % Simulation object, used to execute the inner loop Model
        Cmapping                % Mapping between designVariable and input of the Model
        CSinnerLoopOutputNames  % Names associated to the quantity of interest
    end
    
    methods
        
        %%  Constructor
        function Xobj = RobustDesign(varargin)
            %RobustDesign
            %
            %   This is the constructor for the class RobustDesign. It is
            %   intended for defining a robust dessign optimization. 
            %   The class RobustDesign inherits all methods and properties 
            %   of the class OptimizationProblem.
            
            % =========================================================================
            % COSSAN-X - The next generation of the computational stochastic analysis
            % University of Innsbruck, Copyright 1993-2011 IfM
            % =========================================================================
            
            if isempty(varargin)
                % Construct an empty object used by the subclasses
                % Please DO NOT REMOVE this
                return
            end
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            %% Process inputs arguments
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    %2.1.   Description of the object
                    case 'sdescription'
                        Xobj.Sdescription   = varargin{k+1};
                    case 'xobjectivefunction'
                        if isa(varargin{k+1},'ObjectiveFunction')
                            Xobj.XobjectiveFunction  = varargin{k+1};
                        else
                            error('openCOSSAN:RobustDesign',...
                                [ inputname(k+1) ' must  be an ObjectiveFunction ']);
                        end
                    case 'cxobjectivefunctions'
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n},'ObjectiveFunction'), ...
                                'openCOSSAN:RobustDesign',...
                                'CXobjectivefunctions must contains only ObjectiveFunction Objects ');
                            if n==1
                                Xobj.XobjectiveFunction= varargin{k+1}{n};
                            else
                                Xobj.XobjectiveFunction(n)= varargin{k+1}{n};
                            end
                        end
                        
                    case 'ccxobjectivefunctions'
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n}{:},'ObjectiveFunction'), ...
                                'openCOSSAN:RobustDesign',...
                                'CXobjectivefunctions must contains only ObjectiveFunction Objects ');
                            if n==1
                                Xobj.XobjectiveFunction= varargin{k+1}{n}{:};
                            else
                                Xobj.XobjectiveFunction(n)= varargin{k+1}{n}{:};
                            end
                        end
                    case 'xconstraint'
                        % Add constraint object
                        if isa(varargin{k+1}(1),'Constraint')
                            Xobj.Xconstraint  = varargin{k+1};
                        else
                            error('openCOSSAN:RobustDesign',...
                                [ inputname(k+1) ' must  be a Constrains Object ']);
                        end
                    case 'cxconstraint'
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n},'Constraint'), ...
                                'openCOSSAN:RobustDesign',...
                                'CXconstraint must contains only Constraint Object ');
                            if n==1
                                Xobj.Xconstraint= varargin{k+1}{n};
                            else
                                Xobj.Xconstraint(n)= varargin{k+1}{n};
                            end
                        end
                    case {'ccxconstraints' 'ccxconstraint'}
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n}{:},'Constraint'), ...
                                'openCOSSAN:RobustDesign',...
                                'CXconstrains must contains only Constraint Objects ');
                            if n==1
                                Xobj.Xconstraint= varargin{k+1}{n}{:};
                            else
                                Xobj.Xconstraint(n)= varargin{k+1}{n}{:};
                            end
                        end
                    case {'vinitialsolution','minitialsolutions'}
                        Xobj.VinitialSolution   = varargin{k+1};
                    case {'vweightsobjectivefunctions'}
                        Xobj.VweightsObjectiveFunctions = varargin{k+1};
                    case 'xmodel'
                        Xobj.Xmodel   = varargin{k+1};
                    case 'xinput'
                        Xobj.Xinput   = varargin{k+1};
                    case 'cxinput'
                        Xobj.Xinput   = varargin{k+1}{1};
                    case 'xmetamodel'
                        XmetaData=metaclass(varargin{k+1});
                        assert(strcmp(XmetaData.SuperClasses{1}.Name,'MetaModel'), ...
                            'openCOSSAN:RobustDesign',...
                            'The object provided after the PropertyName Xmetamodel has a superclass %s, (it must be of superclass MetaModel) ',XmetaData.SuperClasses{1}.Name);
                        Xobj.Xmetamodel=varargin{k+1};
                    case 'cxmetamodel'
                        XmetaData=metaclass(varargin{k+1}{1});
                        assert(strcmp(XmetaData.SuperClasses{1}.Name,'MetaModel'), ...
                            'openCOSSAN:RobustDesign',...
                            'The object provided after the PropertyName CXmetamodel has a superclass %s, (it must be of superclass MetaModel) ',XmetaData.SuperClasses{1}.Name);
                        Xobj.Xmetamodel=varargin{k+1}{1};
                    case 'xinnerloopmodel'
                        assert(isa(varargin{k+1},'Model'), ...
                            'openCOSSAN:RobustDesign',...
                            'The object provided after the PropertyName XinnerLoopModel is of class %s',class(varargin{k+1}));
                        Xobj.XinnerLoopModel=varargin{k+1};
                    case {'cxinnerloopmodel' 'cxmodel'}
                        assert(isa(varargin{k+1}{1},'Model'), ...
                            'openCOSSAN:RobustDesign',...
                            'The object provided after the PropertyName CXinnerLoopModel is of class %s',class(varargin{k+1}{1}));
                        Xobj.XinnerLoopModel=varargin{k+1}{1};
                    case 'xsimulator'
                        assert(isa(varargin{k+1},'MonteCarlo')|...
                            isa(varargin{k+1},'LatinHypercubeSampling')|...
                            isa(varargin{k+1},'HaltonSampling')|...
                            isa(varargin{k+1},'SobolSampling'),...
                            'openCOSSAN:RobustDesign',...
                            'A simulation object of class %s is not valid for RobustDesign',class(varargin{k+1}))
                        Xobj.Xsimulator = varargin{k+1};
                    case 'cxsimulator'
                        assert(isa(varargin{k+1}{1},'MonteCarlo')|...
                            isa(varargin{k+1}{1},'LatinHypercubeSampling')|...
                            isa(varargin{k+1}{1},'HaltonSampling')|...
                            isa(varargin{k+1}{1},'SobolSampling'),...
                            'openCOSSAN:RobustDesign',...
                            'A simulation object of class %s is not valid for RobustDesign',class(varargin{k+1}))
                        Xobj.Xsimulator = varargin{k+1}{1};
                    case 'cdesignvariablemapping'
                        Xobj.Cmapping=varargin{k+1};
                    case 'csinnerloopoutputnames'
                        Xobj.CSinnerLoopOutputNames=varargin{k+1};
                    otherwise
                        error('openCOSSAN:RobustDesign',...
                            ['Field name (' varargin{k} ') is not valid']);
                end
            end
            
            assert(~isempty(Xobj.Xinput),...
                'openCOSSAN:RobustDesign', ...
                'An Input is required to define an RobustDesign')
            
            assert(~isempty(Xobj.Xsimulator),...
                'openCOSSAN:RobustDesign', ...
                'A simulation object is required to define an RobustDesign')
            
            assert(~isempty(Xobj.CSinnerLoopOutputNames),...
                'openCOSSAN:RobustDesign', ...
                'It is necessary to define the name of the inner loop outputs')
                      
            assert(~isempty(Xobj.XobjectiveFunction),'openCOSSAN:RobustDesign',...
                'An ObjectiveFunction is required to define an RobustDesign')
            
            if isempty(Xobj.VweightsObjectiveFunctions)
                Xobj.VweightsObjectiveFunctions=ones(length(Xobj.XobjectiveFunction),1);
            end
            
            assert(length(Xobj.XobjectiveFunction)==length(Xobj.VweightsObjectiveFunctions), ...
                'openCOSSAN:RobustDesign', ...
                'Length of the weigths (%i) does not match with the number of objective function (%i)', ...
                length(Xobj.VweightsObjectiveFunctions), length(Xobj.XobjectiveFunction))
            
            
            %% Validate Constructor
            assert(~isempty(Xobj.Xinput.CnamesDesignVariable), ...
                'openCOSSAN:RobustDesign',...
                'The input object must contains at least 1 design variable')
            
            
            % Set default initial solution
            if isempty(Xobj.VinitialSolution)
                CdefaultValues=struct2cell(Xobj.Xinput.getStructure);
                Xobj.VinitialSolution= cell2mat(CdefaultValues( ...
                    ismember(Xobj.Xinput.Cnames,Xobj.CnamesDesignVariables)))';
            else
                assert(length(Xobj.Xinput.CnamesDesignVariable)==size(Xobj.VinitialSolution,2), ...
                    'openCOSSAN:RobustDesign',...
                    ['The lenght of VinitialSolution (' num2str(size(Xobj.VinitialSolution,2)) ...
                    ') must be equal to the number of design varibles (' ...
                    num2str(length(Xobj.Xinput.CnamesDesignVariable)) ')' ] )
            end
            
            
            %% Construct SolutionSequence object
            Xss=Xobj.constructSolutionSequence;
            Xev=Evaluator('XsolutionSequence',Xss);
            Xobj.Xmodel=Model('Xevaluator',Xev,'Xinput',Xobj.Xinput);
            
            %% Check if the input object contains all the variables required by the optimization and contrains
            
            CprovidedInputs=Xobj.Xinput.Cnames;
            if ~isempty(Xobj.Xmodel)
                CprovidedInputs=[CprovidedInputs Xobj.Xmodel.Coutputnames];
            end
            
            assert(all(ismember(Xobj.Cinputnames,CprovidedInputs)), ...
                'openCOSSAN:OptimizationProblem',...
                ['The input object does not contain all the required inputs to ' ...
                'evaluate objective function and constraints. ' ...
                '\nRequired inputs: ' sprintf('\n* %s;',Xobj.Cinputnames{:}) ...
                '\nDefined inputs: ' sprintf('\n* %s;',CprovidedInputs{:}) ])
            
        end     %of constructor
        
        Xss=constructSolutionSequence(Xobj)
        
        %%  Methods inherited from the superclass
    end     %of methods
end
