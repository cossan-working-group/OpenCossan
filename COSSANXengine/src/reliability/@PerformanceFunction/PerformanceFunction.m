classdef PerformanceFunction
    %PERFORMANCEFUNCTION This class define the performance function for the
    %realiability analysis.
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
    
    properties % Public access
        Sdescription        % Description of the performance function
        Scapacity           % CAPACITY (variable name)
        Sdemand             % DEMAND (variable name)
        Xmio                % User defined performance function
        Soutputname         % Name of the exported performance function
        stdDeviationIndicatorFunction   % Standard deviation associated with
        % indicator function; in case this value is different from zero,
        % the original indicator function, i.e a Heaviside function, is
        % replaced by the CDF of a Gaussian distribution with zero mean
        % and the std. deviation equal to stdDeviationIndicatorFunction
    end
    
    methods % Public access
        
        varargout=apply(Xobj,varargin) % Compute the performance function
        
        display(Xobj)  %Summary of the PerformanceFunction object
        
        %% constructor
        function Xobj= PerformanceFunction(varargin)
            %PERFORMANCEFUNCTION This constructor defines a PerformanceFunction
            %object.
            %   The performance function is defined as CAPACITY-DEMAND
            %   CAPACITY and DEMAND are defined by values of the variable defined
            %   by the field Scapacity and Sdemand respectively.
            %   The performance function can also be defined as the results of a
            %   user defined Function.
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
            
            if nargin==0
                % Create an empty object
                return
            end
            % Check varargin
            OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'soutputname'}
                        Xobj.Soutputname=varargin{k+1};
                    case {'scapacity'}
                        Xobj.Scapacity=varargin{k+1};
                    case {'sdemand'}
                        Xobj.Sdemand=varargin{k+1};
                    case {'xmio'}
                        Xobj.Xmio=varargin{k+1};
                    case {'cxmio'}
                        Xobj.Xmio=varargin{k+1}{1};
                    case {'stddeviationindicatorfunction'}
                        Xobj.stdDeviationIndicatorFunction     = varargin{k+1};
                    otherwise
                        error('openCOSSAN:reliability:PerformanceFunction',...
                            ['Field name  ('  varargin{k}  ') not allowed']);
                end
                
            end
            
            %% Inputs checks
            if isempty(Xobj.Xmio)
                
                if isempty(Xobj.Scapacity)
                    error('openCOSSAN:reliability:PerformanceFunction',...
                        'Capacity not defined');
                end
                
                if isempty(Xobj.Sdemand)
                    error('openCOSSAN:reliability:PerformanceFunction',...
                        'Demand not defined');
                end
                
            else
                assert(isa(Xobj.Xmio,'Mio'),...
                    'openCOSSAN:reliability:PerformanceFunction',...
                    'user defined PerformanceFunction can only be defined by means of a Mio object');
                
                assert (isempty(Xobj.Soutputname), ...
                    'openCOSSAN:reliability:PerformanceFunction', ...
                    strcat('It is not possible to use the field Soutputname when the performance function is defined by means of a Mio object.\n',...
                    'The output name is defined by the Mio object. See: https://cossan.co.uk/wiki/index.php/@PerformanceFunction'))
                if length(Xobj.Xmio.Coutputnames)==1
                    Xobj.Soutputname=Xobj.Xmio.Coutputnames{1};
                else
                    error('openCOSSAN:reliability:PerformanceFunction',...
                        [inputname(k+1) ' must be a Mio object with only 1 output (i.e. the performance function)']);
                end
            end
            
            if isempty(Xobj.Soutputname)
                error('openCOSSAN:reliability:PerformanceFunction',...
                    'the outputname of the performance function must be defined');
            end
            
        end % constructor
        
    end % methods
    
end

