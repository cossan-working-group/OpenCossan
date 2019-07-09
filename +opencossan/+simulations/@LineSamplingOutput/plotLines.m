function varargout=plotLines(Xobj,varargin)
%PLOTLINES plots the value of the performance function on the lines
%

Stitle='Lines of the Performance Function';
SxLabelDistance='L2 norm in standard normal space';
SxLabelPlane='Distance from the orthogonal plane';
SyLabel=Xobj.SperformanceFunctionName;
Smarker='-';
Svisible='on';
lineWidth=1;

%% Validate input arguments
opencossan.OpenCossan.validateCossanInputs(varargin{:})

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
        case 'svisible'
            Svisible=varargin{k+1};
        otherwise
            error('openCOSSAN:LineSamplingOutput:plotLines',...
                   ['Field name (' varargin{k} ') not allowed']);
    end
end

%% Check data

assert(~isempty(Xobj.VdistanceOrigin),...
    'openCOSSAN:LineSamplingOutput:plotLines', ...
    'No data available in the object')
assert(~isempty(Xobj.VdistancePlane),...
    'openCOSSAN:LineSamplingOutput:plotLines', ...
    'No data available in the object')

fh1=figure('visible',Svisible);
haxe1=axes;
fh2=figure('visible',Svisible);
haxe2=axes;

if exist('NplotLines','var')
    NplotLines=min(NplotLines,Xobj.Nlines);
else
    NplotLines=Xobj.Nlines;
end

hold(gca(fh1),'on');
hold(gca(fh2),'on');

xlabel(gca(fh1),SxLabelPlane,'FontSize',14)
xlabel(gca(fh2),SxLabelDistance,'FontSize',14)

% Retrieve performance function values
Vg=Xobj.getValues('Sname',Xobj.SperformanceFunctionName);

iend=0;
for n=1:NplotLines
    istart=iend+1;
    iend=Xobj.VnumPointLine(n)+istart-1;
    
    Vn=Xobj.VdistanceOrigin(istart:iend);
    Vd=Xobj.VdistancePlane(istart:iend);
    
    [Vd,sd]=sort(Vd);
    [Vn,sn]=sort(Vn);
    VgLine=Vg(istart:iend);
    
    plot(haxe1,Vd,VgLine(sd),'LineWidth',lineWidth,'Color',rand(1,3));
    
    plot(haxe2,Vn,VgLine(sn),'LineWidth',lineWidth,'Color',rand(1,3));
    
%     if Lscatter
%       %  scatter(x0,0,'o','filled','red')
%     end
end
box(gca(fh1),'on');box(gca(fh2),'on');
grid(gca(fh1),'on');grid(gca(fh2),'on');

ylabel(gca(fh1),SyLabel,'FontSize',14)
ylabel(gca(fh2),SyLabel,'FontSize',14)

title(gca(fh1),Stitle);
title(gca(fh2),Stitle);

set(gca(fh1),'FontSize',14);
set(gca(fh2),'FontSize',14);

if exist('Sfigurename','var')
    saveas(fh,Sfigurename,'eps')
end

varargout{1}=fh1;
varargout{2}=fh2;
end




