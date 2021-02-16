classdef SubsetOutput < SimulationData
    %SubsetOutput class containing speific outputs of the
    %Subset simulation method
    %
    % See also:
    % http://cossan.co.uk/wiki/index.php/SubsetOutput
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
        VsubsetFailureProbability % array containing the intermediary failure probabilities
        VsubsetCoV                % array containing the intermediary CoV
        VrejectionRates           % array containing the rejection rates
        SperformanceFunctionName  % name of the output of the PerformanceFunction
        VsubsetThreshold          % array containing the intermediary performance function thresholds
        VsubsetPerformance        % array containing the values of the performance functions (only accepted samples)
        VseedsIndices             % Indices of the performance function used as seeds
        MsubsetSamples            % Array of only the accepted samples
        MchainIndices             % Array of Markov Chain indices
        VrejectedSamplesIndices   % Vector containing the position of rejected samples
        NinitialSamples           % Number of initial samples
        Nmarkovchainsamples       % Number of states for each  Markov Chain
        Nmarkovchains             % Number of Markov Chains
    end
    
    properties (Dependent = true, SetAccess = protected)
        VsamplesLevel             % Number of samples x level
        Nlevels                   % Number of levels        
    end
    
    methods
        
        function Xobj=SubsetOutput(varargin)
            % See also:
            % http://cossan.co.uk/wiki/index.php/SubsetOutput
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
            
            CsubsetArguments={'VsubsetFailureProbability', ...
                'VsubsetCoV','VrejectRate',...
                'VsubsetPerformance','MsubsetSamples','MchainIndices',...
                'SperformanceFunctionName',...
                'VsubsetThreshold','VrejectedSamplesIndices',...
                'VreplacedSamplesIndices','VseedsIndices','VrejectionRates',...
                'Nmarkovchains','NinitialSamples','Nmarkovchainsamples'};
            
            %% Construct SimulationData
            % Remove input only for the object SubsetOutput
            % It is not necessarty to validate the inputs because they will
            % be validate by the superclass
            
            % Find arguments Specific for the SubsetOutput
            LargSimulationData=false(1,length(varargin));
            for k=1:2:length(varargin)
                if ~ismember(lower(varargin{k}),lower(CsubsetArguments))
                    LargSimulationData(k:k+1)=true;
                end
            end
            
            Xobj=Xobj@SimulationData(varargin{LargSimulationData});
            
            %% Process inputs for the subclass 
            % Removed already processed inputs 
            varargin(LargSimulationData)=[];
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sperformancefunctionname'}
                        Xobj.SperformanceFunctionName=varargin{k+1};
                    case {'vsubsetfailureprobability'}
                        Xobj.VsubsetFailureProbability = varargin{k+1};
                    case {'vsubsetperformance'}
                         Xobj.VsubsetPerformance = varargin{k+1};
                    case {'vsubsetcov'}
                         Xobj.VsubsetCoV = varargin{k+1};
                    case {'vsubsetthreshold'}
                        Xobj.VsubsetThreshold = varargin{k+1};
                    case {'msubsetsamples'}
                        Xobj.MsubsetSamples = varargin{k+1}; 
                    case {'vrejectionrates'}
                        Xobj.VrejectionRates = varargin{k+1};                    
                    case {'vrejectedsamplesindices'}
                        Xobj.VrejectedSamplesIndices = varargin{k+1};
                    case {'vreplacedsamplesindices'}
                        Xobj.VreplacedSamplesIndices = varargin{k+1};
                    case {'vseedsindices'}
                        Xobj.VseedsIndices = varargin{k+1};
                    case {'ninitialsamples'}
                        Xobj.NinitialSamples = varargin{k+1};
                    case {'nmarkovchainsamples'}
                        Xobj.Nmarkovchainsamples = varargin{k+1};
                    case {'mchainindices'}
                        Xobj.MchainIndices=varargin{k+1};
                    case {'nmarkovchains'}    
                        Xobj.Nmarkovchains = varargin{k+1};
                    otherwise
                        error('OpenCossan:SubsetOutput:wrongArgument',...
                             'PropertyName %s is not valid ', varargin{k});
                end
            end 

            % Validate inputs
            
            assert(all([length(Xobj.VsubsetFailureProbability)==length(Xobj.VsubsetCoV), ... 
                  length(Xobj.VsubsetFailureProbability)==length(Xobj.VsubsetThreshold), ...
                  length(Xobj.VsubsetFailureProbability)==length(Xobj.VrejectionRates)]), ...
                  'openCOSSAN:SubsetOutput',...
                    'The fields VsubsetFailureProbability, VsubsetCoV VsubsetThreshold and VrejectionRates must be vectors of same length');
            
        end % end constructor
        
        Xobj = merge(Xobj,Xobj2)
        
        % Plot Subset levels
        varargout=plotMarkovChains(Xobj,varargin)
        varargout=plotLevels(Xobj,varargin)
        
        
        dsiplay(Xobj)
        
        function VsamplesLevel =get.VsamplesLevel(Xobj)
            % New samples generated x level 
            Vnewsample(1:length(Xobj.VsubsetThreshold)-1)= (Xobj.Nmarkovchainsamples-1)*Xobj.Nmarkovchains;
            VsamplesLevel=[Xobj.NinitialSamples Vnewsample];
        end
        
        function Nlevels =get.Nlevels(Xobj)
            % Number of levels
            Nlevels=size(Xobj.MchainIndices,3);
        end
    end
    
end
