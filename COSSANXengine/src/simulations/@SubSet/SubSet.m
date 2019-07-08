classdef SubSet < Simulations
    % SUBSET simulation class.  Subset Simulation is a simulation method
    % to compute small (i.e., rare event) failure probabilities encountered
    % in engineering systems.
    % The basic idea is to express a small failure probability as a product
    % of larger conditional probabilities by introducing intermediate
    % failure events. This conceptually converts the original rare event
    % problem into a series of frequent event problems that are easier to
    % solve.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@Subset
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
    
    properties (SetAccess = protected)
        Ntarget_pf=0.1          % target intermediate pF (default: 1e-1)
        Nmaxlevels=10           % maximum no. of levels (default: 10)
        Vdeltaxi=0.5,           % vector of width parameters for proposal distribution
        XproposedDistributionSet% RandomVariableSet with proposal distribution
        NinitialSamples         % initial samples
        NinitialSimxBatch       % number of initial samples per batch
        NinitialSimLastBatch    % number of initial samples in the last batch
        LexportSamples          % Flag to export the computed samples
        VproposalStd            % Vector of chosen standard deviation (using Subset-infinity) 
    end
    
    properties (Dependent = true, SetAccess = protected)
        Ntarget_cov             % target coefficient of variation (CoV) of the intermediate results
        Nmarkovchainssimxbatch  % Number of Markov Chains per batch
        Nmarkovchainslastbatch  % Number of Markov Chains in the last batch
        Nmarkovchainsamples     % Number of states for each  Markov Chain
    end
    
    methods
        
        %% Methods inheritated from the superclass
        
        %APPLY This method can not be used with SubSet simulation
        function Xo=apply(Xobj,~)    %#ok<INUSD,STOUT>
            error('openCOSSAN:simulations:subset:apply',...
                strcat('The method apply is not available for SubSet simulation objects!\n', ...
                'Subset simulation required the computation of a conditional events (e.g. failure probability).\n', ...
                'Please use computeFailureProbability to estimate the failure probability'))
        end
        
        
        %COMPUTEFAILUREPROBABILITY Compute the failure probability associated to the
        % ProbabilisticModel/SystemReliability
        [Xpf,XsimOut]=computeFailureProbability(Xobj,Xtarget)
        
        %SAMPLE Generate samples in the unit hypercube space associated to the
        % ProbabilisticModel/SystemReliability
        Xsamples=sample(Xobj,varargin)
        
        %DISPLAY This method shows the summary of a SubSet object
        display(Xobj)
        
        
        
        %% constructor
        function Xobj= SubSet(varargin)
            % SUBSET contractor. This function construct a Subset Simulation
            % object.
            %
            % Subset object is used to compute small (i.e., rare event) failure
            % probabilities encountered in engineering systems.
            % The basic idea is to express a small failure probability as a
            % product of larger conditional probabilities by introducing
            % intermediate failure events.
            %
            % See also: https://cossan.co.uk/wiki/index.php/@Subset
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
            
            %% Validate input arguments
            OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'cov'}
                        error('openCOSSAN:simulations:SubSet',...
                            'Subset simulation can not be performed with a target CoV')
                    case {'timeout'}
                        Xobj.timeout=varargin{k+1};
                    case {'nsamples'}
                        Xobj.Nsamples=varargin{k+1};
                    case {'conflevel','levelofconfidence'}
                        Xobj.confLevel=varargin{k+1};
                    case {'nbatches'}
                        Xobj.Nbatches=varargin{k+1};
                    case {'lexportsamples'}
                        Xobj.LexportSamples=varargin{k+1};
                    case {'lintermediateresults'}
                        Xobj.Lintermediateresults=varargin{k+1};
                    case {'target_pf','targetfailureprobability'}
                        Xobj.Ntarget_pf=varargin{k+1};
                    case {'nmaxlevels'}
                        Xobj.Nmaxlevels=varargin{k+1};
                    case {'ninitialsamples'}
                        Xobj.NinitialSamples =varargin{k+1};
                    case {'vdeltaxi'}
                        Xobj.Vdeltaxi=varargin{k+1};
                    case {'xproposeddistributionset'}
                        Xobj.XproposedDistributionSet=varargin{k+1};
                    case {'vproposalstd','vproposalstandarddeviation'}
                        assert(all(varargin{k+1}>=0) & all(varargin{k+1})<=1,...
                            'openCOSSAN:SubSet:wrongVproposalStd', ...
                            'Proposal standard deviation should be >=0 and <=1')
                        Xobj.VproposalStd=varargin{k+1};
                    case {'nseedrandomnumbergenerator'}
                        Nseed       = varargin{k+1};
                        Xobj.RandomNumberGenerator = ...
                            RandStream('mt19937ar','Seed',Nseed);
                    case {'xrandomnumbergenerator'}
                        if isa(varargin{k+1},'RandStream'),
                            Xobj.RandomNumberGenerator  = varargin{k+1};
                        else
                            error('openCOSSAN:SubSet:wrongRandomNumberGenerator',...
                                'argument associated with %s is a class %s\nRequired object type: RandStream' ,...
                                varargin{k},class(varargin{k+1}));
                        end
                    otherwise
                        error('openCOSSAN:SubSet:wrongArgument',...
                            'Propety name %s is not allowed in Subset',varargin{k});
                end
            end 
            
            %% Define simulation parameters

            % Initial samples 
            if isempty(Xobj.NinitialSamples)
                Xobj.NinitialSamples=floor(1/(Xobj.Ntarget_pf^2)*Xobj.Nbatches);
            end
            
            % Initial samples for each batch
            Xobj.NinitialSimxBatch = floor(Xobj.NinitialSamples/Xobj.Nbatches);
            % Initial samples for the last batch
            Xobj.NinitialSimLastBatch =  Xobj.NinitialSamples-Xobj.NinitialSimxBatch*(Xobj.Nbatches-1);
            
            
            
            %compute no. of samples based on specified pF of each level, pFl, and on associated CoV
            %
            % Based on eq. 19 covFl=sqrt( (1-pFl)/(pFl*N) )
            
            %
            %             if Xobj.Nsamples<Xobj.NinitialSamples*Xobj.Nmaxlevels
            %                warning('openCOSSAN:simulations:SubSet',...
            %                     'Nsamples is lower then NinitialSamples*Nmaxlevels. \n Nsamples will be not used as Termination Criteria ');
            %             end
            
            %% Verify consistency of the inputs
            
            % Check NinitialSimxBatch
            if Xobj.Ntarget_pf*Xobj.NinitialSimxBatch<1
                Xobj.NinitialSimxBatch=1/Xobj.Ntarget_pf;
                warning('openCOSSAN:simulations:SubSet',...
                    ['The number of initial samples  (NinitialSimxBatch) has been reset to '...
                    num2str(Xobj.NinitialSamples) ]);
            end
                        
            %set number of initial samples in order to have an inter number
            %of Markov Chain
            if floor(Xobj.Ntarget_pf*Xobj.NinitialSimxBatch) ~= Xobj.Ntarget_pf*Xobj.NinitialSimxBatch
                Xobj.NinitialSimxBatch=floor(ceil(Xobj.NinitialSimxBatch*Xobj.Ntarget_pf)/Xobj.Ntarget_pf);
                warning('openCOSSAN:simulations:SubSet',...
                    ['The parameter Ninitialsamples has been reset to ' ...
                    num2str(Xobj.NinitialSimxBatch*(Xobj.Nbatches-1)+Xobj.NinitialSimLastBatch) ...
                    ' (NinitialSimxBatch']);
            end
            
            % Check NinitialSimLastBatch
            if Xobj.Ntarget_pf*Xobj.NinitialSimLastBatch<1
                Xobj.NinitialSimLastBatch=1/Xobj.Ntarget_pf;
                warning('openCOSSAN:simulations:SubSet',...
                    ['The number of initial samples has been reset to '...
                    num2str(Xobj.NinitialSimxBatch*(Xobj.Nbatches-1)+Xobj.NinitialSimLastBatch) ...
                    ' (NinitialSimLastBatch) ']);
            end
            
            if floor(Xobj.Ntarget_pf*Xobj.NinitialSimLastBatch) ~= Xobj.Ntarget_pf*Xobj.NinitialSimLastBatch
                Xobj.NinitialSimLastBatch=floor(ceil(Xobj.NinitialSimLastBatch*Xobj.Ntarget_pf)/Xobj.Ntarget_pf);
                warning('openCOSSAN:simulations:SubSet',...
                    ['The parameter Ninitialsamples has been reset to ' ...
                    num2str(Xobj.NinitialSimxBatch*(Xobj.Nbatches-1)+Xobj.NinitialSimLastBatch) ...
                    ' (NinitialSimLastBatch) ']);
            end
            
        end % constructor
        
    end % methods
    
    
    methods
        function Nmarkovchainslastbatch = get.Nmarkovchainslastbatch(Xobj)
            Nmarkovchainslastbatch=max(1,ceil(Xobj.NinitialSimLastBatch*Xobj.Ntarget_pf));
        end % end function get Nmarkovchainslastbatch
        
        function Nmarkovchainssimxbatch = get.Nmarkovchainssimxbatch(Xobj)
            Nmarkovchainssimxbatch=max(1,ceil(Xobj.NinitialSimxBatch*Xobj.Ntarget_pf));
        end % end function get Nmarkovchains
        
        function Nmarkovchainsamples = get.Nmarkovchainsamples(Xobj)
            Nmarkovchainsamples=floor(Xobj.NinitialSimxBatch/Xobj.Nmarkovchainssimxbatch);
        end % end function get Nmarkovchainsamples
        
        function Ntarget_cov = get.Ntarget_cov(Xobj)
            Ntarget_cov=sqrt( (1-Xobj.Ntarget_pf)/(Xobj.Ntarget_pf*Xobj.Ninitialsamples) );
        end % end function get Ntarget_cov
        
        function Xobj =setinitialsample(Xobj,Nvalue)
            Xobj.Nsamples=Nvalue*Xobj.Nmaxlevels;
        end
    end
end

