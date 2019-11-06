classdef LogLikelihood < opencossan.workers.Mio
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
    
   
    properties
        
        Xmodel              %The model that is to be used in the evaluation
        Data                %The Data to be used to update
        ShapeParameters     %The Shape Paramters that can be used in the updating procedure
        CustomLog           %User can pass custom likelihood function as a function handle
        
    end
    
    methods
           
        function obj = LogLikelihood(varargin)
        
            if nargin == 0
                % Create empty object
                return
            else
                p = inputParser;
                p.FunctionName = 'opencossan.inference.LogLikelihood';

                p.addParameter('Xmodel',obj.Xmodel);
                p.addParameter('Data',obj.Data);
                p.addParameter('CustomLog',obj.CustomLog)
                p.addParameter('ShapeParameters', obj.ShapeParameters);
                
                p.parse(varargin{:});

                obj.Xmodel = p.Results.Xmodel;
                obj.Data = p.Results.Data;
                obj.CustomLog = p.Results.CustomLog;
                obj.ShapeParameters = p.Results.ShapeParameters;
                
            end
            
        end
        
    end
 

%     
%     properties
%         Data
%         ShapeParameter        %This is an optional parameter in the case 
%                     %that the user defined script has a smoothing parameter
%     end
%     
%     
%     methods
%         
%         function obj = LogLikelihood(varagin)
%             % LOGLIKELIHOOD Constructs a LogLikelihood object.
%             %  obj = LogLikelihood(OutputName,varargin)
%             %
%             % Permitted parameters are:
%             %  - OutputName (required)
%             %  - Data
%             %  - ShapeParameter
%             %
%             % See also workers.Mio
%             
%             import opencossan.*
%             
%             if nargin == 0
%                 super_args = {};
%             else
%                 p = inputParser;
%                 p.KeepUnmatched = true;
%                 p.FunctionName = 'opencossan.inference.LogLikelihood.LogLikelihood';
%                 
%                 p.addParameter('OutputName','',@(x) validateattributes(x,...
%                     {'char', 'cell'},{'nonempty'}));
%                 p.addParameter('Data','',@(x) validateattributes(x,...
%                     {'SimulationData'}));
%                 p.addParameter('ShapeParameter','',@(x) validateattributes(x,...
%                     {'numeric', 'vector'}));
%                 
%                 p.parse(varargin{:});
%                 
%                 super_args = opencossan.common.utilities.parseUnmatchedArguments(p.Unmatched);
%                 
%                 if ~isempty(p.Results.OutputName)
%                     super_args{end+1} = 'OutputNames';
%                     if isa(p.Results.OutputName,'cell')
%                         super_args{end+1} = p.Results.OutputName{1};
%                         OutputName = p.Results.OutputName{1}; % For use in the Script
%                     else
%                         super_args{end+1} = {p.Results.OutputName};
%                         OutputName = p.Results.OutputName; % For use in the Script
%                     end
%                     
%                     if  ~isempty(p.Results.Capacity) && ~isempty(p.Results.Demand)
%                         super_args{end+1} = 'InputNames';
%                         super_args{end+1} = {p.Results.Capacity p.Results.Demand};
%                         
%                         super_args{end+1} = 'Script';
%                         super_args{end+1} = sprintf('TOutput.%s=TableInput.%s-TableInput.%s; TableOutput=struct2table(TOutput);', ...
%                             OutputName,p.Results.Capacity,p.Results.Demand);
%                     end
%                 else
%                     error('OpenCossan:PerformanceFunction:MissingRequiredParameter',...
%                         'OutputName is a required parameter');
%                 end
%             end
%             
%             obj = obj@opencossan.workers.Mio(super_args{:});
%             
%             if nargin > 0
%                 obj.Data = p.Results.Data;
%                 obj.ShapeParameter = p.Results.ShapeParameter;
%             end
%             
%         end
%         
%     end

end