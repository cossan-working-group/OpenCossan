classdef HaltonSampling < opencossan.simulations.MonteCarlo
    %HaltonSampling class
    %   Haltonset is a quasi-random point set class that produces points
    %   from the Halton sequence.
    %   This class is based on the Haltonset Matlab class
    %   These sequences use different prime bases to form successively
    %   finer uniform partitions of the unit interval in each dimension.
    
    properties
        % Number of initial points in sequence to omit
        Skip(1,1) {mustBeInteger, mustBeNonnegative} = 1;
        % Interval between points
        Leap(1,1) {mustBeInteger, mustBeNonnegative} = 0;
        % Flag to apply reverse-radix scrambling
        Scramble(1,1) logical = false;
    end
    
    methods
        function obj = HaltonSampling(varargin)
            %HALTONSAMPLING
            
            if nargin == 0
                super_args = {};
            else
                [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["skip", "leap"], varargin{:});
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    "scramble", {false}, varargin{:});
            end
            
            obj@opencossan.simulations.MonteCarlo(super_args{:});
            
            if nargin > 0
                obj.Skip = required.skip;
                obj.Leap = required.leap;
                obj.Scramble = optional.scramble;
            end
        end
    end
end

