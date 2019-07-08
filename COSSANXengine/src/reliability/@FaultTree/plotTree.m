function varargout=plotTree(Xobj,varargin)
% plotTree This method shows the FaultTree in a matlab figure
% The optinal parameters allow to customize the apparance of the figure.
% The method returns as optional output argoment the handle of the figure.


%% Default values
Stitle='';
sizeData=200;
fontSize=16;

%% Check inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'stitle'}
            Stitle=varargin{k+1};
        case {'sizedata'}
            sizeData=varargin{k+1};
        case {'fontsize'}
            fontSize=varargin{k+1};
        case 'sfigurename'
            SfigureName=varargin{k+1};
        case 'sexportformat'
            Sexportformat=varargin{k+1};
        otherwise
            error('openCOSSAN:reliability:FaultTree',...
                'Field name not allowed');
    end
end


%% Show FaultTree
figHandle=figure('Name',Stitle);
hold on;
s1=scatter(0,0,'<'); % plot output
set(s1,'SizeData',sizeData,'MarkerEdgeColor','k','MarkerFaceColor','r')
t1=text(-0.8,0,'OUTPUT');
set(t1,'FontSize',fontSize,'Color','k','FontWeight','normal');
set(gca,'Box','on','LineWidth',1,'FontSize',fontSize)
xlabel('Tree levels');
Nnodes=length(Xobj.VnodeConnections); % retrive number of nodes

% Preallocate memory
xpos=zeros(Nnodes,1);
ypos=zeros(Nnodes,1);
Ncount=zeros(Nnodes,1);

for ic=2:Nnodes
    Ncount(Xobj.VnodeConnections(ic))=Ncount(Xobj.VnodeConnections(ic))+1;
end

ireset=0;

for ic=2:Nnodes
    if Ncount(Xobj.VnodeConnections(ic))<2
        xpos(ic)=xpos(ic-1)+1;
        ypos(ic)=ypos(Xobj.VnodeConnections(ic));
        ireset=0;
    else
        if ireset==0;
            xpos(ic)=xpos(ic-1)+1;
            ypos(ic)=ypos(Xobj.VnodeConnections(ic))-1;
            ireset=1;
        elseif ~rem(ireset,2)
            % if ireset is an even numer
            xpos(ic)=xpos(ic-1);
            % find the node with the same connection
            Vpos=find(Xobj.VnodeConnections==Xobj.VnodeConnections(ic));
            ypos(ic)=min(ypos(Vpos(1:ireset+1)))-1;
            ireset=ireset+1;
        else
            % if ireset is an odd numer
            xpos(ic)=xpos(ic-1);
            % find the node with the same connection
            Vpos=find(Xobj.VnodeConnections==Xobj.VnodeConnections(ic));
            ypos(ic)=max(ypos(Vpos(1:ireset+1)))+2;
            ireset=ireset+1;
        end
        
        if ireset==Ncount(Xobj.VnodeConnections(ic))
            ireset=0;
        end
        
        % 		elseif ireset<Ncount(Xobj.VnodeConnections(ic))-1
        % 			xpos(ic)=xpos(ic-1);
        % 			ypos(ic)=ypos(Xobj.VnodeConnections(ic))+1;
        % 			ireset=ireset+1;
        % 		else
        % 			xpos(ic)=xpos(ic-1);
        % 			ypos(ic)=ypos(Xobj.VnodeConnections(ic))+1;
        % 			ireset=0;
        % 		end
    end
    l1=plot (xpos([Xobj.VnodeConnections(ic) ic]),ypos([Xobj.VnodeConnections(ic) ic]),'-');
    set(l1,'LineWidth',2);
    switch lower(Xobj.CnodeTypes{ic})
        case 'and'
            s1=scatter(xpos(ic),ypos(ic),'^','filled'); % plot output
            set(s1,'SizeData',sizeData,'MarkerEdgeColor','k','MarkerFaceColor','g')
            t1=text(xpos(ic)+0.2,ypos(ic),Xobj.CnodeNames{ic});
            set(t1,'FontSize',fontSize,'Color','k','FontWeight','normal');
        case 'or'
            s1=scatter(xpos(ic),ypos(ic),'v','filled'); % plot output
            set(s1,'SizeData',sizeData,'MarkerEdgeColor','k','MarkerFaceColor','m')
            t1=text(xpos(ic)+0.2,ypos(ic),Xobj.CnodeNames{ic});
            set(t1,'FontSize',fontSize,'Color','k','FontWeight','normal');
        case 'input'
            s1=scatter(xpos(ic),ypos(ic),'o'); % plot output
            set(s1,'SizeData',sizeData+100,'MarkerEdgeColor','k','MarkerFaceColor','y')
            t1=text(xpos(ic)+0.2,ypos(ic),Xobj.CnodeNames{ic});
            set(t1,'FontSize',fontSize,'Color','b','FontWeight','bold');
    end
end

Ylim=get(gca,'YLim');
Xlim=get(gca,'XLim');

Ylim(1)=Ylim(1)-1;
Ylim(end)=Ylim(end)+1;
Xlim(1)=Xlim(1)-1;
Xlim(end)=Xlim(end)+1;


set(gca,'YLim',Ylim)
set(gca,'XLim',Xlim)

set(gca,'Visible','off');


if nargout>0
    varargout{1}=figHandle;
end

%% Export Figure

if exist('SfigureName','var')
    if exist('Sexportformat','var')
        exportFigure('HfigureHandle',figHandle,'SfigureName',SfigureName,'SexportFormat',Sexportformat)
    else
        exportFigure('HfigureHandle',figHandle,'SfigureName',SfigureName)
    end
end
