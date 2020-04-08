classdef DesignPoint < opencossan.common.CossanObject
    %DesignPoint This class contains the design point associated with a
    %probabilistic model
    %
    % Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
    % Author: Edoardo Patelli
    
    properties 
        FunctionEvaluations(1,1) double {mustBeInteger, mustBeNonnegative}
        PerfomanceAtOrigin(1,1) double
        DesignPointPhysical table
        Model(1,1) opencossan.common.Model
    end
    
    properties  (Dependent=true, SetAccess=protected)
        DesignPointStdNormal           %coordinates of the design point in the standard normal space
        DirectionPhysical   %unit vector containing direction of design point in the physical space
        DirectionStdNormal  %unit vector containing direction of design point in the standard normal space
        ReliabilityIndex                %Euclidean norm of the design point w.r.t. the origin
        Form                            % First order reliability
        Input
    end
    
    methods
        function obj = DesignPoint(varargin)
            %% DesignPoint Constructor
            %DesignPoint Constructor of DesignPoint object; this object
            %contains the coordinates of the design point in both the physical
            %and the standard normal space. In addition, it also contains the
            %vector describing the direction of the design point and its
            %Euclidean norm

            if nargin==0
                super_args = {};
            else
                [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["designpoint", "model", "performanceatorigin"], varargin{:});
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    "functionevaluations", {0}, varargin{:});
            end
            
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.DesignPointPhysical = required.designpoint;
                obj.Model = required.model;
                obj.PerfomanceAtOrigin = required.performanceatorigin;
                obj.FunctionEvaluations = optional.functionevaluations;
            end
        end

        function direction = get.DirectionPhysical(obj)
            direction = obj.DesignPointPhysical{:,:} / norm(obj.DesignPointPhysical{:,:});
        end
        
        function direction = get.DirectionStdNormal(obj)
            direction = obj.DesignPointStdNormal{:,:} / norm(obj.DesignPointStdNormal{:,:});
        end
        
        function index = get.ReliabilityIndex(obj)
            index = norm(obj.DesignPointStdNormal{:,:});
        end
        
        function dp = get.DesignPointStdNormal(obj)
            dp = obj.Model.Input.map2stdnorm(obj.DesignPointPhysical);
        end
        
        function obj = set.DesignPointStdNormal(obj, dp)
            obj.DesignPointPhysical = obj.Model.Input.map2stdnorm(dp);
        end
        
        function form = get.Form(obj)
            if obj.PerfomanceAtOrigin > 0
                form = normcdf(-obj.ReliabilityIndex);
            else
                form = normcdf(obj.ReliabilityIndex);
            end
        end
    end
end
