function varargout=plotLines(Xobj,varargin)
%PLOTLINES plots the value of the performance function on the lines
%

Stitle='Lines of the Performance Function in SNS';
SxLabelNorm='samples norm';
SxLabelPlane='samples distance from the hyperplane';
SyLabel=Xobj.SperformanceFunctionName;
Smarker='o';
Svisible='on';
lineWidth=1;
Ltext=false;
Lfine=false;
Llegend=true;

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'sfigurename'
            Sfigurename=varargin{k+1};
        case 'stitle'
            Stitle=varargin{k+1};
        case 'linewidth'
            lineWidth=varargin{k+1};
        case 'smarker'
            Smarker=varargin{k+1};
        case 'lvisible'
            if varargin{k+1}
                Svisible='on';
            else
                Svisible='off';
            end
        case 'ltext'
            Ltext=varargin{k+1};
        case 'lfine'
            Lfine=varargin{k+1};
        case 'llegend'
            Llegend=varargin{k+1};
        otherwise
            error('openCOSSAN:LineSamplingData:plotLines',...
                ['Field name (' varargin{k} ') not allowed']);
    end
end

%% Start the plot

fh=figure('Visible',Svisible);
varargout{1}=fh;

hold(gca(fh),'on');

% Extract values from the Line Data object
CVperformanceValues={Xobj.Tdata.Vg};
CVlineDistances={Xobj.Tdata.Vdistances};
CdistanceLimitState={Xobj.Tdata.distanceLimitState};
% VimportantDirectionPHY=Xobj.VimportantDirectionPHY;
MimportantDirectionSNS=Xobj.MimportantDirectionSNS;
VNlinePoints=Xobj.VNlineEvaluations;
VnormStatePoint=Xobj.VnormStatePoints;
MhyperplaneCoords=Xobj.MhyperplaneCoords;



subplot(121) % plot distances from origin
% Start loop to plot the processed lines
Xdata=NaN(100,Xobj.NprocessedLines);
Ydata=NaN(100,Xobj.NprocessedLines);
Vxsp=NaN(Xobj.NprocessedLines,1);
for iLine=1:Xobj.NprocessedLines
    
    % Get information for each line
    Vg=CVperformanceValues{iLine};
    VlineDistances=CVlineDistances{iLine};
    
    Valpha=MimportantDirectionSNS(iLine,:);
    NlinePoints=VNlinePoints(iLine);
    normStatePoint=VnormStatePoint(iLine);
    Vxsp(iLine,1)=normStatePoint;
    
    VlineHyperPlanePoint=MhyperplaneCoords(iLine,:);
    
    
    % Distances from origin
    Vx=sqrt(sum((repmat(VlineHyperPlanePoint(:),1,NlinePoints)+...
        Valpha(:)*VlineDistances).^2,1));
    [Vx,sx]=sort(Vx(:));
    Vg=Vg(:);
    p=length(Vx);
    Xdata(1:p,iLine)=Vx;
    Ydata(1:p,iLine)=Vg(sx);
%     if length(Vx1)==1
%         Vx1Fine=Vx1;
%         VgxFine=Vg1;
%     else
%         Vx1Fine=linspace(min(Vx1),max(Vx1),1000);
%         VgxFine=interp1(Vx1,Vg1(sx),Vx1Fine,'spline');
%     end
    
%     hold on
%     if ~Lfine
%         hp=plot(Vx1,Vg1(sx));
%     else
%         hp=plot(Vx1Fine,VgxFine);
%     end
%     set(hp,'color',rand(1,3),'linewidth',lineWidth)
%     hs=scatter(normStatePoint,0);
%     set(hs,'markeredgecolor','red','marker',Smarker)
%     hs1=scatter(Vx1,Vg1(sx),'marker','*','markeredgecolor',0.5*ones(1,3));
%     if Ltext
%         text(Vx1(end),Vg1(sx(end)),num2str(iLine))
%     end
%     xlabel(SxLabelDistance,'FontSize',14);
%     ylabel(SyLabel,'FontSize',14)
%     
%     
%     box on
%     grid on
end %loop over lines

hold on
hp=plot(Xdata,Ydata);
set(hp,'linewidth',lineWidth)
% hs=scatter(Xdata,Ydata);
hsl=scatter(Vxsp,zeros(length(Vxsp),1));
set(hsl,'markeredgecolor','red','marker',Smarker)
xlabel(SxLabelNorm,'FontSize',14);
ylabel(SyLabel,'FontSize',14)
box on
grid on


if Llegend
    legend([hp(1),hp(2),hp(3),hp(4),hp(5),hp(end),hsl(1)],'line #0','line #1','...','line #j','...',strcat('line #',num2str(Xobj.NprocessedLines-1)),'limit state points');
end
set(gca(fh),'FontSize',14);
% title(gca(fh),Stitle,'FontSize',14);

subplot(122) % plot distances from the hyperplane
Xdata=NaN(100,Xobj.NprocessedLines);
Ydata=NaN(100,Xobj.NprocessedLines);
Vxsp=NaN(Xobj.NprocessedLines,1);
for iLine=1:Xobj.NprocessedLines
    % Get information for each line
    Vg=CVperformanceValues{iLine};
    VlineDistances=CVlineDistances{iLine};
    distanceLimitState=CdistanceLimitState{iLine};
    Vxsp(iLine,1)=distanceLimitState;
    

    % Distances from hyperplane
    Vy=VlineDistances;
    [Vy,sy]=sort(Vy(:));
    Vg=Vg(:);
    p=length(Vy);
    Xdata(1:p,iLine)=Vy;
    Ydata(1:p,iLine)=Vg(sy);
%     if length(Vy1)==1
%         Vy1Fine=Vy1;
%         VgyFine=Vg1;
%     else
%         Vy1Fine=linspace(min(Vy1),max(Vy1),1000);
%         VgyFine=interp1(Vy1,Vg1(sy),Vy1Fine,'spline');
%     end
    
%     hold on
%     if ~Lfine
%         hp=plot(Vy1,Vg1(sy));
%     else
%         hp=plot(Vy1Fine,VgyFine);
%     end
%     
%     hs=scatter(distanceLimitState,0);
%     hs1=scatter(Vy1,Vg1(sy),'marker','*','markeredgecolor',0.5*ones(1,3));
%     set(hp,'color',rand(1,3),'linewidth',lineWidth)
%     set(hs,'markeredgecolor','red','marker',Smarker)
%     if Ltext
%         text(Vy1(end),Vg1(sy(end)),num2str(iLine))
%     end
%     xlabel(SxLabelPlane,'FontSize',14);
%     ylabel(SyLabel,'FontSize',14)
%     box on
%     grid on
end %loop over lines
hold on
hp=plot(Xdata,Ydata);
set(hp,'linewidth',lineWidth)
% hs=scatter(Xdata,Ydata);
hsl=scatter(Vxsp,zeros(length(Vxsp),1));
set(hsl,'markeredgecolor','red','marker',Smarker)
xlabel(SxLabelPlane,'FontSize',14);
ylabel(SyLabel,'FontSize',14)
box on
grid on


if Llegend
    legend([hp(1),hp(2),hp(3),hp(4),hp(5),hp(end),hsl(1)],'line #0','line #1','...','line #j','...',strcat('line #',num2str(Xobj.NprocessedLines-1)),'limit state points');
end
set(gca(fh),'FontSize',14);

% title(gca(fh),Stitle,'FontSize',14);


if exist('Sfigurename','var')
    saveas(fh,Sfigurename,'eps')
end

varargout{1}=fh;
end %method
