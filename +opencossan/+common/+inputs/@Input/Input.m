classdef Input < opencossan.common.CossanObject
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
        DoFunctionsCheck(1,1) logical = true     % boolean for check of the Functions
        Members containers.Map;
    end
    
    properties %(SetAccess=protected)            % SetAccess protected
        RandomVariableSets=struct;               % Collection of RandomVariableSet/GaussianRandomVariableSet object
        Functions=struct;                        % Collection of Function objects
        Parameters=struct;                       % Collection of Parameter objects
        %Xbset=struct;                           % Collection of BoundedSet
        StochasticProcesses=struct;              % Collection of StochasticProcess objects
        Samples                                  % Collection of Samples object
        %CinputMapping                           % names of the Intervals to be mapped into RV hyperparameters
    end
    
    properties (Dependent = true, SetAccess = protected)
        Ninputs                                  % Total number of objects (entries) defined in the Input
        NrandomVariables                         % Total number of randomvariables
        %        Nvariables                      % Total number of variables (random and bounded) % TODO: SILVIA: Is this still used???
        NstochasticProcesses                     % Total number of stochastic process
        Nparameters                              % Total number of Parameters
        Nfunctions
        Nsamples                                 % Total number of samples stored in the Input
        Names                                    % Collection of Names of all the variables
        SetNames                                 % names of the all the sets (RandomVariablesSet GaussianMixtureRandomVariablesSet BoundedSet)
        RandomVariableSetNames                   % names of the RandomVariablesSet (only)
        GaussianMixtureRandomVariableSetNames    % names of the GaussianMixtureRandomVariablesSet
        RandomVariableNames                      % names of the Random Variables
        StochasticProcessNames                   % names of the StochasticProcess
        FunctionNames                            % names of the Function
        ParameterNames                           % names of the Parameter
        DesignVariables
        DesignVariableNames   
        NumberOfDesignVariables                  % names of the DesignVariable
%         CnamesBoundedSet                         % names of the BoundedSet
%         CnamesIntervalVariable                   % names of the Interval Variables
        AreDesignVariablesDiscrete               % flag to check if discrete DesignVariables are used
    end
    
    %% Methods
    methods
        
        varargout=sample(Xobj,varargin)         % Generate samples from the Input object
        
        Xobj=add(Xobj,varargin)                 % Add an object to the Input object
        
        Xobj=merge(Xobj,XobjectToBeAdded)       % Merge 2 input objects
        
        varargout=evalpdf(Xobj,varargin)        % evaluate pdf of samples passed as argument
        
        Xo=remove(Xobj,varargin)                % Remove an object from the Input object
        
        Xo=jacobianNataf(Xobj,varargin)         % calculates jacobian matrix associated with point in standard normal space
        
        Tout=getStructure(Xobj)                 % Generate matlab structure with the realizations of input objecs
        
        TableOutput=getTable(Xobj)              % Generate matlab table with the realizations of input objecs
        
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
        varargout=map2uspace(Xobj,varargin)
        varargout=map2deltaSpace(Xobj,varargin)
        
        [MphysicalSpace, Msamplesdoe] = hypercube2physical(Xinput,MsamplesHypercube)
        
        % Set methods
        Xobj=setDesignVariable(Xobj,varargin)
        Xobj=setDesignOfExperiments(Xobj,varargin)
        
        %% constructor
        function Xobj=Input(varargin)
            %INPUT Constructor method for the Input object.
            %
            % See Also: http://cossan.co.uk/wiki/index.php/@Input
            %
            % Author: Edoardo Patelli
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            % email address: openengine@cossan.co.uk
            % Website: http://www.cossan.co.uk
            
            import opencossan.common.Samples
            import opencossan.common.inputs.*
            import opencossan.optimization.DesignVariable

            
            % process inputs via inputParser
            p = inputParser;
            p.FunctionName = 'opencossan.common.inputs.Input';
            
            % Use default values
            p.addParameter('Description',Xobj.Description);
            p.addParameter('DoFunctionsCheck',Xobj.DoFunctionsCheck);
            p.addParameter('Function',Function)
            p.addParameter('RandomVariableSet',random.RandomVariableSet)
            p.addParameter('GaussianMixtureRandomVariableSet',GaussianMixtureRandomVariableSet)
            p.addParameter('StochasticProcess',StochasticProcess)
            p.addParameter('Parameter',Parameter)
            p.addParameter('DesignVariables',[])
            p.addParameter('Samples',Samples)
            p.addParameter('Members',{})
            p.addParameter('MembersNames',"")
            
            p.parse(varargin{:});
            
            for k=1:2:length(varargin)
                switch (varargin{k})
                    case {'Function'}
                        Xobj.Functions.(inputname(k+1))=p.Results.Function;
                    case {'RandomVariableSet','GaussianMixtureRandomVariableSet'}
                        Xobj.RandomVariableSets.(inputname(k+1))=p.Results.RandomVariableSet;
                    case {'StochasticProcess'}
                        assert(~isempty(p.Results.StochasticProcess.McovarianceEigenvectors), ...
                            'openCOSSAN:Input',...
                            'The KL-terms of the stochastic process are not determined');
                        Xobj.StochasticProcess.(inputname(k+1))=p.Results.StochasticProcess;
                    case {'Parameter'}
                        assert(isscalar(p.Results.Parameter), ...
                            'openCOSSAN:Input:wrongParameterLenght',...
                            'Only a scalar input is allowed after the Parameter field');
                        Xobj.Parameters.(inputname(k+1))=p.Results.Parameter;
                    case {'DesignVariable'}
                        Xobj.DesignVariables.(inputname(k+1))=p.Results.DesignVariable;
                        %                     case {'xbset','xboundedset'}
                        %                         Xobj.Xbset.(inputname(k+1))=varargin{k+1};
                    case {'Description'}
                        Xobj.Description=p.Results.Description;
                    case {'Samples'}
                        Xobj.Samples=p.Results.Samples;
                    case {'DoFunctionsCheck'}
                        Xobj.DoFunctionsCheck=p.Results.DoFunctionsCheck;
                    case {'MembersNames'}
                        CSmembers=p.Results.MembersNames;
                    case {'Members'}
                        CXobjects=p.Results.Members;
                        % The object are retrieved from the base workspace
                    case {'ccxmembers','ccxmember'}
                        CXobjects=cell(size(varargin{k+1}));
                        for n=1:length(varargin{k+1})
                            CXobjects(n)=varargin{k+1}{n};
                        end
                    case 'cinputmapping'
                        Xobj.CinputMapping=varargin{k+1};
                end
            end
            
            % Add objects to the Input
            if exist('CXobjects','var')
                assert(logical(exist('CSmembers','var')),...
                    'openCOSSAN:Input:NoMembersNames',...
                    ['It is necessary to define the names of the objects',...
                    ' (i.e. Parameters, RandomVariableSet, StochasticProcess, DesignVariable) using the ProperyField MembersNames']);
                
                assert(length(CXobjects)==length(CSmembers), ...
                    'openCOSSAN:Input:WrongInputLength',...
                    'Length of Members (%i) must be equal to the length of MembersNames (%i)', ...
                    length(CXobjects),length(CSmembers))
                
                Xobj.Members = containers.Map(CSmembers, CXobjects);
                for iobj=1:length(CXobjects)
                    switch class(CXobjects{iobj})
                        case 'opencossan.common.inputs.Function'
                            Xobj.Functions.(CSmembers{iobj})= CXobjects{iobj};
                        case 'opencossan.common.inputs.random.RandomVariableSet'
                            Xobj.RandomVariableSets.(CSmembers{iobj})= CXobjects{iobj};
                        case 'opencossan.common.inputs.GaussianMixtureRandomVariableSet'
                            Xobj.RandomVariableSets.(CSmembers{iobj})= CXobjects{iobj};
                        case {'opencossan.common.inputs.stochasticprocess.KarhunenLoeve',...
                                'opencossan.common.inputs.stochasticprocess.AtkinsonSilva'}
                            Xobj.StochasticProcesses.(CSmembers{iobj})= CXobjects{iobj};
                        case 'opencossan.common.inputs.Parameter'
                            Xobj.Parameters.(CSmembers{iobj})= CXobjects{iobj};
                        otherwise
%                             error('openCOSSAN:Input:WrongObjectType',...
%                                 'The object %s of type %s is not a valid', ...
%                                 CSmembers{iobj},class(CXobjects{iobj}));
                    end
                end
            else
                assert(logical(~exist('CSmembers','var')),...
                    'openCOSSAN:Input',...
                    ['It is mandatory to pass objects using the ' ...
                    'PropertyName CXmembers']);
            end
            
            if ~isempty(Xobj.Samples)
                %% Check the Sample object
                assert(length(Xobj.Samples) <= 1,...
                    'openCOSSAN:Input:TooManySamplesObjects',...
                    'Only 1 Samples objects is allowed in the Input)')
                
                
                assert(isempty(setxor(Xobj.Xsamples.Cvariables,CSmembers)), ...
                    'openCOSSAN:Input:SamplesObjectsMismatchVariables',...
                    ['The variables defined in the Samples object do not match',...
                    ' the variable defined in the Input object)\n',...
                    'Input variables: %s\nSamples variables: %s'],...
                    sprintf(' ''%s'';',Xobj.Xsamples.Cvariables{:}),...
                    sprintf(' ''%s'';',CSmembers{:}));
            end
            
            if ~isempty(Xobj.FunctionNames) && Xobj.DoFunctionsCheck
                checkFunction(Xobj)
            end
        end % End constructor
        
        %% Dependent properties
        
        function names = get.Names(obj)
            % Please DO NOT change the order of the variable name returned
            % TODO: Should become keys(obj.Members) at some point.
            names = [obj.RandomVariableNames ...
                obj.FunctionNames ...
                obj.ParameterNames ...
                obj.StochasticProcessNames ...
                obj.DesignVariableNames];
        end
        
        function CVariableNames = get.RandomVariableNames(Xobj)
            CVariableNames={};
            CRVSetNames=fieldnames(Xobj.RandomVariableSets)';
            for irvs=1:length(CRVSetNames)
                if isa(Xobj.RandomVariableSets.(CRVSetNames{irvs}),'opencossan.common.inputs.GaussianMixtureRandomVariableSet')
                    CVariableNames = [CVariableNames ...
                    Xobj.RandomVariableSets.(CRVSetNames{irvs}).Cmembers];   %#ok<AGROW>
                else
                CVariableNames = [CVariableNames ...
                    Xobj.RandomVariableSets.(CRVSetNames{irvs}).Names];   %#ok<AGROW>
                end
            end
        end
        
        function NrandomVariables = get.NrandomVariables(Xobj)
            Crvset=Xobj.RandomVariableSetNames;
            NrandomVariables=0;
            if ~isempty(Crvset)
                for irvs=1:length(Crvset)
                    NrandomVariables = NrandomVariables + Xobj.RandomVariableSets.(Crvset{irvs}).Nrv;
                end
            end
            CrvsetGauss=Xobj.GaussianMixtureRandomVariableSetNames;
            if ~isempty(CrvsetGauss)
                for irvs=1:length(CrvsetGauss)
                    NrandomVariables = NrandomVariables + Xobj.RandomVariableSets.(CrvsetGauss{irvs}).Nrv;
                end
            end
        end
        
        function dvs = get.DesignVariables(obj)
            dvs = [];
            for k = keys(obj.Members)
                if isa(obj.Members(k{1}),...
                        'opencossan.optimization.DesignVariable')
                    dvs = [dvs obj.Members(k{1})]; %#ok<AGROW>
                end
            end
        end
        
        function names = get.DesignVariableNames(obj)
            names = [];
            for k = keys(obj.Members)
                if isa(obj.Members(k{1}),...
                        'opencossan.optimization.DesignVariable')
                    names = [names string(k{1})]; %#ok<AGROW>
                end
            end
        end
        
        function n = get.NumberOfDesignVariables(obj)
            n = length(obj.DesignVariables);
        end
        
        function NstochasticProcesses = get.NstochasticProcesses(Xobj)
            NstochasticProcesses=length(Xobj.StochasticProcessNames);
        end
        
        function RandomVariableSetNames = get.RandomVariableSetNames(Xobj)
            % Return the names of the RandomVariableSet (only)
            Cnames=fieldnames(Xobj.RandomVariableSets)';
            if ~isempty(Cnames) && ~isempty(fieldnames(Xobj.RandomVariableSets))
                Vpos=false(length(Cnames),1);
                for irvset=1:length(Cnames)
                    Vpos(irvset)=isa(Xobj.RandomVariableSets.(Cnames{irvset}),'opencossan.common.inputs.random.RandomVariableSet');
                end
                RandomVariableSetNames=Cnames(Vpos);
            else
                RandomVariableSetNames  ={};
            end
        end
        
        function GaussianMixtureRandomVariableSetNames = get.GaussianMixtureRandomVariableSetNames(Xobj)
            % Return the names of the GaussianMixtureRandomVariableSet (only)
            Cnames=fieldnames(Xobj.RandomVariableSets)';
            if ~isempty(Cnames) && ~isempty(fieldnames(Xobj.RandomVariableSets))
                Vpos=false(length(Cnames),1);
                for irvset=1:length(Xobj.RandomVariableSets)
                    Vpos(irvset)=isa(Xobj.RandomVariableSets.(Cnames{irvset}),'opencossan.common.inputs.GaussianMixtureRandomVariableSet');
                end
                GaussianMixtureRandomVariableSetNames=Cnames(Vpos);
            else
                GaussianMixtureRandomVariableSetNames  ={};
            end
            % Be sure the names are exported in a row
            if isvector(GaussianMixtureRandomVariableSetNames)
                GaussianMixtureRandomVariableSetNames=GaussianMixtureRandomVariableSetNames';
            end
            
        end
        
        function StochasticProcessNames = get.StochasticProcessNames(Xobj)
            StochasticProcessNames  = fieldnames(Xobj.StochasticProcesses)';
        end
        
        function FunctionNames = get.FunctionNames(Xobj)
            FunctionNames = fieldnames(Xobj.Functions)';
        end
        
        function ParameterNames = get.ParameterNames(Xobj)
            ParameterNames = fieldnames(Xobj.Parameters)';
        end        
%         function CnamesBoundedSet = get.CnamesBoundedSet(Xobj)
%             % Return the names of the BoundedSet (only)
%             CnamesBoundedSet  = fieldnames(Xobj.Xbset)';
%         end
        
%         function CnamesIntervalVariable = get.CnamesIntervalVariable(Xobj)
%             Cbset=Xobj.CnamesBoundedSet;
%             CnamesIntervalVariable={};
%             for iiv=1:length(Cbset)
%                 CnamesIntervalVariable = [CnamesIntervalVariable ...
%                     Xobj.Xbset.(Cbset{iiv}).Names;];   %#ok<AGROW>
%             end
%             if ~isrow(CnamesIntervalVariable)
%                 CnamesIntervalVariable=CnamesIntervalVariable';
%             end
%         end
        
        function Nparameters = get.Nparameters(Xobj)
            Nparameters = length(Xobj.ParameterNames);
        end
        
        function Nparameters = get.Nfunctions(Xobj)
            Nparameters = length(Xobj.FunctionNames);
        end
        
        function Ninputs = get.Ninputs(Xobj)
            Ninputs  = length(Xobj.Names);
        end
        
        function Nsamples = get.Nsamples(Xobj)
            if isempty(Xobj.Samples)
                Nsamples = 0;
            else
                Nsamples = Xobj.Samples.Nsamples;
            end
        end
        
        function Tdef = getDefaultValuesStructure(Xobj)
            Tdef =  Xobj.get('DefaultValues');
        end
        
        function Cdef = getDefaultValuesCell(Xobj)
            Cdef = struct2cell( Xobj.get('DefaultValues'));
        end
        
        function TableDefault = getDefaultValuesTable(Xobj)
            TableDefault = struct2table( Xobj.get('DefaultValues'),'AsArray',true);
        end
        
        function AreDesignVariablesDiscrete = get.AreDesignVariablesDiscrete(Xobj)
            AreDesignVariablesDiscrete=false;
            CDVNames=Xobj.DesignVariableNames;
            for n=1:length(CDVNames)
                if isa(Xobj.DesignVariables(CDVNames{n}), ...
                    'opencossan.optimization.DiscreteDesignVariable')
                    AreDesignVariablesDiscrete=true;
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

