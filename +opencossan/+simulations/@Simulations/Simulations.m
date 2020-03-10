classdef (Abstract) Simulations < opencossan.common.CossanObject
    % Abstract class for creating simulations methods
    % Subclass constructor should accept
    % property name/property value pairs
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/@Simulation
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
        % Termination criteria coefficient of variation (CoV) (0= no termination criteria adopted)
        CoV(1,1) double {mustBeNonnegative} = 0;    
        % Termination criteria Time in seconds  (0= no termination criteria adopted)
        Timeout(1,1) double {mustBeNonnegative} = 0;           
        % Termination criteria Nsamples (0= no termination criteria adopted)
        NumberOfSamples(1,1) {mustBeInteger} = 1;
        % RandStream to use for the simulation
        RandomStream; 
    end
    
    properties (Hidden, SetAccess = protected)
        StartTime; % Store the start time of the simulation
        ResultFolder;
    end
    
    methods
        function obj = Simulations(varargin)
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["samples", "timeout", "cov", "randomstream", "seed"], {1, 0, 0, [], []}, varargin{:});
            end
            
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.NumberOfSamples = optional.samples;
                obj.Timeout = optional.timeout;
                obj.CoV = optional.cov;
                
                assert(isempty(optional.randomstream) || isempty(optional.seed), ...
                    'OpenCossan:Simulations', "You can not specify both a RandomStream and a Seed");
                
                if ~isempty(optional.randomstream)
                    obj.RandomStream = optional.randomstream;
                end
                
                if ~isempty(optional.seed)
                    obj.RandomStream = RandStream('mt19937ar','Seed', optional.seed);
                end
            end
        end
    end
    
    methods (Abstract)        
        pf = computeFailureProbability(Xobj, model)        
        samples = sample(obj, varargin)
    end
    
    methods (Access = protected)
        [exit, flag] = checkTermination(obj, varargin);
        exportResult(obj, pf);
        obj = initialize(obj);
    end
end


