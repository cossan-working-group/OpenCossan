classdef SubsetOutput < opencossan.common.outputs.SimulationData
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
        IntermediateFailureProbabilites(1,:) double;
        IntermediateCoVs(1,:) double;
        RejectionRates(1,:) double;
        Thresholds(1,:) double;
    end
    
    properties (Dependent = true, SetAccess = protected)
        VsamplesLevel             % Number of samples x level
        Nlevels                   % Number of levels        
    end
    
    methods
        
        function obj=SubsetOutput(varargin)
            %SUBSETOUTPUT This method constructs an object of class
            %SubsetOutput that is a subclass of a SimulationData object
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
            
            CsubsetArguments={'subsetFailureProbability', ...
                'subsetCoV','rejectRate',...
                'subsetPerformance','subsetSamples',...
                'performanceFunctionName',...
                'subsetThreshold','rejectedSamplesIndices','replacedSamplesIndices'};
            
            
            %% Construct SimulationData
            % Remove input only for the object SubsetOutput
            % It is not necessarty to validate the inputs because they will
            % be validate by the superclass
            
            % Find arguments Specific for the SubsetOutput
            LargSimulationData=false(1,length(varargin));
            for k=1:2:length(varargin)
                if ismember(lower(varargin{k}),CsubsetArguments)
                    LargSimulationData(k:k+1)=true;
                end
            end
            
            obj=obj@opencossan.common.outputs.SimulationData(varargin{LargSimulationData});
            
            %% Process inputs for the subclass 
            % Removed already processed inputs 
            varargin(LargSimulationData)=[];
            % Check parameters specific for this class
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'performancefunctionname'}
                        obj.performanceFunctionName=varargin{k+1};
                    case {'subsetfailureprobability'}
                        obj.subsetFailureProbability = varargin{k+1};
                    case {'subsetperformance'}
                         obj.subsetPerformance = varargin{k+1};
                    case {'subsetcov'}
                         obj.subsetCoV = varargin{k+1};
                    case {'subsetthreshold'}
                        obj.subsetThreshold = varargin{k+1};
                    case {'subsetsamples'}
                        obj.subsetSamples = varargin{k+1}; 
                    case {'rejectionrates'}
                        obj.rejectionRates = varargin{k+1};                    
                    case {'rejectedsamplesindices'}
                        obj.rejectedSamplesIndices = varargin{k+1};
                    case {'replacedsamplesindices'}
                        obj.replacedSamplesIndices = varargin{k+1};
                    case {'seedsindices'}
                        obj.seedsIndices = varargin{k+1};
                    case {'initialsamples'}
                        obj.initialSamples = varargin{k+1};
                    case {'markovchainsamples'}
                        obj.markovchainsamples = varargin{k+1};
                    case {'chainindices'}
                        obj.chainIndices=varargin{k+1};
                    case {'markovchains'}    
                        obj.markovchains = varargin{k+1};
                    otherwise
                        error('openCOSSAN:SubsetOutput:wrongArgmument',...
                            'The argument %s is not valid!',varargin{k})
                end
            end

            % Validate inputs
            
            assert(all([length(obj.subsetFailureProbability)==length(obj.subsetCoV), ... 
                  length(obj.subsetFailureProbability)==length(obj.subsetThreshold), ...
                  length(obj.subsetFailureProbability)==length(obj.rejectionRates)]), ...
                  'openCOSSAN:SubsetOutput',...
                  ['The fields subsetFailureProbability, subsetCoV, subsetThreshold and ',...
                  ' rejectionRates must be vectors of same length.\n* Defined lengths: %i %i %i %i'],...
                  length(obj.subsetFailureProbability),length(obj.subsetCoV),...
                  length(obj.subsetThreshold),length(obj.rejectionRates));
            
        end % end constructor
        
        Xobj = merge(Xobj,Xobj2)
        
        % Plot Subset levels
        varargout=plotMarkovChains(Xobj,varargin)
        varargout=plotLevels(Xobj,varargin)
        
        function VsamplesLevel =get.VsamplesLevel(Xobj)
            % New samples generated x level 
            Vnewsample(1:length(Xobj.subsetThreshold)-1)= (Xobj.markovchainsamples-1)*Xobj.markovchains;
            VsamplesLevel=[Xobj.initialSamples Vnewsample];
        end
        
        function Nlevels =get.Nlevels(Xobj)
            % Number of levels
            Nlevels=size(Xobj.chainIndices,3);
        end
    end
    
end
