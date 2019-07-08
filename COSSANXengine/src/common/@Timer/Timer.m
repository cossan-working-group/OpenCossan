classdef Timer < handle
    %TIMER This class is used to monitor the elapsed time in OpenCossan
    % This object is initialised automatically by OpenCossan
    
    properties
        Cdescription    % Description of the Timer object
    end
    
    properties(SetAccess = private)
        Vtime                       % Vector of the time for each timing
        Ctimelabel                  % Description of each timing
        timestamp = datestr(now)    %
        LrunningTime=true           % Timer status
    end
    
    properties (Dependent = true)
        currentTime                 % Elapsed time from the last timing
        totalTime                   % Elapsed time from the Timer initialization
        Ntiming                     % Number of counters
    end
    
    methods
        % Constructor
        function Xobj=Timer(varargin)
            %TIMER This is the constructor of the class Timer
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Timer
            %
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
            
            
            Xobj.starttime(varargin{:});
        end % End Constructor
        
        function starttime(Xobj,varargin) % Start a new counter
            % Start the Timer
            
            OpenCossan.validateCossanInputs(varargin{:});
            
            Xobj.Ctimelabel{end+1} = tic; % Start new counter
            Xobj.Vtime(end+1) = 0;
            % Initialize variable
            Sdescription=['Timing ' num2str(length(Xobj.Ctimelabel))];
            
            for k=1:2:length(varargin)
                switch(lower(varargin{k}))
                    case ('sdescription')
                        Sdescription = varargin{k+1};
                    otherwise
                        error('OpenCossan:common:Timer',...
                            ['PropertyName ' varargin{k} ' not valid'])
                end
            end
            
            Xobj.Cdescription{Xobj.Ntiming} = Sdescription;
            Xobj.LrunningTime=true; % Reactivate the timer
        end
        
        function stoptime(Xobj) % Stop all the counter
            
            Xobj.LrunningTime=false; % Stop the timer
            Xobj.Vtime(end) = toc(Xobj.Ctimelabel{end}); % Compute enlapsed time for last counter
            
        end
        
        function varargout=laptime(Xobj,varargin)
            % Get time elapsed from previous counter and start a new
            % counter
            % The method returns as optional output argument the number of
            % the new counter started
            
            % Get time elapsed from previous counter
            Xobj.Vtime(end) = toc(Xobj.Ctimelabel{end});
            
            % Start a new counter
            Xobj.starttime(varargin{:});
            if nargout~=0
                varargout{1}=length(Xobj.Vtime);
            end
        end
        
        
        function deltatime=deltatime(Xobj,NlapNumber,NlapNumber2)
            % Return the elapsed time from the laptime specified
            % NlapNumber
            if nargin==2
                assert(NlapNumber<=length(Xobj.Vtime),'OpenCossan:Timer:deltatime',...
                    'The Timer contains only %i laps! Required lap number not valid.',length(Xobj.Vtime))
                deltatime=sum(Xobj.Vtime(NlapNumber:end))+Xobj.currentTime;
            else
                assert(NlapNumber2>NlapNumber,'OpenCossan:Timer:deltatime',...
                    'The second lap number must be greater then the first')
                
                assert(NlapNumber2<=length(Xobj.Vtime),'OpenCossan:Timer:deltatime',...
                    'The Timer contains only %i laps! Required lap number not valid.',length(Xobj.Vtime))
                
                
                deltatime=sum(Xobj.Vtime(NlapNumber:NlapNumber2));
            end
        end
        
        function reset(Xobj) % Reset Timer object
            Xobj.Ctimelabel = {};
            Xobj.Vtime = [];
            Xobj.Cdescription = {};
        end
        
        function display(Xobj) % Show Timer
            OpenCossan.cossanDisp(['Timer initialized at ' Xobj.timestamp],2)
            
            if length(Xobj.Vtime)>1
                OpenCossan.cossanDisp('  # Lap   | Elapsed time | Description',3);
                OpenCossan.cossanDisp('---------------------------------------',3);
                
                if Xobj.LrunningTime
                    for i=1:length(Xobj.Vtime)-1
                        OpenCossan.cossanDisp([sprintf('%4i     ',i) sprintf('%12.3f',Xobj.Vtime(i)) '     ' Xobj.Cdescription{i} ],3)
                    end
                    OpenCossan.cossanDisp([sprintf('%4i     ',length(Xobj.Vtime)) sprintf('%12.3f',Xobj.currentTime) '     ' Xobj.Cdescription{end} ' (current time)'],3)
                else
                    for i=1:length(Xobj.Vtime)
                        OpenCossan.cossanDisp([sprintf('%4i     ',i) sprintf('%12.3f',Xobj.Vtime(i)) '     ' Xobj.Cdescription{i} ],3)
                    end
                end
                OpenCossan.cossanDisp('---------------------------------------',3);
            end
            
            OpenCossan.cossanDisp([' Total time   : ' sprintf('%10.3f',Xobj.totalTime)],2)
            
        end
        
        
        function plot(Xobj,varargin) % Plot time in a x,y plot
            
            % Check inputs
            if ~isempty(varargin)
                OpenCossan.validateCossanInputs(varargin{:});
            end
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sfigurename'
                        SfigureName=varargin{k+1};
                    case 'stitle'
                        Stitle=varargin{k+1};
                    case 'sexportformat'
                        Sexportformat=varargin{k+1};
                    otherwise
                        
                end
            end
            fh=figure;
            
            plot(0:length(Xobj.Vtime),[0 cumsum(Xobj.Vtime)],'MarkerSize',8,...
                'Marker','o','LineWidth',2);
            ylabel('Cumulative Time (s)')
            set(gca,'XTick',0:length(Xobj.Vtime))
            set(gca,'XTickLabel',Xobj.Cdescription)
  %          xticklabel_rotate(0:length(Xobj.Vtime),90,['Initial Time' Xobj.Cdescription],'interpreter','none');
            set(gca, 'XGrid','on','FontSize',12)
            
            if exist('Stitle','var')
                title(gca,Stitle);
            else
                title(gca,['Timer initialized at ' Xobj.timestamp]);
            end
            if exist('SfigureName','var')
                if exist('Sexportformat','var')
                    exportFigure('HfigureHandle',fh,'SfigureName',SfigureName,'SexportFormat',Sexportformat)
                else
                    exportFigure('HfigureHandle',fh,'SfigureName',SfigureName)
                end
            end
        end
        
        % Dependent Properties
        
        function currentTime=get.currentTime(Xobj)
            currentTime=toc(Xobj.Ctimelabel{Xobj.Ntiming});
        end
        
        function Ntiming=get.Ntiming(Xobj)
            Ntiming=length(Xobj.Vtime);
        end
        
        function totalTime=get.totalTime(Xobj)
            if isempty(Xobj.Vtime)
                Xobj.starttime
            end
            
            if Xobj.LrunningTime
                totalTime=toc(Xobj.Ctimelabel{end});
            else
                totalTime=sum(Xobj.Vtime);
            end
        end
        
        
    end
    
end

