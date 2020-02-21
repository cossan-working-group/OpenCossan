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
        % Target intermediate pf
        TargetProbabilityOfFailure(1,1) double {mustBePositive, ...
            mustBeLessThanOrEqual(TargetProbabilityOfFailure, 1)} = 0.1
        % Maximum number of levels
        MaxLevels(1,1) {mustBeInteger} = 10;
        % Width for the uniform proposal distribution bounds = [-deltaxi, deltaxi]
        deltaxi(1,1) double {mustBePositive} = 0.5
        proposedDistributionSet % RandomVariableSet with proposal distribution
        InitialSamples          % initial samples
        exportSamples           % Flag to export the computed samples
        KeepSeeds = true;       % if true, keeps the seeds for the next level
    end
    
    properties (Dependent = true, SetAccess = protected)
        TargetCoV              % target coefficient of variation (CoV) of the intermediate results
        MarkovChains   % Number of Markov Chains in the last batch
        MarkovChainSamples      % Number of states for each  Markov Chain
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
                        Xobj.TargetProbabilityOfFailure=varargin{k+1};
                    case {'maxlevels'}
                        Xobj.MaxLevels=varargin{k+1};
                    case {'initialsamples'}
                        Xobj.InitialSamples =varargin{k+1};
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
            
            %compute no. of samples based on specified pF of each level, pFl, and on associated CoV
            %
            % Based on eq. 19 covFl=sqrt( (1-pFl)/(pFl*N) )
            
            %
            %             if Xobj.Nsamples<Xobj.initialSamples*Xobj.maxlevels
            %                warning('openCOSSAN:simulations:SubsetOriginal',...
            %                     'Nsamples is lower then initialSamples*maxlevels. \n Nsamples will be not used as Termination Criteria ');
            %             end
        end % constructor
        
    end % methods
    
    
    methods        
        function chains = get.MarkovChains(obj)
            chains = max(1, ceil(obj.InitialSamples * obj.TargetProbabilityOfFailure));
        end
        
        function samples = get.MarkovChainSamples(Xobj)
            samples = floor(Xobj.InitialSamples / Xobj.MarkovChains);
        end
        
        function target_cov = get.TargetCoV(Xobj)
            target_cov = sqrt((1-Xobj.TargetProbabilityOfFailure)/(Xobj.TargetProbabilityOfFailure*Xobj.Initialsamples) );
        end
        
        function Xobj =setinitialsample(Xobj,Nvalue)
            Xobj.Nsamples = Nvalue * Xobj.maxlevels;
        end
    end
end


