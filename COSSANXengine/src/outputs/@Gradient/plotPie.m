function varargout=plotPie(Xobj,varargin)
%PLOTPIE This method plot the component of the gradient in a pie
%style figure and return the handle to the figure object.

%% Process inputs

Stitle=Xobj.Sdescription;
color='b';
maxcomponents=length(Xobj.Vgradient);


%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'figurehandle'
            fh=varargin{k+1};
        case 'sfigurename'
            SfigureName=varargin{k+1};
        case 'sexportformat'
            Sexportformat=varargin{k+1};
        case 'stitle'
            Stitle=varargin{k+1};
        case 'color'
            color=varargin{k+1};
        otherwise
            error('openCOSSAN:simulations:Gradient:plotComponents',...
                   ['Field name (' varargin{k} ') not allowed']);
    end
end

%% Sort results
[Values, indices]=sort(abs(Xobj.Vgradient),'descend');


figHandle=figure;
Vexplode=zeros(size(Values));
Vexplode(1)=1;

pie(gca(figHandle),Values,Vexplode,Xobj.Cnames(indices));
title(gca(figHandle),Stitle);
    
% Export Figure

if exist('SfigureName','var')
    if exist('Sexportformat','var')
        exportFigure('figureHandle',figHandle,'SfigureName',SfigureName,'SexportFormat',Sexportformat)
    else
        exportFigure('figureHandle',figHandle,'SfigureName',SfigureName)
    end
end

end

