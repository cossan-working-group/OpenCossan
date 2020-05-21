classdef Job < opencossan.common.CossanObject
    %JOB This class provide information of job prepared and submitted to a
    %cluster or grid computing. 
    %
    % See also: JobManager, Evaluator
    
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
    
    properties
        ID(1,:) {mustBeInteger}
        Name
        State
        Dependences
        ScriptName
    end
    
    methods
        function obj = Job(varargin)
            
            if nargin == 0
                superArg = {};
            else
                
                [requiredArgs, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["ID","Status"], varargin{:});
                
                [optionalArgs, superArg] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["Name","Dependences" "ScriptName"],{[],[],[]}, varargin{:});
            end
            
            obj@opencossan.common.CossanObject(superArg{:});
            
            if nargin > 0
                obj.ID=requiredArgs.id;
                obj.State=requiredArgs.state;
                obj.Name=optionalArgs.name;
                obj.Dependences=optionalArgs.dependences;
                obj.ScriptName=optionalArgs.scriptname;
            end
        end
        
    end
end

