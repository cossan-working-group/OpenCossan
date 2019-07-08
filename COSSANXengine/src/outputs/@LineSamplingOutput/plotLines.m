function varargout=plotLines(Xobj,varargin)
%PLOTLINES plots the value of the performance function on the lines
%

Stitle='Lines of the Performance Function';
SxLabelDistance='Distance from origin in standard normal space';
SxLabelPlane='Distance from the plane orthogonal to the important direction';
SyLabel=Xobj.SperformanceFunctionName;
Smarker='-';
Svisible='on';
lineWidth=1;
Ldistance=true;

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'sfigurename'
            Sfigurename=varargin{k+1};
        case 'stitle'
            Stitle=varargin{k+1};
        case 'nmaxlines'
            NplotLines=varargin{k+1};
        case 'linewidth'
             lineWidth=varargin{k+1};
        case 'smarker'
            Smarker=varargin{k+1};
        case 'ldistance'
            % Use the distance from the origin in Standard normal space
            % Otherwise the distance from the plane orthogonal to the importante
            % direction is used
            Ldistance=varargin{k+1};    
        case 'lvisible'
            if varargin{k+1}
                Svisible='on';
            else
                Svisible='off';
            end
        otherwise
            error('openCOSSAN:LineSamplingOutput:plotLines',...
                   ['Field name (' varargin{k} ') not allowed']);
    end
end

%% Check data

if Ldistance
    assert(~isempty(Xobj.VdistanceOrigin),...
        'openCOSSAN:LineSamplingOutput:plotLines', ...
        'No data available in the object')
else
    assert(~isempty(Xobj.VdistancePlane),...
        'openCOSSAN:LineSamplingOutput:plotLines', ...
        'No data available in the object')
end

fh=figure('Visible',Svisible);
varargout{1}=fh;

if exist('NplotLines','var')
    NplotLines=min(NplotLines,Xobj.Nlines);
else
    NplotLines=Xobj.Nlines;
end

 
hold(gca(fh),'on');
  
Vg=Xobj.getValues('Sname',Xobj.SperformanceFunctionName);

if Ldistance
        xlabel(gca(fh),SxLabelDistance,'FontSize',16)
else
        xlabel(gca(fh),SxLabelPlane,'FontSize',14)
end

if all(diff(Xobj.VnumPointLine)==0) && Xobj.VnumPointLine(1)~=2
    Lscatter=false;
else
    Lscatter=true;
end

iEndPoint=0;
for n=1:NplotLines
    iStartPoint=iEndPoint+1;
    iEndPoint=Xobj.VnumPointLine(n)+iStartPoint-1;
    
    if Ldistance
        Vx=Xobj.VdistanceOrigin(iStartPoint:iEndPoint);
    else
        Vx=Xobj.VdistancePlane(iStartPoint:iEndPoint);
    end
    
    plot(Vx,Vg(iStartPoint:iEndPoint),'LineWidth',lineWidth,'Color',rand(1,3))
    
    if Lscatter
      %  scatter(x0,0,'o','filled','red')
    end
    
    %text(Vx(end),Vg(iEndPoint),num2str(n))
end
box(gca(fh),'on');
grid(gca(fh),'on');


ylabel(gca(fh),SyLabel,'FontSize',16)

title(gca(fh),Stitle);

set(gca(fh),'FontSize',16);

if exist('Sfigurename','var')
    saveas(fh,Sfigurename,'eps')
end

varargout{1}=fh;
end




