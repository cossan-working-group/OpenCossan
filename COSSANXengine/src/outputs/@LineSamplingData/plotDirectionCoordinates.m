function varargout=plotDirectionCoordinates(Xobj,varargin)
%PLOTLINES plots the value of the performance function on the lines
%

Stitle1='Important direction PHY';
Stitle2='Important direction SNS';
SxLabel='input variable #';
SyLabel='coordinate';
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

%% Extract values from the Line Data object
VimportantDirectionPHY=Xobj.VimportantDirectionPHY;
VimportantDirectionSNS=Xobj.VimportantDirectionSNS;

%% Start the plot

fh=figure;

% Create subplot
subplot1 = subplot(2,1,1,'Parent',fh,'YGrid','on','XGrid','on',...
    ...'Ytick',0:0.2:1,...
    'FontSize',14);
% X-limits of the axes
xlim(subplot1,[0 Xobj.Nvars+1]);
box(subplot1,'on');
hold(subplot1,'all');


Y1=VimportantDirectionPHY;

% Create stem
hst=stem(Y1,...
    'MarkerFaceColor',[0.043 0.518 0.780],...
    'LineWidth',1,...
    'Parent',subplot1);

% Create xlabel
xlabel(SxLabel);
% Create ylabel
ylabel(SyLabel);
% Create title
title(Stitle1)

if Llegend
    legend(hst,'coordinate Physical Space');
end


% Create subplot
subplot2 = subplot(2,1,2,'Parent',fh,'YGrid','on','XGrid','on',...
    ...'Ytick',0:0.2:1,...
    'FontSize',14);
% X-limits of the axes
xlim(subplot2,[0 Xobj.Nvars+1]);
box(subplot2,'on');
hold(subplot2,'all');


Y2=VimportantDirectionSNS;

% Create stem
hst=stem(Y2,'MarkerFaceColor',[0.847 0.161 0],...
    'LineWidth',1,...
    'Color',[0.039 0.141 0.416],...
    'Parent',subplot2);

% Create xlabel
xlabel(SxLabel);
% Create ylabel
ylabel(SyLabel);
% Create title
title(Stitle2)



if Llegend
    legend(hst,'coordinate Standard Space');
end

% title(gca(fh),Stitle,'FontSize',14);


if exist('Sfigurename','var')
    saveas(fh,Sfigurename,'eps')
end

varargout{1}=fh;
end %method
