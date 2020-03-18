classdef FailureProbability < opencossan.common.CossanObject
    %FailureProbability This class define teh FailureProbability Output.
    %   The object contains the failure probability (pf) estimated by
    %   simulation methods.
    
    properties (SetAccess = protected)
        Value(1,1) double {mustBeNonnegative, mustBeLessThanOrEqual(Value, 1)};
        Variance(1,1) double {mustBeNonnegative};
        SimulationData opencossan.common.outputs.SimulationData;
        Simulation
    end
    
    properties (Dependent)
        ExitFlag;
        CoV;
    end
    
    methods
        
        function obj = FailureProbability(varargin)
            % FAILUREPROBABILITY This method initializes the FailureProbability
            % object
            %
            % See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/@FailureProbability
            
            import opencossan.*
            
            %% Process the inputs
            if nargin == 0
                super_args = {};
            else
                [required, super_args] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["value", "simulationdata", "simulation", "variance"], varargin{:});
            end
            
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.Value = required.value;
                obj.SimulationData = required.simulationdata;
                obj.Simulation = required.simulation;
                obj.Variance = required.variance;
            end
        end
        
        function flag = get.ExitFlag(obj)
            flag = obj.SimulationData.ExitFlag;
        end      
        
        function variance = get.CoV(obj)
            variance = sqrt(obj.Variance) / obj.Value;
        end
    end
end

