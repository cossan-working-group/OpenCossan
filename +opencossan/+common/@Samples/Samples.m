classdef Samples
    % SAMPLES Definition of the class Samples The class Samples is used to store
    % relializations of random variables, stochastic process and
    % designvariables.
    %
    %
    % See also: https://cossan.co.uk/wiki/index.php/@Samples
    %
    % Author: Matteo Broggi, Edoardo Patelli
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
    
    properties  (SetAccess=protected)
        Xrvset                  % Array of objects RandomVariableSet/GaussianRandomVariableSet
        Xbset                   % Array of objects BoundedSet
        XdesignVariable         % Array of objects Design Variable
        XstochasticProcess      % Array of objects StochasticProcess
        CnamesStochasticProcess % cell array with the names of the StochasticProcess
        CnamesRandomVariableSet % Cell array of names of the RandomVariableSet/GaussianRandomVariableSet
        CnamesBoundedSet        % cell array of names of the BoundedSet
        CnamesDesignVariables   % names of the Design Variable
    end
    
    properties  (Dependent=true, SetAccess=protected)
        Nsamples                    % number of samples
        Cvariables                  % cell array with the names of the rvs & sp
        CnamesRandomVariable        % names of the random variables
        CnamesIntervalVariable      % names of the interval variables
    end
    
    properties (Dependent=true)
        MsamplesPhysicalSpace       % samples in the physical space
        MsamplesStandardNormalSpace % samples in the SNS
        Tsamples                    % samples in a structure format
    end
    
    properties (GetAccess=private, SetAccess=protected, Hidden)
        MsamplesPhysicalSpaceStored
        MsamplesStandardNormalSpaceStored
    end
    
    properties  (SetAccess=public)
        Sdescription            % description of the object
        Vweights                % Weights associated to the samples
        MsamplesHyperCube       % samples in the hypercube (cdf values)
        MdoeDesignVariables     % samples of design variables obtained with DOE
        MsamplesHyperSphere     % samples in the unit hypersphere of intervals (ellipsoidal correlation)
        MsamplesEpistemicSpace  % samples of interval variables
        MsamplesUnitHypercube   % samples in the unit hypercube of intervals
        Xdataseries             % Array of objects DataSeries with the realizations of the StochasticProcess
    end
    
    %% Methods of the class
    methods
        Xobj    = add(Xobj,varargin)   % Add samples to the Samples object
        
        varargout = evalpdf(Xobj,varargin)  % evaluate pdf at samples values
        
        Xobj    = chop(Xobj,varargin)  % Chops samples from the object
        
        [V1,V2] = cumulativeFrequencies(Xobj,varargin)  %compute the
        % cumulative frequencies of the samples of the Samples object
        
        [Xobj,X1] = relativeFrequencies(Xobj,varargin)    % calculates
        % relative frequencies of the samples of the Samples object
        
        varargout  = sort(Xobj,varargin)      % sorts samples of the Xobj
                
        function Xobj     = Samples(varargin)
            % SAMPLES Constructor of the object Samples.
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Samples
            %
            % ==============================================================================
            % COSSAN-X - The next generation of the computational stochastic analysis
            % ==============================================================================
            %
            % Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
            % Author: Edoardo Patelli Pierre Beaurepaire
            
            % Author: Edoardo Patelli, Matteo Broggi
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
            
            %% Argument Check
%             opencossan.OpenCossan.validateCossanInputs(varargin{:})
            
            %% Initialize variables
            Cnames  = [];   % empty variable to store names of random
            % variables - used for verify correctness of
            % provided parameters
            
            %% Process arguments passed to the constructor
            for k=1:2:nargin,
                switch lower(varargin{k})
                    case 'sdescription'     % Description of object Samples
                        Xobj.Sdescription     =varargin{k+1};
                    case {'msampleshypercube','mcdf'}  %  Samples in hypercube space (Correlated)
                        Xobj.MsamplesHyperCube = varargin{k+1};
                        if min(reshape( Xobj.MsamplesHyperCube ,[],1))<0 || max(reshape( Xobj.MsamplesHyperCube ,[],1))>1
                            error('openCOSSAN:Samples:Samples',...
                                'the samples defined in the hypercube must be in the range [0 1]');
                        elseif sum(reshape( imag( Xobj.MsamplesHyperCube) ,[],1)) ~=0
                            error('openCOSSAN:Samples:Samples',...
                                'the samples can not be complex numbers');  
                        end
                    case {'msampleshypersphere','mhs'}  %  Samples in interval delta space
                        Xobj.MsamplesHyperSphere = varargin{k+1};
                    case {'msamplesphysicalspace','mx'},
                        %   Samples in Physical Space (Correlated)
                        MX   = varargin{k+1};
                        if sum(reshape( imag( MX) ,[],1)) ~=0
                            error('openCOSSAN:Samples:Samples',...
                                'the samples can not be complex numbers');
                        end
                    case {'cdoedesignvariables','cxdoedesignvariables','cdv'}
                        for imem=1:length(varargin{k+1})
                            if isa(varargin{k+1}{imem},'inputs.DesignVariable')
                                Xobj.XdesignVariable{imem}     = varargin{k+1}{imem};
                            else
                                error('openCOSSAN:Samples:Samples',...
                                    ['a cell array of DesignVariable  '...
                                    ' objects must be passed after the FieldName ' varargin{k}]);
                            end
                        end
                    case {'msamplesdoedesignvariables','mdoedesignvariables'}
                        % Set the realizations of the design variables
                        MDOE   = varargin{k+1};
                    case {'msamplesepistemicspace','my'}
                        MY  = varargin{k+1};
                    case {'msamplesunithypercube','mh'}
                        MH  = varargin{k+1};
                    case {'msamplesstandardnormalspace','mu'},
                        %  Samples in standard normal space (Uncorrelated)
                        MU=varargin{k+1};
                        if sum(reshape( imag( MU) ,[],1)) ~=0
                            error('openCOSSAN:Samples:MsamplesStandardNormalSpaceIsNotReal',...
                                'The samples can not be complex numbers');
                        end
                    case {'tsampleshypercube'}
                        % store names of the fields
                        Cnames  = fieldnames(varargin{k+1})';
                        MHC= cell2mat(squeeze(struct2cell(varargin{k+1})))';
                        if min(reshape(MHC ,[],1))<0
                            error('openCOSSAN:Samples:Samples',...
                                'The samples defined in the hypercube must be in the range [0 1]');
                        end
                    case {'tsamplesphysicalspace'}
                        % store names of the fields
                        Cnames  = fieldnames(varargin{k+1})';
                        MX=cell2mat(squeeze(table2cell(varargin{k+1})))';
                    case {'tsamplesstandardnormalspace'}
                        % store names of the fields
                        Cnames  = fieldnames(varargin{k+1})';
                        MU=cell2mat(squeeze(table2cell(varargin{k+1})))';
                    case {'vweights','vweight'}
                        % Weigths of the Samples  (for importance Sampling)
                        Xobj.Vweights     = varargin{k+1};
                    case 'cnamesstochasticprocess'
                        Xobj.CnamesStochasticProcess     = varargin{k+1};
                    case 'xinput'
                        assert(isa(varargin{k+1},'opencossan.common.inputs.Input'),...
                            'openCOSSAN:Samples:Samples',...
                            'an Object Input must be passed after the FieldName Xinput')
                        
                        % extract RandomVariableSet from Input object
                        Xobj.Xrvset  = struct2cell(varargin{k+1}.RandomVariableSets);
                        Xobj.XdesignVariable  = struct2cell(varargin{k+1}.DesignVariables);
                        Xobj.XstochasticProcess = struct2cell(varargin{k+1}.StochasticProcesses);
                        Xobj.CnamesStochasticProcess = varargin{k+1}.StochasticProcessNames;
                        Xobj.CnamesDesignVariables= varargin{k+1}.DesignVariableNames;
                        Xobj.CnamesRandomVariableSet= varargin{k+1}.RandomVariableSetNames;
                        
                    case{'xrvset','xrandomvariableset','xgrvset','xgaussianrandomvariableset'}
                        %  Case of RandomVariableSet object
                        if isa(varargin{k+1}(1),'opencossan.common.inputs.random.RandomVariableSet') ||...
                                isa(varargin{k+1}(1),'opencossan.common.inputs.GaussianMixtureRandomVariableSet')
                            Xobj.Xrvset{1}     = varargin{k+1}(1);
                        else
                            error('openCOSSAN:Samples:Samples',...
                                ['a RandomVariableSet/GaussianRandomVariableSet  '...
                                ' object must be passed after the FieldName ' varargin{k}]);
                        end
                    case {'xbset','xboundedset'}
                        Xobj.Xbset{1}=varargin{k+1};
                        assert(isa(varargin{k+1},'opencossan.intervals.BoundedSet'),...
                            'openCOSSAN:Samples:Samples',...
                            'An object of type BoundedSet must be passed after the FiledName %s',varargin{k});
                    case {'cxbset','cxboundedset'}
                        for imem=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{imem},'opencossan.intervals.BoundedSet'),...
                                'openCOSSAN:Samples:Samples',...
                                'An object of type BoundedSet must be passed after the FiledName %s',varargin{k}{imem});
                                Xobj.Xbset{imem}     = varargin{k+1}{imem};
                        end
                    case{'cxrvset','cxrandomvariableset','cxgrvset','cxgaussianrandomvariableset'},
                        %  Case of RandomVariableSet object
                        for imem=1:length(varargin{k+1})
                            if isa(varargin{k+1}{imem},'opencossan.common.inputs.random.RandomVariableSet') || ...
                                    isa(varargin{k+1}{imem},'opencossan.common.inputs.GaussianMixtureRandomVariableSet')
                                Xobj.Xrvset{imem}     = varargin{k+1}{imem};
                            else
                                error('openCOSSAN:Samples:Samples',...
                                    ['a cell array of RandomVariableSet/GaussianRandomVariableSet'...
                                    ' objects must be passed after the FieldName ' varargin{k}]);
                            end
                        end
                    case 'xstochasticprocess'
                        %Case of a stochasticprocess
%                        if isa(varargin{k+1}(1),'opencossan.common.inputs.StochasticProcess')
                            Xobj.XstochasticProcess{1} = varargin{k+1}(1);
%                         else
%                             error('openCOSSAN:Samples:Samples',...
%                                 ['A StochasticProcess object must be passed after the FieldName ' varargin{k} ]);
%                         end
                    case{'cxstochasticprocess'}
                        %  Case of RandomVariableSet object
                        for imem=1:length(varargin{k+1})
%                            if isa(varargin{k+1}{imem},'opencossan.common.inputs.StochasticProcess')
                                Xobj.XstochasticProcess{imem}     = varargin{k+1}{imem};
%                             else
%                                 error('openCOSSAN:Samples:Samples',...
%                                     ['A cell array of StochasticProcess'...
%                                     ' objects must be passed after the FieldName ' varargin{k}]);
%                             end
                        end
                    case 'cxdataseries'
                        %Case of a dataseries
                        if all(cellfun(@(x)(isa(x,'opencossan.common.Dataseries')),varargin{k+1}))
                            Xobj.Xdataseries...
                                (size(varargin{k+1},1),size(varargin{k+1},2)) = ...
                                varargin{k+1}{end,end};
                            for isp = size(varargin{k+1},2)
                                for isample=1:size(varargin{k+1},1)
                                    Xobj.Xdataseries(isample,isp) = varargin{k+1}{isample,isp};
                                end
                            end
                        else
                            error('openCOSSAN:Samples:Samples',...
                                'Only Dataseries object must be contained in the cell array passed after the FieldName CXdataseries ');
                        end
                    case 'xdataseries'
                        %Case of a dataseries
                        if (isa(varargin{k+1},'opencossan.common.Dataseries'))
                            Xobj.Xdataseries = varargin{k+1};
                        else
                            error('openCOSSAN:Samples:Samples',...
                                'Only Dataseries object must be passed after the FieldName Xdataseries ');
                        end
                    case {'cnamesdesignvariable','cnamesdesignvariables'}
                        Xobj.CnamesDesignVariables = varargin{k+1};
                    case {'cnamesrandomvariableset','cnamesrvs'}
                        Xobj.CnamesRandomVariableSet = varargin{k+1};
                    case {'cnamesboundedset','cnamesbset'}
                        Xobj.CnamesBoundedSet = varargin{k+1};
                    otherwise
                        % Case of an unknown parameter
                        error('openCOSSAN:Samples:Samples', ...
                            'PropertyName %s is not a valid Property. \n Please see http://cossan.cfd.liv.ac.uk/wiki/index.php/@Samples',varargin{k})
                end
            end
            
            %% Set MsamplesHyperCube/MdoeDesignVariables
            if exist('MHC','var')
                Xobj.MsamplesHyperCube=MHC;
            end

            if exist('MDOE','var')
                Xobj.MdoeDesignVariables=MDOE;
            end
            
            if exist('MH','var')
               Xobj.MsamplesUnitHypercube=MH; 
            end
            
            if ~isempty(Xobj.MsamplesHyperCube)
                if size(Xobj.MsamplesHyperCube,2) ~=length( Xobj.CnamesRandomVariable)
                    error('openCOSSAN:Samples:Samples',...
                        [' The number of colums (%n) of the samples matrix does NOT ' ...
                        'match with the number of the random variables defined ' ...
                        'in the RandomVariableSet (%n)'],size(Xobj.MsamplesHyperCube,2),length( Xobj.CnamesRandomVariable));
                end
            end
            
            %%
            if ~isempty(Cnames)
                %re-orders the samples according to the rvset order
                [~, loc] =ismember(Xobj.CnamesRandomVariable,Cnames);
                if exist('MX','var')
                    MX = MX(:,loc);
                elseif exist('MU','var')
                    MU = MU(:,loc);
                else
                    Xobj.MsamplesHyperCube =  Xobj.MsamplesHyperCube(:,loc);
                end
            end
            
                   
            if exist('MX','var')
                % Map the sample from the physical space to the unit
                % hypercube
                Xobj.MsamplesHyperCube=zeros(size(MX));
                irv=0;
                % Cycle over all the RandomVariableSet
                for n=1:length(Xobj.Xrvset)
                    Xobj.MsamplesHyperCube(:,irv+(1:Xobj.Xrvset{n}.Nrv),:)= ...
                        Xobj.Xrvset{n}.physical2cdf(MX(:,irv+(1:Xobj.Xrvset{n}.Nrv)));
                    irv=irv+Xobj.Xrvset{n}.Nrv;
                end
                
                Xobj.MsamplesPhysicalSpaceStored=MX;              
                         
            elseif exist('MU','var')
                % Map the sample from the standard normal space to the unit
                % hyper cube
                Xobj.MsamplesHyperCube=zeros(size(MU));
                irv=0;
                % Cycle over all the RandomVariableSet and
                % GaussianMixtureRandomVariableSet
                for n=1:length(Xobj.Xrvset)
                    Xobj.MsamplesHyperCube(:,irv+(1:Xobj.Xrvset{n}.Nrv))= ...
                        Xobj.Xrvset{n}.stdnorm2cdf(MU(:,irv+(1:Xobj.Xrvset{n}.Nrv)));
                    irv=irv+Xobj.Xrvset{n}.Nrv;
                end
                Xobj.MsamplesStandardNormalSpaceStored=MU;
            end
                        
           
            if exist('MH','var') 
                
                Xobj.MsamplesUnitHypercube=MH;
                % Map the samples from the the unit hypercube to epistemic 
                % space of the intervals. Note the intervals might be
                % correlated and a specific method is needed to map them
                Xobj.MsamplesEpistemicSpace=zeros(size(MH));
                iiv=0;
                % Cycle over all BoundedSet
                for n=1:length(Xobj.Xbset)
                    Xobj.MsamplesEpistemicSpace(:,iiv+(1:Xobj.Xbset{n}.Niv))= ...
                        Xobj.Xbset{n}.map2physical(MH(:,iiv+(1:Xobj.Xbset{n}.Niv)));
                    iiv=iiv+Xobj.Xbset{n}.Niv;
                end
                
            elseif exist('MY','var') 
                Xobj.MsamplesEpistemicSpace=MY;
                % Map the samples from the epistemic space of the intervals
                % to the unit hypercube. Note the intervals might be
                % correlated and a specific method is needed to map them
                Xobj.MsamplesUnitHypercube=zeros(size(MY));
                iiv=0;
                % Cycle over all BoundedSet
                for n=1:length(Xobj.Xbset)
                    Xobj.MsamplesUnitHypercube(:,iiv+(1:Xobj.Xbset{n}.Niv))= ...
                        Xobj.Xbset{n}.map2hypercube(MY(:,iiv+(1:Xobj.Xbset{n}.Niv)));
                    iiv=iiv+Xobj.Xbset{n}.Niv;
                end
            end
            
            if isempty(Cnames)
                % check that the length of the columns of the samples are
                % equal to the number of random variables defined by the
                % RandomVariableSet objects
                assert (length(Xobj.CnamesRandomVariable)==length(Xobj.CnamesRandomVariable),...
                    'openCOSSAN:Samples:Samples',...
                    [' The number of colums (%n) of the samples matrix does not' ...
                    'match with the number of the random variables defined ' ...
                    'in the RandomVariableSet (%n)'],length(Xobj.CnamesRandomVariable), ...
                    length(Xobj.CnamesRandomVariable));
            else
                for i=1:length(Cnames)
                    % in case the names of the variables have been defined
                    % and do not match with current definition, an error is returned
                    assert(ismember(Cnames{i},Xobj.CnamesRandomVariable),...
                        'openCOSSAN:Samples:Samples',...
                        [' The name of the random variables (%s) defiend in the ' ...
                        'structure are not consistent with the names of ' ...
                        'the random variables defined in the RandomVariableSet'],Cnames{i});
                end
            end
            
%             %  Check that random variable set
%             assert(isempty(Xobj.Xrvset) || ~isempty(Xobj.MsamplesHyperCube), ...
%                 'openCOSSAN:Samples:Samples',...
%                 'RandomVariableSet is available but MsamplesHyperCube not defined');
%             
%             assert(isempty(Xobj.XstochasticProcess) || ~isempty(Xobj.Xdataseries), ...
%                 'openCOSSAN:Samples:Samples',...
%                 'StochasticProcess is available but Dataseries not defined');
%             
%             assert(isempty(Xobj.XdesignVariable) || ~isempty(Xobj.MdoeDesignVariables), ...
%                 'openCOSSAN:Samples:Samples',...
%                 'DesignVariables are available but no design of experiment defined');
%             
%             assert(isempty(Xobj.Xbset) || ~isempty(Xobj.MsamplesUnitHypercube),...
%                 'openCOSSAN:Samples:Samples',...
%                 'BoundedSet is available but MsampelsEpistemicSpace is not defined');
            
            
            
            %  Check consistency of samples w.r.t. dimension of weights
            if (~isempty(Xobj.Vweights)) && (size(Xobj.MsamplesHyperCube,1)~=length(Xobj.Vweights)),
                error('openCOSSAN:Samples:Samples', ...
                    ['size of the sample weights ( ' ...
                    num2str(length(Xobj.Vweights)) ...
                    ') does not agree with the size of the samples  ( ' ...
                    num2str(size(Xobj.MX,1)) ')'])
            end
            
            % Check consistency of the number of samples/realization
            Vsamples=[];
            if ~isempty(Xobj.MsamplesHyperCube)
                Vsamples = [Vsamples size(Xobj.MsamplesHyperCube,1)];
            end
            if ~isempty(Xobj.Xdataseries)
                Vsamples = [Vsamples Xobj.Xdataseries.Nsamples];
            end
            if ~isempty(Xobj.MdoeDesignVariables)
                Vsamples = [Vsamples size(Xobj.MdoeDesignVariables,1)];
            end    
            if ~isempty(Xobj.MsamplesHyperSphere)
                Vsamples = [Vsamples size(Xobj.MsamplesHyperSphere,1)];
            end
%             if ~isempty(Xobj.MsamplesEpistemicSpace)
%                 Vsamples = [Vsamples size(Xobj.MsamplesEpistemicSpace,1)];
%             end
            
            
            if ~isempty(Vsamples)
                
                assert(all(Vsamples==Vsamples(1)),...
                    'openCOSSAN:Samples:InconsistentSamplesSize', ...
                    ['No consistent number of samples for all the variables\n'....
                    'Samples RandomVariables     : %i\n',...
                    'Samples Dataseries          : %i\n',...
                    'Samples DesignOfExperiment  : %i\n',...
					'Samples MsamplesHyperSphere : %i'],...
                    size(Xobj.MsamplesHyperCube,1),...
                    size(Xobj.Xdataseries,1),... %TODO This gives the number of dataseries
                    size(Xobj.MdoeDesignVariables,1),...
                    size(Xobj.MsamplesHyperSphere,1));
                
            end
            
            if length(Xobj.CnamesStochasticProcess)~=length(Xobj.Xdataseries)
                warning('OpenCossan:Samples:noStochasticProcessName',...
                    'The length of StochasticProcess names (%i) does not match the number of dataseries (%i)',...
                    length(Xobj.CnamesStochasticProcess),length(Xobj.Xdataseries))
            end
            
        end     %of constructor
        
        %%  Dependent fields
        function Cvariables = get.Cvariables(Xobj)
            Cvariables=[Xobj.CnamesRandomVariable Xobj.CnamesStochasticProcess Xobj.CnamesDesignVariables Xobj.CnamesIntervalVariable];
        end
        
        function CnamesRandomVariable = get.CnamesRandomVariable(Xobj)
            CnamesRandomVariable  = {};
            
            for n=1:length(Xobj.Xrvset),
                CnamesRandomVariable=[CnamesRandomVariable Xobj.Xrvset{n}.Names]; %#ok<AGROW>
            end
        end  % of function for getting name of variables
        
        function CnamesIntervalVariable=get.CnamesIntervalVariable(Xobj)
            CnamesIntervalVariable = {};
            for n=1:length(Xobj.Xbset)
                CnamesIntervalVariable=[CnamesIntervalVariable, Xobj.Xbset{n}.Cmembers]; %#ok<AGROW>
            end
            
        end % of function for getting name of variables
        
        
        
        %%  Function for getting number of samples
        function Nsamples = get.Nsamples(Xobj)
            if ~isempty(Xobj.MsamplesHyperCube)
                Nsamples = size(Xobj.MsamplesHyperCube,1);
            elseif ~isempty(Xobj.Xdataseries)
                Nsamples = Xobj.Xdataseries.Nsamples;
            elseif ~isempty(Xobj.MdoeDesignVariables)
                Nsamples = size(Xobj.MdoeDesignVariables,1);
            elseif ~isempty(Xobj.MsamplesHyperSphere)
                Nsamples = size(Xobj.MsamplesHyperSphere,1);
            elseif ~isempty(Xobj.MsamplesUnitHypercube)
                Nsamples = size(Xobj.MsamplesUnitHypercube,1);
            else
                Nsamples=0;
            end
        end  % of function for getting number of samples
        
        %%  Function for setting the samples in the HypercubeSpace
        function Xobj = set.MsamplesHyperCube(Xobj,MsamplesHyperCube)
            if ~isempty(MsamplesHyperCube)
                assert(max(MsamplesHyperCube(:))<=1 && min(MsamplesHyperCube(:))>=0,...
                    'openCOSSAN:Samples:set',...
                    'The hypercube sample values must be in the [0,1] range')
                assert(size(MsamplesHyperCube,2)==length(Xobj.CnamesRandomVariable),...
                    'openCOSSAN:Samples:set',...
                    ['The number of colums of the sample matrix (%i) '...
                    'must be equal to the number of random variables (%i)'],...
                    size(MsamplesHyperCube,2),length(Xobj.CnamesRandomVariable))  %#ok<MCSUP>
            end
            % clear the stored samples in physical and standard normal
            % space
            Xobj.MsamplesPhysicalSpaceStored=[]; %#ok<MCSUP>
            Xobj.MsamplesStandardNormalSpaceStored=[]; %#ok<MCSUP>
            % remove the problematic bounds from the hypercube
            MsamplesHyperCube(MsamplesHyperCube==0)=eps(0.5);
            MsamplesHyperCube(MsamplesHyperCube==1)=1-eps(0.5);
            % store the samples in hypercube space
            Xobj.MsamplesHyperCube=MsamplesHyperCube;
        end
        
        %%  Function for getting the samples in the PhysicalSpace
        function MsamplesPhysicalSpace = get.MsamplesPhysicalSpace(Xobj)
            if isempty(Xobj.MsamplesPhysicalSpaceStored)
                if ~isempty(Xobj.MsamplesHyperCube)
                    Xobj.MsamplesPhysicalSpaceStored=zeros(size(Xobj.MsamplesHyperCube));
                    irv=0;
                    for n=1:length(Xobj.Xrvset)
                        Xobj.MsamplesPhysicalSpaceStored(:,irv+(1:Xobj.Xrvset{n}.Nrv))= ...
                            Xobj.Xrvset{n}.cdf2physical(Xobj.MsamplesHyperCube(:,irv+(1:Xobj.Xrvset{n}.Nrv)));
                        irv=irv+Xobj.Xrvset{n}.Nrv;
                    end
                    
                end
                if ~isempty(Xobj.MsamplesHyperSphere)
                    Nrvs=length(Xobj.CnamesRandomVariable);
                    Nint=length(Xobj.CnamesIntervalVariable);
                    Xobj.MsamplesPhysicalSpaceStored(:,Nrvs+1:Nrvs+Nint)=zeros(size(Xobj.MsamplesHyperSphere));
                    int=0;
                    for ibset=1:length(Xobj.Xbset)
                        %TODO: EXCLUDE BOUNDEDSET OF INTERVALS WITH NO
                        %PHYSICAL MEANING (ONLY EPISTEMIC/HYPERPARAMETERS)
                        %if strcmp(Xobj.Xbset{ibset}.ScorrelationFlag,'2') % ellipsoidal correlation
                        Xobj.MsamplesPhysicalSpaceStored(:,Nrvs+int+(1:Xobj.Xbset{ibset}.Niv))= ...
                            Xobj.Xbset{ibset}.map2physical('MsamplesHyperSphere',Xobj.MsamplesHyperSphere(:,int+(1:Xobj.Xbset{ibset}.Niv)));
                        int=int+Xobj.Xbset{ibset}.Niv;
                        %end
                    end 
                end           
            end
            MsamplesPhysicalSpace=Xobj.MsamplesPhysicalSpaceStored;
        end
        
        %%  Function for setting the samples in the PhysicalSpace
        function Xobj = set.MsamplesPhysicalSpace(Xobj,MsamplesPhysicalSpace)
            % removed the stored samples
            Nrvs=length(Xobj.CnamesRandomVariable);
%             Nint=length(Xobj.CnamesIntervalVariable);
            Xobj.MsamplesHyperCube=zeros(size(MsamplesPhysicalSpace(:,1:Nrvs)));
%             Xobj.MsamplesHyperSphere=zeros(size(MsamplesPhysicalSpace(:,Nrvs+1:Nrvs+Nint)));
            % populate the hypercube
            irv=0;
            % Cycle over all the RandomVariableSet
            for n=1:length(Xobj.Xrvset)
                Xobj.MsamplesHyperCube(:,irv+(1:Xobj.Xrvset{n}.Nrv),:)= ...
                    Xobj.Xrvset{n}.physical2cdf(MsamplesPhysicalSpace(:,irv+(1:Xobj.Xrvset{n}.Nrv)));
                irv=irv+Xobj.Xrvset{n}.Nrv;
            end
           
            % store the samples in physical space for future use
            Xobj.MsamplesPhysicalSpaceStored=MsamplesPhysicalSpace;
        end
        
        %%  Function for getting the samples in the StandardNormalSpace
        function MsamplesStandardNormalSpace = get.MsamplesStandardNormalSpace(Xobj)
            if isempty(Xobj.MsamplesStandardNormalSpaceStored)
                Xobj.MsamplesStandardNormalSpaceStored=zeros(size(Xobj.MsamplesHyperCube));
                irv=0;
                for n=1:length(Xobj.Xrvset)
                    Xobj.MsamplesStandardNormalSpaceStored(:,irv+(1:Xobj.Xrvset{n}.Nrv))= ...
                        Xobj.Xrvset{n}.cdf2stdnorm(Xobj.MsamplesHyperCube(:,irv+(1:Xobj.Xrvset{n}.Nrv)));
                    irv=irv+Xobj.Xrvset{n}.Nrv;
                end
            end
            MsamplesStandardNormalSpace=Xobj.MsamplesStandardNormalSpaceStored;
        end
        
        %%  Function for setting the samples in the StandardNormalSpace
        function Xobj = set.MsamplesStandardNormalSpace(Xobj,MsamplesStandardNormalSpace)
            % removed the stored samples
            Xobj.MsamplesHyperCube=zeros(size(MsamplesStandardNormalSpace));
            irv=0;
            % Cycle over all the RandomVariableSet
            for n=1:length(Xobj.Xrvset)
                Xobj.MsamplesHyperCube(:,irv+(1:Xobj.Xrvset{n}.Nrv),:)= ...
                    Xobj.Xrvset{n}.stdnorm2cdf(MsamplesStandardNormalSpace(:,irv+(1:Xobj.Xrvset{n}.Nrv)));
                irv=irv+Xobj.Xrvset{n}.Nrv;
            end
            % store the samples in physical space for future use
            Xobj.MsamplesStandardNormalSpaceStored=MsamplesStandardNormalSpace;
        end
        
        %%  Function for setting the samples of the design variables
        function Xobj = set.MdoeDesignVariables(Xobj,Msamplesdoe)
            assert(size(Msamplesdoe,2) == length(Xobj.CnamesDesignVariables), ...
                'openCOSSAN:Samples:set',...
                ['The number of column of Msamplesdoedesignvariables (%i) must be ' ...
                'equal to the length of the field CnamesDesignVariables (%i)'],...
                size(Msamplesdoe,2),length(Xobj.CnamesDesignVariables)); %#ok<MCSUP>
            Xobj.MdoeDesignVariables=Msamplesdoe;
        end
        
        %%  Function for getting the samples structure
        function Tsamples = get.Tsamples(Xobj)
            Nrvs=length(Xobj.CnamesRandomVariable);
            Nint=length(Xobj.CnamesIntervalVariable);
            %% Extract DesignVariable
            CdesignVariableValue   = num2cell(Xobj.MdoeDesignVariables);
            % Extract values of the RandomVariable
            Crvvalue =num2cell(Xobj.MsamplesPhysicalSpace(:,1:Nrvs));
            % Extract dataseries
            Cspvalue = num2cell(Xobj.Xdataseries);
            % Extract values of interval variables from EpistemicSpace
            CintnervalEpistemicValue = num2cell(Xobj.MsamplesEpistemicSpace);
            % Extract values of interval variables from EpistemicSpace
            CintervalPhysicalValue = num2cell(Xobj.MsamplesPhysicalSpace(:,Nrvs+1:Nrvs+Nint));
            % Construct the structure
            Tsamples=cell2struct([Crvvalue Cspvalue CdesignVariableValue CintervalPhysicalValue  CintnervalEpistemicValue],...
                Xobj.Cvariables, 2);
        end
        
        %% Function for setting the samples structure
        function Xobj = set.Tsamples(Xobj,Tsamples)
            % TODO: where are the stochastic processes???
            % check that all the necessary fields are available
            Cnames  = fieldnames(Tsamples);
            CrequiresFields = [Xobj.CnamesRandomVariable,Xobj.CnamesDesignVariables,Xobj.CnamesIntervalVariable];
            SavailableFields = sprintf( '%s ', Cnames{:});
            SrequiresFields = sprintf( '%s ', CrequiresFields{:});
            assert(all(ismember(CrequiresFields,Cnames)),...
                'openCOSSAN:Samples:set',...
                ['Not all the required values are available in the sample structure.\n',...
                'Required fields: %s\nAvailable fields: %s'],...
                SrequiresFields, SavailableFields);
            
            % create a matrix with all the samples from the structure
            MfullSamples = cell2mat(struct2cell(Tsamples))';
            
            % find which samples are random variables and their location in
            % the full matrix
            VlocRV = zeros(1,length(Xobj.CnamesRandomVariable));
            for irv=1:length(Xobj.CnamesRandomVariable)
                VlocRV(irv) = find(strcmpi(Xobj.CnamesRandomVariable{irv},Cnames));
            end
            % find which samples are design variables and their location in
            % the full matrix
            VlocDV = zeros(1,length(Xobj.CnamesDesignVariables));
            for idv=1:length(Xobj.CnamesDesignVariables)
                VlocDV(idv) = find(strcmpi(Xobj.CnamesDesignVariables{idv},Cnames));
            end
            % find which samples are interval variables and their location in
            % the full matrix TODO: exclude intervals with no physical
            % meaning
            VlocIV = zeros(1,length(Xobj.CnamesIntervalVariable));
            for int=1:length(Xobj.CnamesIntervalVariable)
                VlocIV(int) = find(strcmpi(Xobj.CnamesIntervalVariable{int},Cnames));
            end
            % find which samples are design variables and their location in
            % the full matrix
            % set the random variable values
            Xobj.MsamplesPhysicalSpace = [MfullSamples(:,VlocRV),MfullSamples(:,VlocIV)];
            % set the design variable values
            Xobj.MdoeDesignVariables = MfullSamples(:,VlocDV);
        end
    end     %of methods
    
end     %of classdef
