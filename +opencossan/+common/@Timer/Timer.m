classdef Timer < handle & matlab.mixin.CustomDisplay
    %TIMER This class is used to monitor elapsed time in OpenCossan
    
    % =====================================================================
    % This file is part of *OpenCossan*: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % *OpenCossan* is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    properties
        Descriptions(:,1) cell;     % Descriptions of the individual timings
    end
    
    properties(SetAccess = private)
        Time(:,1) double;                   % Time for each timing
        TimeStamp(1,:) char = datestr(now); % Timestamp during initialization
        IsRunning = false                   % Timer status
    end
    
    properties(Access = private)
        Timing(:,1) uint64;         % Stores the timings used for tic;toc;
    end
    
    properties (Dependent = true)
        CurrentTime                 % Elapsed time of the current timing (if running)
        TotalTime                   % Total elapsed time of all timings
        Ntiming                     % Number of timings
    end
    
    methods
        function obj = Timer(varargin)
            %TIMER Constructs a Timer object
            %
            %   obj = Timer(varargin)
            %
            %   The Timer constructor supports the following name-value
            %   parameters:
            %       'Description' - Label for the first timing (char)
            
            obj.start(varargin{:});
        end
        
        function start(obj,varargin)
            %START Starts the timer if it is stopped. Gives a warning if
            %the timer is already running.
            %
            %   start(obj,varargin)
            %
            %   The method supports the following name-value parameters:
            %       'Description' - Label for the new timing (char)
            
            %% Parse input
            p = inputParser;
            p.FunctionName = 'opencossan.common.Timer.start';
            p.addParameter('Description',...
                sprintf('Timing %d', obj.Ntiming + 1));
            p.parse(varargin{:});
            
            %% Start the Timer
            if obj.IsRunning
                warning('OpenCossan:Timer:AlreadyRunning',...
                    'The timer is already running');
            else
                % Start new timer
                obj.Timing(end+1) = tic;
                obj.Time(end+1) = 0;
                obj.Descriptions{obj.Ntiming} = replace(p.Results.Description,' ','_');
                obj.IsRunning = true;
            end
        end
        
        function stop(obj)
            %STOP Stops the current timer
            if obj.IsRunning
                obj.IsRunning = false; % Stop the timer
                obj.Time(end) = toc(obj.Timing(end)); % Compute enlapsed time for last counter
            end
        end
        
        function varargout = lap(obj,varargin)
            %LAP Stops the timer and then starts a new timing
            %
            %   lap(obj,varargin)
            %
            %   The method supports the following name-value parameters:
            %       'Description' - Label for the new timing (char)
            
            obj.stop();
            obj.start(varargin{:});
            if nargout~=0
                varargout{1} = length(obj.Time);
            end
        end
        
        function delta = delta(obj,lap1,lap2)
            %DELTATIME Returns the elapsed time from lap1 to lap2
            %
            %   delta = delta(obj,lap1,lap2) Returns the elapsed time
            %   from lap1 to lap2
            %
            %   delta = delta(obj,lap1) Returns the elapsed time from lap1
            %   until the end
            
            if nargin < 3
                lap2 = obj.Ntiming;
            end
            
            assert(lap1 <= obj.Ntiming,'OpenCossan:Timer:delta',...
                'The Timer contains only %i laps! Value of lap1 (%d) is invalid.',...
                obj.Ntiming,lap1)
            assert(lap2 <= obj.Ntiming,'OpenCossan:Timer:delta',...
                'The Timer contains only %i laps! Value of lap2 (%d) is invalid.',...
                obj.Ntiming,lap2)
            assert(lap2 >= lap1,'OpenCossan:Timer:delta',...
                'The second lap number must be greater then the first')
            
            delta = sum(obj.Time(lap1:lap2));
        end
        
        function reset(obj)
            %RESET Clears the timer
            obj.Timing = [];
            obj.Time = [];
            obj.Descriptions = {};
            obj.IsRunning = false;
        end
        
        function f = plot(obj,varargin)
            %PLOT Plots the evolution of the time and returns
            %the function handle.
            %
            %   f = plot(obj,varargin)
            %
            %   PLOT supports the following name-value parameters:
            %       'FigureName' - Export the figure as FigureName.pdf
            %       (char)
            %       'ExportFormat' - Specifiy the format to export as
            %       (char)
            
            %% Parse Inputs
            p = inputParser;
            p.FunctionName = 'opencossan.common.Timer.plot';
            p.addParameter('Title',...
                sprintf('Timer initialized at %s',obj.TimeStamp),@ischar);
            p.addParameter('FigureName','',@ischar);
            p.addParameter('ExportFormat','',@ischar);
            p.parse(varargin{:});
            
            %% Plot times
            f = figure;
            plot(0:length(obj.Time),[0 cumsum(obj.Time)'],'MarkerSize',8,...
                'Marker','o','LineWidth',2);
            ylabel('Cumulative Time (s)')
            xticks(0:obj.Ntiming);
            xticklabels(["Start    ";obj.Descriptions]);
            xtickangle(90)
            grid on
            title(gca,p.Results.Title);
            
            if ~isempty(p.Results.FigureName)
                if ~isempty(p.Results.ExportFormat)
                    opencossan.common.utilities.exportFigure('HfigureHandle',f,...
                        'SfigureName',p.Results.FigureName,...
                        'SexportFormat',p.Results.ExportFormat);
                else
                    opencossan.common.utilities.exportFigure('HfigureHandle',f,...
                        'SfigureName',p.Results.FigureName);
                end
            end
        end
        
        function currentTime = get.CurrentTime(obj)
            %GET.CURRENTTIME Returns the time of the currently running
            %timer
            currentTime = 0;
            if obj.IsRunning
                currentTime = toc(obj.Timing(end));
            end
        end
        
        function Ntiming = get.Ntiming(obj)
            %GET.NTIMING Returns the number of laps
            Ntiming = numel(obj.Time);
        end
        
        function totalTime = get.TotalTime(obj)
            %GET.TOTALTIME Returns the total of all laps and the currently
            %running timer
            totalTime = sum(obj.Time) + obj.CurrentTime;
        end
    end
    
    methods (Access = protected)
        function groups = getPropertyGroups(obj)
            %GETPROPERTYGROUPS Prop. groups for disply method
            import matlab.mixin.util.PropertyGroup;
            if ~isscalar(obj)
                groups = PropertyGroup({'Descriptions','Time','TimeStamp','IsRunning',...
                    'CurrentTime','TotalTime','Ntiming'});
            else
                propList = struct();
                if obj.IsRunning
                    propList.Status = 'Running';
                else
                    propList.Status = 'Stopped';
                end
                propList.Initialized = obj.TimeStamp;
                propList.TotalTime = obj.TotalTime;
                
                groups = PropertyGroup(propList);
                
                propList = struct();
                for i = 1:numel(obj.Timing)
                    if i == numel(obj.Timing) && obj.IsRunning
                        propList.(obj.Descriptions{i}) = ...
                            sprintf('Lap %d %12.3fs (current)',i,obj.CurrentTime);
                    else
                        propList.(obj.Descriptions{i}) = ...
                            sprintf('Lap %d %12.3fs',i,obj.Time(i));
                    end
                end
                
                groups = [groups PropertyGroup(propList)];
            end
        end
    end
    
end

