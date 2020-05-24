classdef PerformanceFunction < opencossan.workers.MatlabWorker
    % PERFORMANCEFUNCTION This class define the performance function for the
    % realiability analysis. It is a subclass of workers.Mio.
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/@PerformanceFunction
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
    
    
    properties
        Capacity;
        Demand;
        StdDeviationIndicatorFunction   % Standard deviation associated with
        % indicator function; in case this value is different from zero,
        % the original indicator function, i.e a Heaviside function, is
        % replaced by the CDF of a Gaussian distribution with zero mean
        % and the std. deviation equal to stdDeviationIndicatorFunction
    end
    
    methods
        function obj = PerformanceFunction(varargin)
            % PERFORMANCEFUNCTION Constructs a PerformanceFunction object.
            %  obj = PerformanceFunction(OutputName,varargin)
            %
            % Permitted parameters are:
            %  - OutputName (required)
            %  - Capacity
            %  - Demand
            %  - StdDeviationIndicatorFunction
            %
            % See also workers.Mio
            
            import opencossan.*
            
            if nargin == 0
                super_args = {};
            else
                p = inputParser;
                p.KeepUnmatched = true;
                p.FunctionName = 'opencossan.reliability.PerformanceFunction.PerformanceFunction';
                
                p.addParameter('OutputName','',@(x) validateattributes(x,...
                    {'char', 'cell'},{'nonempty'}));
                p.addParameter('Capacity','',@(x) validateattributes(x,...
                    {'char'},{'nonempty'}));
                p.addParameter('Demand','',@(x) validateattributes(x,...
                    {'char'},{'nonempty'}));
                p.addParameter('StdDeviationIndicatorFunction',0,@(x) validateattributes(x,...
                    {'numeric'},{'nonempty'}));
                
                p.parse(varargin{:});
                
                super_args = opencossan.common.utilities.parseUnmatchedArguments(p.Unmatched);
                
                if ~isempty(p.Results.OutputName)
                    super_args{end+1} = 'OutputNames';
                    if isa(p.Results.OutputName,'cell')
                        super_args{end+1} = p.Results.OutputName(1);
                        OutputName = p.Results.OutputName(1); % For use in the Script
                    else
                        super_args{end+1} = {p.Results.OutputName};
                        OutputName = p.Results.OutputName; % For use in the Script
                    end
                    
                    if  ~isempty(p.Results.Capacity) && ~isempty(p.Results.Demand)
                        super_args{end+1} = 'InputNames';
                        super_args{end+1} = {p.Results.Capacity p.Results.Demand};
                        
                        super_args{end+1} = 'Script';
                        super_args{end+1} = sprintf('TOutput.%s=TableInput.%s-TableInput.%s; TableOutput=struct2table(TOutput);', ...
                            OutputName,p.Results.Capacity,p.Results.Demand);
                    end
                else
                    error('OpenCossan:PerformanceFunction:MissingRequiredParameter',...
                        'OutputName is a required parameter');
                end
            end
            
            obj = obj@opencossan.workers.MatlabWorker(super_args{:});
            
            if nargin > 0
                obj.Demand = p.Results.Demand;
                obj.Capacity = p.Results.Capacity;
                obj.StdDeviationIndicatorFunction = p.Results.StdDeviationIndicatorFunction;
            end
        end
        
    end
    
end

