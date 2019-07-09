function exportFigure(varargin)
% This method is used to export the current figure passed by handle
% Valid Property Name
% * figureHandle  : define the Handle of the figure (default gcf)
% * SfigureName   : name of the exported figure
% * SexportFormat : Export format for the figure (defauld = eps+tiff)

% Process Inputs
opencossan.OpenCossan.validateCossanInputs(varargin{:})

% Initialize variables
figureHandle=gcf;

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'hfigurehandle'
            figureHandle=varargin{k+1};
        case 'sfigurename'
            SfigureName=varargin{k+1};
        case 'sexportformat'
            SexportFormat=varargin{k+1};
        case 'sfullpath'
            SfullPath=varargin{k+1};
        otherwise
            error('openCOSSAN:common:utility:exportFigure',...
                ['PropertyName ' varargin{k} ' not valid']);
    end
end

if ~exist('SfigureName','var')
    error('openCOSSAN:common:utility:exportFigure',...
           'The SfigureName is a required field.');
end

if ~exist('SfullPath','var')
   if isempty(opencossan.OpenCossan.getWorkingPath)
        error('openCOSSAN:common:utility:exportFigure',...
           'The COSSAN working path is empty. Has COSSAN-X been initilized?');
   else
       SfullFileName=fullfile(opencossan.OpenCossan.getWorkingPath,SfigureName);
   end
else
    SfullFileName=fullfile(SfullPath,SfigureName);
end

% Export the current figure in a PDF format
if exist('SexportFormat','var')
    saveas(figureHandle,SfullFileName,SexportFormat)
else
    print('-depsc2','-tiff','-r300',SfullFileName)
end

