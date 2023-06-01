classdef SubsetOriginal < opencossan.simulations.Simulations
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
        target_pf=0.1           % target intermediate pF (default: 1e-1)
        maxlevels=10            % maximum no. of levels (default: 10)
        deltaxi=0.5,            % vector of width parameters for proposal distribution
        proposedDistributionSet % RandomVariableSet with proposal distribution
        initialSamples          % initial samples
        initialSimxBatch        % number of initial samples per batch
        initialSimLastBatch     % number of initial samples in the last batch
        exportSamples           % Flag to export the computed samples
        KeepSeeds = true;       % if true, keeps the seeds for the next level
    end
    
    properties (Dependent = true, SetAccess = protected)
        target_cov              % target coefficient of variation (CoV) of the intermediate results
        markovchainssimxbatch   % Number of Markov Chains per batch
        markovchainslastbatch   % Number of Markov Chains in the last batch
        markovchainsamples      % Number of states for each  Markov Chain
    end
    
    methods
        
        %% Methods inheritated from the superclass
        
        %APPLY This method can not be used with SubSet simulation
        function Xo=apply(Xobj,~)    %#ok<INUSD,STOUT>
            error('openCOSSAN:simulations:subsetoriginal:apply',...
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
        
        
        
        %% constructor
        function Xobj= SubsetOriginal(varargin)
            % SUBSET constructor. This function constructs a Subset Simulation
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
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'cov'}
                        error('openCOSSAN:simulations:SubsetOriginal',...
                            'Subset simulation can not be performed with a target CoV')
                    case {'timeout'}
                        Xobj.timeout=varargin{k+1};
                    case {'nsamples'}
                        Xobj.Nsamples=varargin{k+1};
                    case {'conflevel','levelofconfidence'}
                        Xobj.confLevel=varargin{k+1};
                    case {'nbatches'}
                        Xobj.Nbatches=varargin{k+1};
                    case {'exportsamples'}
                        Xobj.exportSamples=varargin{k+1};
                    case {'lintermediateresults'}
                        Xobj.Lintermediateresults=varargin{k+1};
                    case {'target_pf','targetfailureprobability'}
                        Xobj.target_pf=varargin{k+1};
                    case {'maxlevels'}
                        Xobj.maxlevels=varargin{k+1};
                    case {'initialsamples'}
                        Xobj.initialSamples =varargin{k+1};
                    case {'deltaxi'}
                        Xobj.deltaxi=varargin{k+1};
                    case {'proposeddistributionset'}
                        Xobj.proposedDistributionSet=varargin{k+1};
                    case {'nseedrandomnumbergenerator'}
                        Nseed       = varargin{k+1};
                        Xobj.RandomNumberGenerator = ...
                            RandStream('mt19937ar','Seed',Nseed);
                    case {'keepseeds'}
                        Xobj.KeepSeeds = varargin{k+1};
                    case {'xrandomnumbergenerator'}
                        if isa(varargin{k+1},'RandStream'),
                            Xobj.RandomNumberGenerator  = varargin{k+1};
                        else
                            error('openCOSSAN:SubsetOriginal:wrongRandomNumberGenerator',...
                                'argument associated with %s is a class %s\nRequired object type: RandStream' ,...
                                varargin{k},class(varargin{k+1}));
                        end
                    otherwise
                        error('openCOSSAN:SubsetOriginal:wrongArgument',...
                            'Propety name %s is not allowed in Subset',varargin{k});
                end
            end 
            
            if isempty(Xobj.initialSamples)
                error('openCOSSAN:SubsetOriginal:missingArgument',...
                    'SubsetOriginal needs an initial number of samples');
            end
            
            %% Define simulation parameters

            % Initial samples 
            if isempty(Xobj.initialSamples)
                Xobj.initialSamples=floor(1/(Xobj.target_pf^2)*Xobj.Nbatches);
            end
            
            % Initial samples for each batch
            Xobj.initialSimxBatch = floor(Xobj.initialSamples/Xobj.Nbatches);
            % Initial samples for the last batch
            Xobj.initialSimLastBatch =  Xobj.initialSamples-Xobj.initialSimxBatch*(Xobj.Nbatches-1);
            
            
            
            %compute no. of samples based on specified pF of each level, pFl, and on associated CoV
            %
            % Based on eq. 19 covFl=sqrt( (1-pFl)/(pFl*N) )
            
            %
            %             if Xobj.Nsamples<Xobj.initialSamples*Xobj.maxlevels
            %                warning('openCOSSAN:simulations:SubsetOriginal',...
            %                     'Nsamples is lower then initialSamples*maxlevels. \n Nsamples will be not used as Termination Criteria ');
            %             end
            
            %% Verify consistency of the inputs
            
            % Check initialSimxBatch
            if Xobj.target_pf*Xobj.initialSimxBatch<1
                Xobj.initialSimxBatch=1/Xobj.target_pf;
                warning('openCOSSAN:simulations:SubsetOriginal',...
                    ['The number of initial samples  (initialSimxBatch) has been reset to '...
                    num2str(Xobj.initialSamples) ]);
            end
                        
            %set number of initial samples in order to have an inter number
            %of Markov Chain
            if floor(Xobj.target_pf*Xobj.initialSimxBatch) ~= Xobj.target_pf*Xobj.initialSimxBatch
                Xobj.initialSimxBatch=floor(ceil(Xobj.initialSimxBatch*Xobj.target_pf)/Xobj.target_pf);
                warning('openCOSSAN:simulations:SubsetOriginal',...
                    ['The parameter initialsamples has been reset to ' ...
                    num2str(Xobj.initialSimxBatch*(Xobj.Nbatches-1)+Xobj.initialSimLastBatch) ...
                    ' (initialSimxBatch']);
            end
            
            % Check initialSimLastBatch
            if Xobj.target_pf*Xobj.initialSimLastBatch<1
                Xobj.initialSimLastBatch=1/Xobj.target_pf;
                warning('openCOSSAN:simulations:SubsetOriginal',...
                    ['The number of initial samples has been reset to '...
                    num2str(Xobj.initialSimxBatch*(Xobj.Nbatches-1)+Xobj.initialSimLastBatch) ...
                    ' (initialSimLastBatch) ']);
            end
            
            if floor(Xobj.target_pf*Xobj.initialSimLastBatch) ~= Xobj.target_pf*Xobj.initialSimLastBatch
                Xobj.initialSimLastBatch=floor(ceil(Xobj.initialSimLastBatch*Xobj.target_pf)/Xobj.target_pf);
                warning('openCOSSAN:simulations:SubsetOriginal',...
                    ['The parameter initialsamples has been reset to ' ...
                    num2str(Xobj.initialSimxBatch*(Xobj.Nbatches-1)+Xobj.initialSimLastBatch) ...
                    ' (initialSimLastBatch) ']);
            end
            
        end % constructor
        
    end % methods
    
    
    methods
        function markovchainslastbatch = get.markovchainslastbatch(Xobj)
            markovchainslastbatch=max(1,ceil(Xobj.initialSimLastBatch*Xobj.target_pf));
        end % end function get markovchainslastbatch
        
        function markovchainssimxbatch = get.markovchainssimxbatch(Xobj)
            markovchainssimxbatch=max(1,ceil(Xobj.initialSimxBatch*Xobj.target_pf));
        end % end function get markovchains
        
        function markovchainsamples = get.markovchainsamples(Xobj)
            markovchainsamples=floor(Xobj.initialSimxBatch/Xobj.markovchainssimxbatch);
        end % end function get markovchainsamples
        
        function target_cov = get.target_cov(Xobj)
            target_cov=sqrt( (1-Xobj.target_pf)/(Xobj.target_pf*Xobj.initialsamples) );
        end % end function get target_cov
        
        function Xobj =setinitialsample(Xobj,Nvalue)
            Xobj.Nsamples=Nvalue*Xobj.maxlevels;
        end
    end
end


