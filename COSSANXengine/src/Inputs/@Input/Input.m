classdef Input
    %INPUT  Constructor for the Input object
    % This class is linking the various input objects with the toolboxes of
    % COSSAN X
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Input
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
    
    properties % Public access
        Sdescription            % Description of the Object
        LcheckFunctions=true    % boolean for check of the Functions
    end
    
    properties %(SetAccess=protected) % SetAccess protected
        Xrvset=struct;               % Collection of RandomVariableSet/GaussianRandomVariableSet object
        Xfunctions=struct;           % Collection of Function objects
        Xparameters=struct;          % Collection of Parameter objects
        XdesignVariable=struct;      % Collection of Design Variable objects
        Xbset=struct;                % Collection of BoundedSet
        Xsp=struct;                  % Collection of StochasticProcess objects
        Xsamples                     % Collection of Samples object
        CinputMapping                % names of the Intervals to be mapped into RV hyperparameters
    end
    
    properties (Dependent = true, SetAccess = protected)
        Ninputs                  % Total number of objects (entries) defined in the Input
        NrandomVariables         % Total number of randomvariables
        NstochasticProcesses     % Total number of stochastic process
        NdesignVariables         % Total number of designvariables
        NintervalVariables       % Total number of intervalvariables
        Nsamples                 % Total number of samples stored in the Input
        Cnames                   % Collection of Names of all the variables
        CnamesSet                % names of the RandomVariablesSet + GaussianMixtureRandomVariablesSet
        CnamesRandomVariableSet  % names of the RandomVariablesSet (only)
        CnamesGaussianMixtureRandomVariableSet % names of the GaussianMixtureRandomVariablesSet
        CnamesRandomVariable     % names of the Random Variables
        CnamesStochasticProcess  % names of the StochasticProcess
        CnamesFunction           % names of the Function
        CnamesParameter          % names of the Parameter
        CnamesDesignVariable     % names of the DesignVariable
        CnamesBoundedSet         % names of the BoundedSet
        CnamesIntervalVariable   % names of the Interval Variables
        LdiscreteDesignVariables % flag to check if discrete DesignVariables are used
    end
    
    %% Methods
    methods
        
        display(Xobj)                           % Show a summary of the Input object
        
        varargout=sample(Xobj,varargin)         % Generate samples from the Input object
        
        Xobj=add(Xobj,XobjectToBeAdded,varargin)% Add an object to the Input object
        
        Xobj=merge(Xobj,XobjectToBeAdded)       % Merge 2 input objects
        
        varargout=evalpdf(Xobj,varargin)        % evaluate pdf of samples passed as argument
        
        
        Xo=remove(Xobj,varargin)                % Remove an object from the Input object
        
        Xo=jacobianNataf(Xobj,varargin)         % calculates jacobian matrix associated with point in standard normal space
        
        Tout=getStructure(Xobj)                 % Generate matlab structure with the realizations of input objecs
        
        Poutput=getValues(Xobj,varargin)        % Retrieve the value(s) of a single variable
        
        Cout = evaluateFunction(Xobj,varargin)  % Compute the functions
        
            MX = getSampleMatrix(Xobj)              % Retrive reliazation in a matrix format
        
        varargout = getMoments(Xobj,varargin)   % Retrive the moments of Random Variables
        varargout = getStatistics(Xobj,varargin)% Retrieve the Statistic of interest
        varargout = getBounds(Xobj,varargin)    % Retrive the bounds  of Input variables
        
        %mapping between spaces
        varargout=cdf2physical(Xobj,varargin)
        varargout=cdf2stdnorm(Xobj,varargin)
        varargout=map2physical(Xobj,varargin)
        varargout=map2stdnorm(Xobj,varargin)
        
        [MphysicalSpace,Msamplesdoe] = hypercube2physical(Xinput,MsamplesHypercube)
        
        % Set methods
        Xobj=setDesignVariable(Xobj,varargin)
        Xobj=setDesignOfExperiments(Xobj,varargin)
        %% constructor
        function Xobj=Input(varargin)
            %INPUT Constructor method for the Input object.
            %
            % See also: https://cossan.co.uk/wiki/index.php/@Input
            %
            %
            % Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'xfunction'}
                        Xobj.Xfunctions.(inputname(k+1))=varargin{k+1};
                    case {'xrvset','xgrvset','xrandomvariableset','xgaussianrandomvariableset'}
                        Xobj.Xrvset.(inputname(k+1))=varargin{k+1};
                    case {'xsp','xstochasticprocess'}
                        assert(~isempty(varargin{k+1}.McovarianceEigenvectors), ...
                            'openCOSSAN:Input',...
                            'The KL-terms of the stochastic process are not determined');
                        Xobj.Xsp.(inputname(k+1))=varargin{k+1};
                    case {'xparameter'}
                        assert(isscalar(varargin{k+1}), ...
                            'openCOSSAN:Input:wrongParameterLenght',...
                            'Only a scalar input is allowed after the Xparameter field');
                        Xobj.Xparameters.(inputname(k+1))=varargin{k+1};
                    case {'xdesignvariable'}
                        Xobj.XdesignVariable.(inputname(k+1))=varargin{k+1};
                    case {'xbset','xboundedset'}
                        Xobj.Xbset.(inputname(k+1))=varargin{k+1};
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'xsamples'}
                        Xobj.Xsamples=varargin{k+1};
                    case {'lcheckfunctions'}
                        Xobj.LcheckFunctions=varargin{k+1};
                    case {'csmembers','csmember'}
                        CSmembers=varargin{k+1};
                    case {'cxmembers','cxmember'}
                        CXobjects=varargin{k+1};
                        % The object are retrieved from the base workspace
                    case {'ccxmembers','ccxmember'}
                        CXobjects=cell(size(varargin{k+1}));
                        for n=1:length(varargin{k+1})
                            CXobjects(n)=varargin{k+1}{n};
                        end
                    case 'cinputmapping'
                        Xobj.CinputMapping=varargin{k+1};
                    otherwise
                        error('openCOSSAN:Input',...
                            'Field name %s is not allowed',varargin{k});
                end
                
            end
            
            % Add objects to the Input
            if exist('CXobjects','var')
                assert(logical(exist('CSmembers','var')),...
                    'openCOSSAN:Input:NoCSmembers',...
                    ['It is necessary to define the names of the objects',...
                    ' (i.e. Parameters, RandomVariableSet, StochasticProcess, DesignVariable) using the ProperyField CSmembers']);
                
                assert(length(CXobjects)==length(CSmembers), ...
                    'openCOSSAN:Input:WrongInputLength',...
                    'Length of CXobject (%i) must be equal to the length of CSobject (%i)', ...
                    length(CXobjects),length(CSmembers))
                
                for iobj=1:length(CXobjects)
                    switch class(CXobjects{iobj})
                        case 'Function'
                            Xobj.Xfunctions.(CSmembers{iobj})= CXobjects{iobj};
                        case 'RandomVariableSet'
                            Xobj.Xrvset.(CSmembers{iobj})= CXobjects{iobj};
                        case 'GaussianMixtureRandomVariableSet'
                            Xobj.Xrvset.(CSmembers{iobj})= CXobjects{iobj};
                        case 'StochasticProcess'
                            Xobj.Xsp.(CSmembers{iobj})= CXobjects{iobj};
                        case 'Parameter'
                            Xobj.Xparameters.(CSmembers{iobj})= CXobjects{iobj};
                        case 'DesignVariable'
                            Xobj.XdesignVariable.(CSmembers{iobj})= CXobjects{iobj};
                        case 'BoundedSet'
                            Xobj.Xbset.(CSmembers{iobj})= CXobjects{iobj};
                        otherwise
                            error('openCOSSAN:Input:WrongObjectType',...
                                'The object %s of type %s is not a valid', ...
                                CSmembers{iobj},class(CXobjects{iobj}));
                    end
                end
            else
                assert(logical(~exist('CSmembers','var')),...
                    'openCOSSAN:Input',...
                    ['It is mandatory to pass objects using the ' ...
                    'PropertyName CXmembers']);
            end
            
            if ~isempty(Xobj.Xsamples)
                %% Check the Sample object
                if length(Xobj.Xsamples)>1
                    error('openCOSSAN:Input:TooManySamplesObjects',...
                        'Only 1 Samples objects is allowed in the Input)');
                end
                
                assert(isempty(setxor(Xobj.Xsamples.Cvariables,CSmembers)), ...
                    'openCOSSAN:Input:SamplesObjectsMismatchVariables',...
                    ['The variables defined in the Samples object do not match',...
                    ' the variable defined in the Input object)\n',...
                    'Input variables: %s\nSamples variables: %s'],...
                    sprintf(' ''%s'';',Xobj.Xsamples.Cvariables{:}),...
                    sprintf(' ''%s'';',CSmembers{:}));
            end
            
%             if Xobj.LintervalHyperparameters
%             assert(~isempty(Xobj.CinputMapping),...
%                 'openCOSSAN:Input:MissingInputMapping',...
%                 'The definition of interval hyper-parameters requires an Input Mapping')
%             end
            
            
            if ~isempty(Xobj.CnamesFunction) && Xobj.LcheckFunctions
                checkFunction(Xobj)
            end
        end % End constructor
        
        %% Dependent properties
        
        function outdata = get.Cnames(Xobj)
            % Please DO NOT change the order of the returned names
            outdata  = [Xobj.CnamesRandomVariable ...
                Xobj.CnamesFunction ...
                Xobj.CnamesParameter ...
                Xobj.CnamesStochasticProcess ...
                Xobj.CnamesDesignVariable ...
                Xobj.CnamesIntervalVariable,...
                ];
        end
        
        function CnamesRandomVariable = get.CnamesRandomVariable(Xobj)
            Crvset=Xobj.CnamesSet;
            CnamesRandomVariable={};
            if ~isempty(Crvset)
                for irvs=1:length(Crvset)
                    CnamesRandomVariable = [CnamesRandomVariable ...
                        Xobj.Xrvset.(Crvset{irvs}).Cmembers;];   %#ok<AGROW>
                end
            end
        end
        
        function NrandomVariables = get.NrandomVariables(Xobj)
            Crvset=Xobj.CnamesSet;
            NrandomVariables=0;
            if ~isempty(Crvset)
                for irvs=1:length(Crvset)
                    NrandomVariables = NrandomVariables + Xobj.Xrvset.(Crvset{irvs}).Nrv;
                end
            end
        end
        
        function NdesignVariables = get.NdesignVariables(Xobj)
            NdesignVariables=length(Xobj.CnamesDesignVariable);
        end
        
        function NstochasticProcesses = get.NstochasticProcesses(Xobj)
            NstochasticProcesses=length(Xobj.CnamesStochasticProcess);
        end
        
        function CnamesSet = get.CnamesSet(Xobj)
            % Return the names of the RandomVariableSet +
            % GaussianMixtureRandomVariable Set
            if ~isempty(Xobj.Xrvset)
                CnamesSet  = fieldnames(Xobj.Xrvset)';
            else
                CnamesSet  ={};
            end
        end
        
        function CnamesRandomVariableSet = get.CnamesRandomVariableSet(Xobj)
            % Return the names of the RandomVariableSet (only)
            Cnames=Xobj.CnamesSet;
            if ~isempty(Cnames)
                Vpos=false(length(Cnames),1);
                for irvset=1:length(Cnames)
                    Vpos(irvset)=strcmp(class(Xobj.Xrvset.(Cnames{irvset})),'RandomVariableSet');
                end
                CnamesRandomVariableSet=Cnames(Vpos);
            else
                CnamesRandomVariableSet  ={};
            end
        end
        
        function CnamesGaussianMixtureRandomVariableSet = get.CnamesGaussianMixtureRandomVariableSet(Xobj)
            % Return the names of the GaussianMixtureRandomVariableSet (only)
            Cnames=Xobj.CnamesSet;
            if ~isempty(Cnames)
                Vpos=false(length(Cnames),1);
                for irvset=1:length(Cnames)
                    Vpos(irvset)=strcmp(class(Xobj.Xrvset.(Cnames{irvset})),'GaussianMixtureRandomVariableSet');
                end
                CnamesGaussianMixtureRandomVariableSet=Cnames(Vpos);
            else
                CnamesGaussianMixtureRandomVariableSet  ={};
            end
        end
        
        function CnamesStochasticProcess = get.CnamesStochasticProcess(Xobj)
            if ~isempty(Xobj.Xsp)
                CnamesStochasticProcess  = fieldnames(Xobj.Xsp)';
            else
                CnamesStochasticProcess  ={};
            end
        end
        
        function CnamesFunction = get.CnamesFunction(Xobj)
            if ~isempty(Xobj.Xfunctions)
                CnamesFunction     = fieldnames(Xobj.Xfunctions)';
            else
                CnamesFunction  ={};
            end
        end
        
        function CnamesParameter = get.CnamesParameter(Xobj)
            if ~isempty(Xobj.Xparameters)
                CnamesParameter     = fieldnames(Xobj.Xparameters)';
            else
                CnamesParameter  ={};
            end
        end
        
        function CnamesDesignVariable = get.CnamesDesignVariable(Xobj)
            if ~isempty(Xobj.XdesignVariable)
                CnamesDesignVariable     = fieldnames(Xobj.XdesignVariable)';
            else
                CnamesDesignVariable  ={};
            end
        end
        
        function CnamesBoundedSet = get.CnamesBoundedSet(Xobj)
            % Return the names of the BoundedSet (only)
            if ~isempty(Xobj.Xbset)
                 CnamesBoundedSet  = fieldnames(Xobj.Xbset)';
            else
                CnamesBoundedSet  ={};
            end
        end
        
        function CnamesIntervalVariable = get.CnamesIntervalVariable(Xobj)
            Cbset=Xobj.CnamesBoundedSet;
            CnamesIntervalVariable={};
            if ~isempty(Cbset)
                for iiv=1:length(Cbset)
                    CnamesIntervalVariable = [CnamesIntervalVariable ...
                        Xobj.Xbset.(Cbset{iiv}).Cmembers;];   %#ok<AGROW>
                end
            end
        end
        
        function NintervalVariables = get.NintervalVariables(Xobj)
            Cbset=Xobj.CnamesBoundedSet;
            NintervalVariables=0;
            if ~isempty(Cbset)
                for iiv=1:length(Cbset)
                    NintervalVariables = NintervalVariables + Xobj.Xbset.(Cbset{iiv}).Niv;
                end
            end
        end
        
        function Ninputs = get.Ninputs(Xobj)
            Ninputs  = length(Xobj.Cnames);
        end
        
        function Nsamples = get.Nsamples(Xobj)
            if isempty(Xobj.Xsamples)
                Nsamples = 0;
            else
                Nsamples = Xobj.Xsamples.Nsamples;
            end
        end
        
        function Tdef = getDefaultValuesStructure(Xobj)
            Tdef =  Xobj.get('defaultvalues');
        end
        
        function Cdef = getDefaultValuesCell(Xobj)
            Cdef = struct2cell( Xobj.get('defaultvalues'));
        end
        
        function LdiscreteDesignVariables = get.LdiscreteDesignVariables(Xobj)
            LdiscreteDesignVariables=false;
            CnamesDesignVariable=Xobj.CnamesDesignVariable;
            for n=1:length(CnamesDesignVariable)
                if ~isempty(Xobj.XdesignVariable.(CnamesDesignVariable{n}).Vsupport)
                    LdiscreteDesignVariables=true;
                    break
                end
            end
        end
        
        checkFunction(Xobj)  %method checking whether the input functions are valid
        
    end % End methods
    
    %% Private Methods
    methods (Access=private)
        Cout=evaluateFunctions(Xobj,varargin) % Estimate the function defined
        % in the Input Object and return a cell array
    end
    
end

