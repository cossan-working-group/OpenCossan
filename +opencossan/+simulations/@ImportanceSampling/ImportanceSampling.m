classdef ImportanceSampling < opencossan.simulations.Simulations
    %IMPORTANCESAMPLING class definitoin of the ImportanceSampling
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@ImportanceSampling
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
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    properties (SetAccess = protected)
        XrvsetUD     % Collection of RandomVariableSet objects containing that defines the Importance Sampling Density
        Cmapping     % Map the RV of the Importance sampling distribution with Random Variables defined in the Input object
        Lcomputedesignpoint=false % flag to compute automatically the Proposal distribition based on the DesignPoint
    end
    
    properties
        SweightsName    = 'Vweigths' % Name of the variable used to store the weights
    end
    
    methods
        %% Methods inheritated from the superclass        
        Xo=computeProposalDistribution(Xobj,varargin)  % Calculate Proposal Distribution based on the
        
        Xo=apply(Xobj,varargin)  % Evaluate the Model/ProbabilisticModel
        
        [Msamples, weight]=sample(Xobj,varargin) % This method generate samples in the hypercube space from the proposal distribution
        
        varargout=computeFailureProbability(Xobj,varargin)    % Estimate the FailureProbability
        
        %% constructor
        function Xobj= ImportanceSampling(varargin)
            %IMPORTANCESAMPLING
            %
            % See also:
            % https://cossan.co.uk/wiki/index.php/@ImportanceSampling
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
                % Required to load the object from mat files
                return
            end
            
            %% Validate input arguments
            opencossan.OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'lverbose'}
                        Xobj.Lverbose=varargin{k+1};
                    case {'cov'}
                        Xobj.CoV=varargin{k+1};
                    case {'timeout'}
                        Xobj.timeout=varargin{k+1};
                    case {'nsamples'}
                        Xobj.Nsamples=varargin{k+1};
                    case {'conflevel'}
                        Xobj.confLevel=varargin{k+1};
                    case {'nbatches'}
                        Xobj.Nbatches=varargin{k+1};
                    case {'lexportsamples'}
                        Xobj.Lexportsamples=varargin{k+1};
                    case {'sbatchfolder'}
                        Xobj.SbatchFolder=varargin{k+1};
                    case {'lintermediateresults'}
                        Xobj.Lintermediateresults=varargin{k+1};
                    case {'sweightsname'}
                        Xobj.Sweightsname=varargin{k+1};
                    case {'cxrvsets','cxrvset'}
                        %
                        CrvnamesUD={};
                        for irvs=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{irvs},'opencossan.common.inputs.RandomVariableSet'), ...
                                'openCOSSAN:InportanceSampling',...
                                ['A RandomVariableSet object is required after to defined the proposal distribution. \n ' ...
                                ' at position ' num2str(irvs) ' of the field XrandomVariableSet']);
                            CrvnamesUD=[CrvnamesUD varargin{k+1}{irvs}.Cmembers]; %#ok<AGROW>
                        end
                        Xobj.XrvsetUD     = varargin{k+1};
                    case {'ccxrvsets'}
                        % This double cell array is required by the GUI.
                        CrvnamesUD={};
                        for irvs=1:length(varargin{k+1}{1})
                            assert(isa(varargin{k+1}{1}{irvs},'opencossan.common.inputs.RandomVariableSet'), ...
                                'openCOSSAN:InportanceSampling',...
                                ['A RandomVariableSet object is required after to defined the proposal distribution. \n ' ...
                                ' at position ' num2str(irvs) ' of the field XrandomVariableSet']);
                            CrvnamesUD=[CrvnamesUD varargin{k+1}{1}{irvs}.Cmembers]; %#ok<AGROW>
                        end
                        Xobj.XrvsetUD     = varargin{k+1}{1};
                    case 'cmapping'
                        Xobj.Cmapping=varargin{k+1};
                    case {'nseedrandomnumbergenerator'}
                        Nseed       = varargin{k+1};
                        Xobj.RandomNumberGenerator = ...
                            RandStream('mt19937ar','Seed',Nseed);
                    case {'xrandomnumbergenerator'}
                        assert(isa(varargin{k+1},'RandStream'),...
                            'openCOSSAN:ImportanceSampling',...
                           'Object of class %s not valid after Xrandomnumbergenerator',class(varargin{k}));
                        
                            Xobj.RandomNumberGenerator  = varargin{k+1};
                    case {'xdesignpoint','cxdesignpoint'}
                        if iscell(varargin{k+1})
                            % The GUI require to pass objects embedded in a
                            % cell array
                            Xdp=varargin{k+1}{1};
                        else
                            Xdp=varargin{k+1};
                        end
                        
                        Xobj = computeProposalDistribution(Xobj,Xdp);
                        
                    case 'lcomputedesignpoint'
                        % The proposal distribution is computed
                        % from the design point that will be computed on
                        % real-time.
                        Xobj.Lcomputedesignpoint=true;
                        OpenCossan.cossanDisp('Importance Sampling will computing automatically the design point',1)
                    otherwise
                        error('openCOSSAN:InportanceSampling',...
                            'The field name (%s) is not allowed',varargin{k});
                end
            end
            
            if Xobj.Nbatches>Xobj.Nsamples
                error('openCOSSAN:InportanceSampling',...
                    ['The number of batches (' num2str(Xobj.Nbatches) ...
                    ') can not be greater than the number of samples (' ...
                    num2str(Xobj.Nsamples) ')' ]);
            end
            
            
            if ~Xobj.Lcomputedesignpoint && ~exist('Xdp','var')
                %% Check if the proposal distribution has been defined
                assert(~isempty(Xobj.XrvsetUD), ...
                    'openCOSSAN:InportanceSampling',...
                    'A proposal distribution is required to initialize the ImportanceSampling object or the flag LcomputeDesingPoint must be set to true.');
                
                %% Check the Cmapping
                assert(size(Xobj.Cmapping,2)==2, ...
                    'openCOSSAN:InportanceSampling',...
                    'The Cmapping cell array must contains 2 columns');
                
                for irv=1:size(Xobj.Cmapping,1)
                    assert(any(strcmp(Xobj.Cmapping(irv,1),CrvnamesUD)), ...
                        'openCOSSAN:InportanceSampling',...
                        ['The variable ' Xobj.Cmapping{irv,1} ' defined in the Cmapping is not present in the Importance sampling density']);
                end
                
            end
            
        end % constructor
        
    end % methods
    
end

