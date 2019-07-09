function varargout=plotComponents(Xobj,varargin)
%PLOTCOMPONENTS This method plot the component of the gradient in a bar
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
            Sfigurename=varargin{k+1};
        case 'stitle'
            Stitle=varargin{k+1};
        case 'nmaxcomponents'
            maxcomponents=varargin{k+1};
        case 'scolor'
            color=varargin{k+1};
        otherwise
            error('openCOSSAN:simulations:Gradient:plotComponents',...
                   ['Field name (' varargin{k} ') not allowed']);
    end
end

%% Sort results
[~, indices]=sort(abs(Xobj.Vgradient),'descend');
indices=indices(1:min(maxcomponents,length(indices)));

if ~exist('fh','var')
    fh=figure;
    Vtick=1:maxcomponents;
else
     Vtick=get(gca(fh),'Xtick');
     hold(gca(fh),'on');
end

bar(gca(fh),Xobj.Vgradient(indices),color);
title(gca(fh),Stitle);
set(gca(fh),'LineWidth',2,'Xtick',Vtick,'XTickLabel',Xobj.Cnames(indices),'FontSize',16);
    
if exist('Sfigurename','var')
    saveas(fh,Sfigurename,'pdf')
end

varargout{1}=fh;
end

