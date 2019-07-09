function varargout = plot3d(Xobj,varargin)
%PLOT3d Plot the sensitivity indices in a 3d bar plot

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

% Default values
LtotalIndices=true;
LupperBounds=true;
LfirstOrder=true;
LsobolIndices=false;
Svisible='on';
CinputNames=Xobj.CinputNames;

%% Add fields
for k=1:2:length(varargin),
    switch lower(varargin{k}),
        case 'lfirstorder'
            % Define indices
            LfirstOrder=varargin{k+1};
        case 'ltotalindices'
            LtotalIndices=varargin{k+1};
        case 'lupperbounds'
            LupperBounds=varargin{k+1};
        case 'lsobolindices'
            LsobolIndices=varargin{k+1};
        case 'sfigurename'
            SfigureName=varargin{k+1};
        case 'lvisible'
            if varargin{k+1}
                Svisible='on';
            else
                Svisible='off';
            end
         case 'csnames'
            CinputNames=varargin{k+1};  
        otherwise
            warning('openCOSSAN:output:SensitivityMeasures:plot',...
                ['PropertyName ' varargin{k} ' ignored']);
    end
end

% Index of the variables
Vfield=ismember(Xobj.CinputNames,CinputNames);

figHandle=figure('Visible',Svisible);
varargout{1}=figHandle;
hold(gca,'on')

%% Check if the required indices have been computed
if LsobolIndices
    % Plot Sobol' indicies
    if isempty(Xobj.VsobolIndices(Vfield))
        warning('openCOSSAN:output:SensitivityMeasures:plot3d',...
            'The Object does not contains any Sobol'' index');
        LsobolIndices=false;
    end
end

if LfirstOrder
    if isempty(Xobj.VsobolFirstIndices)
        warning('openCOSSAN:output:SensitivityMeasures:plot3d',...
            'The Object does not contains any Sobol'' first order index');
        LfirstOrder=false;
    end
end

if LtotalIndices
    if isempty(Xobj.VtotalIndices)
        warning('openCOSSAN:output:SensitivityMeasures:plot3d',...
            'The Object does not contains Total index');
        LtotalIndices=false;
    end
end

if LupperBounds
    if isempty(Xobj.VupperBounds)
        warning('openCOSSAN:output:SensitivityMeasures:plot3d',...
            'The Object does not contains upper bounds');
        LupperBounds=false;
    end
end


if LsobolIndices
    % Plot Sobol' indicies
    
    hbar=bar3(gca,Xobj.VsobolIndices,'stacked');
    title(gca,'Estimations of the sensitivity indices')
    
    set(gca,'YTickLabel',Xobj.CsobolComponentsNames,'Ytick',1:length(Xobj.CsobolComponentsNames));
    set(gca,'XTickLabel','Sobol'' sensitivity measures');
    zlabel(gca,'Normalized sensitivity measures');
    
else
    %% Plot first Order indicies, total indicies and upper bounds
    Mvalues=[];
    Clegend={};
    
    if LfirstOrder
        Mvalues=[Mvalues Xobj.VsobolFirstIndices(Vfield)'];
        Clegend{end+1}='Main effect';

    end
    
    if LtotalIndices
        Mvalues=[Mvalues Xobj.VtotalIndices(Vfield)'];
        Clegend{end+1}='Total effect (interactions)';
        
    end
    
    if LupperBounds
        Mvalues=[Mvalues Xobj.VupperBounds(Vfield)'];
        Clegend{end+1}='Upper Bounds (total effects)';
        
    end
    
    if isempty(Mvalues)
        close(figHandle);
        return
    end
    
    hbar=bar3(gca,Mvalues,'detached');
    title(gca,'Estimations of the sensitivity indices')
    
    
    set(gca,'YTickLabel',Xobj.CinputNames(Vfield),'Ytick',1:length(CinputNames));
    set(gca,'XTickLabel',Clegend,'Xtick',1:length(Clegend));
    zlabel(gca,'Normalized sensitivity measures');
    
end

grid on;
view(gca,[-290 270 180])
set(hbar(1),...
    'FaceColor',[0.0431372560560703 0.517647087574005 0.780392169952393]);

% Export Figure

if exist('SfigureName','var')
    if exist('Sexportformat','var')
        exportFigure('figureHandle',figHandle,'SfigureName',SfigureName,'SexportFormat',Sexportformat)
    else
        exportFigure('figureHandle',figHandle,'SfigureName',SfigureName)
    end
end


