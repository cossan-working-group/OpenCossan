classdef SubsetOriginal < opencossan.simulations.Simulations
    % SUBSET simulation class.  Subset Simulation is a simulation method to compute small (i.e.,
    % rare event) failure probabilities encountered in engineering systems. The basic idea is to
    % express a small failure probability as a product of larger conditional probabilities by
    % introducing intermediate failure events. This conceptually converts the original rare event
    % problem into a series of frequent event problems that are easier to solve.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@Subset
    %
    % Author: Edoardo Patelli Institute for Risk and Uncertainty, University of Liverpool, UK email
    % address: openengine@cossan.co.uk Website: http://www.cossan.co.uk
    
    % ===================================================================== This file is part of
    % openCOSSAN.  The open general purpose matlab toolbox for numerical analysis, risk and
    % uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify it under the terms of the
    % GNU General Public License as published by the Free Software Foundation, either version 3 of
    % the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    % without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
    % the GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License along with openCOSSAN.  If
    %  not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    properties (SetAccess = protected)
        % Target intermediate pf
        TargetProbabilityOfFailure(1,1) double {mustBePositive, ...
            mustBeLessThanOrEqual(TargetProbabilityOfFailure, 1)} = 0.1
        % Maximum number of levels
        MaxLevels(1,1) {mustBeInteger} = 10;
        % Width for the uniform proposal distribution bounds = [-deltaxi, deltaxi]
        DeltaXi(1,:) double {mustBePositive} = 0.5
        InitialSamples(1,1) {mustBeInteger} % initial samples
        ExportSamples(1,1) logical = false; % Flag to export the computed samples
        KeepSeeds(1,1) logical = true;       % if true, keeps the seeds for the next level
    end
    
    properties (Dependent = true)
        TargetCoV              % target coefficient of variation (CoV) of the intermediate results
        NumberOfChains   % Number of Markov Chains in the last batch
        SamplesPerChain      % Number of states for each  Markov Chain
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
        
        [Xpf,XsimOut] = computeFailureProbability(Xobj,Xtarget)
        
        %% constructor
        function obj = SubsetOriginal(varargin)
            % SUBSET constructor. This function constructs a Subset Simulation object.
            %
            % Subset object is used to compute small (i.e., rare event) failure probabilities
            % encountered in engineering systems. The basic idea is to express a small failure
            % probability as a product of larger conditional probabilities by introducing
            % intermediate failure events.
            %
            % See also: https://cossan.co.uk/wiki/index.php/@Subset
            
            if nargin == 0
                return
            else
                [optional, ~] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["initialsamples", "targetprobabilityoffailure", "maxlevels", "deltaxi", ...
                     "exportsamples", "keepseeds"], {[], 0.1, 10, 0.5, false, true}, varargin{:});
            end
            
            % TODO: Call super constructor once it exists
            % obj@opencossan.simulations.Simulations(super_args{:});
            
            if nargin > 0
                obj.TargetProbabilityOfFailure = optional.targetprobabilityoffailure;
                obj.MaxLevels = optional.maxlevels;
                obj.DeltaXi = optional.deltaxi;
                obj.ExportSamples = optional.exportsamples;
                obj.KeepSeeds = optional.keepseeds;
                
                if ~isempty(optional.initialsamples)
                    obj.InitialSamples = optional.initialsamples;
                else
                    obj.InitialSamples = floor(1/obj.TargetProbabilityOfFailure);
                end
            end
        end
        
        function chains = get.NumberOfChains(obj)
            chains = max(1, ceil(obj.InitialSamples * obj.TargetProbabilityOfFailure));
        end
        
        function samples = get.SamplesPerChain(obj)
            samples = floor(obj.InitialSamples / obj.NumberOfChains);
        end
        
        function target_cov = get.TargetCoV(obj)
            target_cov = sqrt((1-obj.TargetProbabilityOfFailure)/(obj.TargetProbabilityOfFailure*obj.Initialsamples) );
        end
        
        function samples = sample(obj, varargin)
        end
    end
end


