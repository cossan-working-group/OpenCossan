classdef JobManagerSlurm < opencossan.highperformancecomputing.JobManager
    %  This class defines the interface with the cluster/cloud computing. 
    %   The requested computation are automatically converted to jobs and
    %   submitted to the Job management software on the cluster. The results are then retrieved and
    %  processed by OpenCossan (i.e., in a SimulationData object).
    %
    % See also: JobManagerSlurm, Worker, Evaluator, 
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2020 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    % =====================================================================
    
    properties
        ModuleList              % list of module to load  
        AdditionalSubmitArgs    % Custumisation arguments for submitting jobs
    end
    
    properties (Dependent)    
        quotedCommand
    end
    
    methods
        
        function obj=JobManagerSlurm(varargin)
            %Constructor of JobManager
            if nargin == 0
                superArg = {};
            else
                % No mandatory parameters
                
                % Process optional paramets
                OptionalsArguments={...
                    ["moduleList","AdditionalSubmitArgs"], {[] []};};
                
                [optionalArgs, superArg] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    [OptionalsArguments{:,1}],OptionalsArguments(:,2), varargin{:});
            end
            
            obj@opencossan.highperformancecomputing.JobManager(superArg{:});
            
            if optionalArgs > 0
                obj.ModuleList=optionalArgs.modulelist;
                obj.AdditionalSubmitArgs=optionalArgs.additionalsubmitargs;
            end
        end
     
    end
            
end
