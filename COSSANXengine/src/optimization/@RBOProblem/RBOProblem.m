classdef RBOProblem < OptimizationProblem
    %RBOProblem This is class used to define the ReliabilityBasedOptimization
    %Problem. It exends the class OptimizationProblem,
    %
    % See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@RobustDesign
    %
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
    
    properties
        XprobabilisticModel     % ProbabilisticModel used to compute the failure probability
        Xsimulator              % method used to compute the failure probability
        Cmapping                % Mapping between DesignVariables and inputs of the ProbabilisticModel
        SfailureProbabilityName % Name associated to the failure probability
        CSprobabilisticModelValues % Names of the variables extracted from the inner loop.
        VperturbationSize       % perturbation size for local RBO
        NmaxLocalRBOIteration   % maximum number of iteration for local RBO
        SmetamodelType          % Type of metamodel used for solving the RBOproblem
        CmetamodelProperties    % Cell that contains the properties of the MetaModel
        CSinnerLoopOutputNames  % Names associated to the quantity of interest
    end
    
    
    %%  Methods inherited from the superclass
    methods
        
        [Xopt, varargout]  = optimize(Xobj,varargin) % Perform optimization
        [Xopt, varargout]  = optimizeDirectApproach(Xobj,varargin) % Perform optimization
        [Xopt, varargout]  = optimizeGlobalMetaModel(Xobj,varargin) % Perform optimization
        [Xopt, varargout]  = optimizeLocalMetaModel(Xobj,varargin) % Perform optimization
        
        
        display(Xobj)                   %This method shows the summary of the Xobj
        
        Xobj=calibrateMetaModel(Xobj,varargin); % This method is used to train a metamodel used to compute the failure probability
        
        function Xobj = RBOProblem(varargin)
            %%  Constructor
            %RBOProblem
            %
            %   This is the constructor for the class RBOProblem. It is
            %   intended for defininf a RBO problem. The class RBOProblem
            %   inherits all methods and properties of the class
            %   OptimizationProblem.
            %
            % See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/@RBOproblem
            %
            %
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
                        assert(isa(varargin{k+1},'ObjectiveFunction'),...
                            'openCOSSAN:RBOproblem',...
                                 '%s must  be an ObjectiveFunction ',inputname(k+1))
                        Xobj.XobjectiveFunction  = varargin{k+1};
                    case 'cxobjectivefunctions'
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n},'ObjectiveFunction'), ...
                                'openCOSSAN:RBOproblem',...
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
                                'openCOSSAN:RBOproblem',...
                                'CXobjectivefunctions must contains only ObjectiveFunction Objects ');
                            if n==1
                                Xobj.XobjectiveFunction= varargin{k+1}{n}{:};
                            else
                                Xobj.XobjectiveFunction(n)= varargin{k+1}{n}{:};
                            end
                        end
                    case 'xconstraint'
                        % Add constraint object
                          assert(isa(varargin{k+1},'Constraint'),...
                            'openCOSSAN:RBOproblem',...
                                 '%s must  be an Constraint Object ',inputname(k+1))
                            Xobj.Xconstraint  = varargin{k+1};
                    case 'cxconstraint'
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n},'Constraint'), ...
                                'openCOSSAN:RBOproblem',...
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
                                'openCOSSAN:RBOproblem',...
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
                    case 'xinput'
                        Xobj.Xinput   = varargin{k+1};
                    case 'cxinput'
                        Xobj.Xinput   = varargin{k+1}{1};
                    case 'xsimulator'
                        % Getting the metadata of the Object
                        XmetaData=metaclass(varargin{k+1});
                        assert(strcmp(XmetaData.SuperClasses{1}.Name,'Simulations'), ...
                            'openCOSSAN:RBOproblem',...
                            'The object provided after the PropertyName Xsimulator has a superclass %s, (it must be of superclass Simulations) ',XmetaData.SuperClasses{1}.Name);
                        Xobj.Xsimulator=varargin{k+1};
                    case 'cxsimulator'
                        XmetaData=metaclass(varargin{k+1}{1});
                        assert(strcmp(XmetaData.SuperClasses{1}.Name,'Simulations'), ...
                            'openCOSSAN:RBOproblem',...
                            'The object provided after the PropertyName CXsimulator has a superclass %s, (it must be of superclass Simulations) ',XmetaData.SuperClasses{1}.Name);
                        Xobj.Xsimulator=varargin{k+1}{1};
                    case {'xprobabilisticmodel' 'xmodel'}
                        assert(isa(varargin{k+1},'ProbabilisticModel'), ...
                            'openCOSSAN:RBOproblem',...
                            'The object provided after the PropertyName Xprobabilisticmodel is of class %s',class(varargin{k+1}));
                        Xobj.XprobabilisticModel=varargin{k+1};
                    case {'cxprobabilisticmodel' 'cxmodel'}
                        assert(isa(varargin{k+1}{1},'ProbabilisticModel'), ...
                            'openCOSSAN:RBOproblem',...
                            'The object provided after the PropertyName CXprobabilisticmodel is of class %s',class(varargin{k+1}{1}));
                        Xobj.XprobabilisticModel=varargin{k+1}{1};
                    case 'cdesignvariablemapping'
                        Xobj.Cmapping=varargin{k+1};
                    case 'sfailureprobabilityname'
                        Xobj.SfailureProbabilityName=varargin{k+1};
                    case {'csprobabilisticmodelvalues' 'csinnerloopvariables'}
                        Xobj.CSprobabilisticModelValues=varargin{k+1};
                    case 'smetamodeltype'
                        Xobj.SmetamodelType=varargin{k+1};
                    case 'nmaxlocalrboiterations'
                        Xobj.NmaxLocalRBOIteration=varargin{k+1};
                    case 'vperturbation'
                        Xobj.VperturbationSize=varargin{k+1};
                    case 'csinnerloopoutputnames'
                        Xobj.CSinnerLoopOutputNames=varargin{k+1};
                    otherwise
                        % The validity of the metamodelProperties is not checked
                        % during the definition of the RBOproblem but only when
                        % the metamodel object is constructed (used)
                        Xobj.CmetamodelProperties{end+1}=varargin{k};
                        Xobj.CmetamodelProperties{end+1}=varargin{k+1};
                end
            end
            
            if isempty(Xobj.SmetamodelType)
                assert(isempty(Xobj.CmetamodelProperties),'openCOSSAN:RBOproblem', ...
                    'It is not possible to provide details for the metamodel without specifing the metamodel type.')
            end
            
            assert(~isempty(Xobj.Cmapping),...
                'openCOSSAN:RBOproblem', ...
                'The RBOproblem requires the mapping between the design variable and some quantities defined in the probabilistic model.')
            
            assert(~isempty(Xobj.Xinput),...
                'openCOSSAN:RBOproblem', ...
                'An Input is required to define an RBOproblem')
            
            assert(~isempty(Xobj.SfailureProbabilityName),...
                'openCOSSAN:RBOproblem', ...
                'It is necessary to define the name of the failure probability')
            
            assert(~isempty(Xobj.XobjectiveFunction),...
                'openCOSSAN:RBOproblem', ...
                'An objective function is required to define an RBOproblem')
            
            assert(~isempty(Xobj.Xsimulator),...
                'openCOSSAN:RBOproblem', ...
                'A Simulator object is required to define an RBOproblem')
            
            % Remove important direction from the LinaSamling
            if isa(Xobj.Xsimulator,'LineSampling')
                if ~isempty(Xobj.Xsimulator.Valpha)
                    OpenCossan.cossanDisp('[RBOProblem] Remove importance direction from LineSampling object',3)
                    Xobj.Xsimulator.Valpha=[];
                end
            end
            
            
            if isempty(Xobj.VweightsObjectiveFunctions)
                Xobj.VweightsObjectiveFunctions=ones(length(Xobj.XobjectiveFunction),1);
            end
            
            assert(length(Xobj.XobjectiveFunction)==length(Xobj.VweightsObjectiveFunctions), ...
                'openCOSSAN:RBOproblem', ...
                'Length of the weigths (%i) does not match with the number of objective function (%i)', ...
                length(Xobj.VweightsObjectiveFunctions), length(Xobj.XobjectiveFunction))
            
            %% Validate Constructor
            assert(~isempty(Xobj.Xinput.CnamesDesignVariable), ...
                'openCOSSAN:RBOproblem',...
                'The input object must contains at least 1 design variable')
            
            % Set default initial solution
            if isempty(Xobj.VinitialSolution)
                
                Xobj.VinitialSolution=Xobj.Xinput.getValues('Cnames',Xobj.CnamesDesignVariables);
                
                %                 CdefaultValues=struct2cell(Xobj.Xinput.getStructure);
                %                 Xobj.VinitialSolution= cell2mat(CdefaultValues( ...
                %                     ismember(Xobj.CnamesDesignVariables,Xobj.Xinput.Cnames)))';
            else
                assert(length(Xobj.Xinput.CnamesDesignVariable)==size(Xobj.VinitialSolution,2), ...
                    'openCOSSAN:RBOproblem',...
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
        
        
        
    end     %of methods
    
    
end     %of classdef
