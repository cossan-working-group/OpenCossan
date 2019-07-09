function varargout = plot(Xobj,varargin)
%PLOTINDICES Plot the Sensitivity measures
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Plot@SensitivityMeasures
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria$
% Author: Edoardo Patelli

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

% Default values
LtotalIndices=true;
LupperBounds=true;
LfirstOrder=true;
LsobolIndices=false;
Svisible='on';
Lplotcov=false;
Cinputnames=Xobj.CinputNames;

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
        case 'sexportformat'
            Sexportformat=varargin{k+1}; 
        case 'lplotcov'
            Lplotcov=varargin{k+1};   
        case 'csnames'
            Cinputnames=varargin{k+1};   
        case 'lvisible'
            if varargin{k+1}
                Svisible='on';
            else
                Svisible='off';
            end
        otherwise
            warning('openCOSSAN:output:SensitivityMeasures:plot',...
                ['PropertyName ' varargin{k} ' ignored']);
    end
end

figHandle=figure('Visible',Svisible);
varargout{1}=figHandle;
hold(gca,'on')
Stitle='Estimations of the sensitivity indices\newline';
%% Check if the required indices have been computed
if LsobolIndices
    % Plot Sobol' indicies
    if isempty(Xobj.VsobolIndices)
%         warning('openCOSSAN:output:SensitivityMeasures:plot',...
%             'The Object does not contains any Sobol'' index');
        LsobolIndices=false;
    end
end

if LfirstOrder
    if isempty(Xobj.VsobolFirstIndices)
%         warning('openCOSSAN:output:SensitivityMeasures:plot',...
%             'The Object does not contains any Sobol'' first order index');
        LfirstOrder=false;
    end
end

if LtotalIndices
    if isempty(Xobj.VtotalIndices)
%         warning('openCOSSAN:output:SensitivityMeasures:plot',...
%             'The Object does not contains Total index');
        LtotalIndices=false;
    end
end

if LupperBounds
    if isempty(Xobj.VupperBounds)
%         warning('openCOSSAN:output:SensitivityMeasures:plot',...
%             'The Object does not contains upper bounds');
        LupperBounds=false;
    end
end

% Not used for sobol indicies
Vfield=ismember(Xobj.CinputNames,Cinputnames);

if LsobolIndices
    % Plot Sobol' indicies
    
    hbar=bar(gca,Xobj.VsobolIndices,'grouped');
    title(gca,Stitle)
    legend(gca,'Sobol'' sensitivity measures')
    set(gca,'XTickLabel',Xobj.CsobolComponentsNames,'Xtick',1:length(Xobj.CsobolComponentsNames));
    %xticklabel_rotate;
    ylabel('Normalized sensitivity measures');
    
    if ~isempty(Xobj.VsobolIndicesCoV) && Lplotcov
        stdError = (Xobj.VsobolIndicesCoV-1).*Xobj.VsobolIndices;
        heb=errorbar(Xobj.VsobolIndices,stdError,'LineWidth',2);
        set(heb,'LineStyle','none','Marker','.','Color','b');
    elseif ~isempty(Xobj.MsobolIndicesCI)
        errorLow = Xobj.VsobolIndices-Xobj.MsobolIndicesCI(1,Vfield);
        errorUp = Xobj.MsobolIndicesCI(2,Vfield)-Xobj.VsobolIndices;
        hebCI=errorbar(Xobj.VsobolIndices,errorLow,errorUp,'LineWidth',2);
        set(hebCI,'LineStyle','none','Marker','.','Color','c');
    end
else
    %% Plot first Order indicies, total indicies and upper bounds
    Mvalues=[];
    Clegend={};
    
    if LfirstOrder
        Mvalues=[Mvalues Xobj.VsobolFirstIndices(Vfield)'];
        Clegend{end+1}='Main effect';
        
        if ~isempty(Xobj.VsobolFirstIndicesCoV)  && Lplotcov
            stdErrorFirstLow = (Xobj.VsobolFirstIndicesCoV(Vfield)-1).*Xobj.VsobolFirstIndices(Vfield);
            stdErrorFirstUp=stdErrorFirstLow;
        elseif ~isempty(Xobj.MsobolFirstIndicesCI)
            stdErrorFirstLow = Xobj.VsobolFirstIndices(Vfield)-Xobj.MsobolFirstIndicesCI(1,Vfield);
            stdErrorFirstUp = Xobj.MsobolFirstIndicesCI(2,Vfield)-Xobj.VsobolFirstIndices(Vfield);
        end
    end
    
    if LtotalIndices
        Mvalues=[Mvalues Xobj.VtotalIndices(Vfield)'];
        Clegend{end+1}='Total effect (interactions)';
        
        if ~isempty(Xobj.VtotalIndicesCoV) && Lplotcov
            stdErrorTotalLow = (Xobj.VtotalIndicesCoV(Vfield)-1).*Xobj.VtotalIndices(Vfield);
            stdErrorTotalUp=stdErrorTotalLow;
        elseif ~isempty(Xobj.MtotalIndicesCI)
            stdErrorTotalLow = Xobj.VtotalIndices(Vfield)-Xobj.MtotalIndicesCI(1,Vfield);
            stdErrorTotalUp = Xobj.MtotalIndicesCI(2,Vfield)-Xobj.VtotalIndices(Vfield);
        end
    end
    
    if LupperBounds
        Mvalues=[Mvalues Xobj.VupperBounds(Vfield)'];
        Clegend{end+1}='Upper Bounds (total effects)';
        
        if ~isempty(Xobj.VupperBoundsCoV)  && Lplotcov
            stdErrorUpperLow = (Xobj.VupperBoundsCoV(Vfield)-1).*Xobj.VupperBounds(Vfield);
            stdErrorUpperUp=stdErrorUpperLow;
        elseif ~isempty(Xobj.MupperBoundsCI)
            stdErrorUpperLow = Xobj.VupperBounds(Vfield)-Xobj.MupperBoundsCI(1,Vfield);
            stdErrorUpperUp = Xobj.MupperBoundsCI(2,Vfield)-Xobj.VupperBounds(Vfield);
        end
    end
    
    if Lplotcov
       Stitle=[Stitle ' error bars (+/- 1 std)'];
    else
       Stitle=[Stitle ' Confidence Intervals: ' sprintf('%3.2f%% %3.2f%%',Xobj.Valpha*100)];
    end
    
    if isempty(Mvalues)
        close(figHandle);
        return
    end
    
    hbar=bar(gca,Mvalues,'grouped');
    title(gca,Stitle)
    legend(gca,Clegend)
    set(gca,'XTickLabel',Xobj.CinputNames(Vfield),'Xtick',1:length(Xobj.CinputNames(Vfield)));
    %xticklabel_rotate;
    ylabel(gca,'Normalized sensitivity measures');
    
    %% Plot for the different cases
    if LfirstOrder
        if LtotalIndices
            if LupperBounds
                % CASE 7
                if exist('stdErrorFirstLow','var')
                    heb1=errorbar(gca,1:length(Xobj.VsobolFirstIndices(Vfield)),Xobj.VsobolFirstIndices(Vfield),...
                        stdErrorFirstLow,stdErrorFirstUp,'LineWidth',2);
                    set(heb1,'Xdata',get(heb1,'Xdata')-0.22);
                    set(heb1,'LineStyle','none','Marker','.','Color','b');
                end
                
                
                if exist('stdErrorTotalLow','var')
                    heb2=errorbar(gca,1:length(Xobj.VtotalIndices(Vfield)),Xobj.VtotalIndices(Vfield),...
                        stdErrorTotalLow,stdErrorTotalUp,'LineWidth',2);
                    set(heb2,'LineStyle','none','Marker','.','Color','g');
                end
                
                if exist('stdErrorUpper','var')
                    heb3=errorbar(gca,1:length(Xobj.VupperBounds(Vfield)),Xobj.VupperBounds(Vfield),...
                        stdErrorUpperLow,stdErrorUpperUp,'LineWidth',2);
                    set(heb3,'Xdata',get(heb3,'Xdata')+0.22);
                    set(heb3,'LineStyle','none','Marker','.','Color','r');
                end
            else
                % CASE 4
                if exist('stdErrorFirstLow','var')
                    heb1=errorbar(gca,1:length(Xobj.VsobolFirstIndices(Vfield)),Xobj.VsobolFirstIndices(Vfield),...
                        stdErrorFirstLow,stdErrorFirstUp,'LineWidth',2);
                    set(heb1,'Xdata',get(heb1,'Xdata')-0.15);
                    set(heb1,'LineStyle','none','Marker','.','Color','b');
                end
                if exist('stdErrorTotalLow','var')
                    heb2=errorbar(gca,1:length(Xobj.VtotalIndices(Vfield)),Xobj.VtotalIndices(Vfield),...
                        stdErrorTotalLow,stdErrorTotalUp,'LineWidth',2);
                    set(heb2,'Xdata',get(heb2,'Xdata')+0.15);
                    set(heb2,'LineStyle','none','Marker','.','Color','r');
                end
            end
        else
            if LupperBounds
                % CASE 6
                if exist('stdErrorFirstLow','var')
                    heb1=errorbar(gca,1:length(Xobj.VsobolFirstIndices(Vfield)),Xobj.VsobolFirstIndices(Vfield),...
                        stdErrorFirstLow,stdErrorFirstUp,'LineWidth',2);
                    set(heb1,'Xdata',get(heb1,'Xdata')-0.15);
                    set(heb1,'LineStyle','none','Marker','.','Color','b');
                end
                if exist('stdErrorUpperLow','var')
                    heb3=errorbar(gca,1:length(Xobj.VupperBounds(Vfield)),Xobj.VupperBounds(Vfield),...
                        stdErrorUpperLow,stdErrorUpperUp,'LineWidth',2);
                    set(heb3,'Xdata',get(heb3,'Xdata')+0.15);
                    set(heb3,'LineStyle','none','Marker','.','Color','r');
                end
                
            else
                % CASE 1
                if exist('stdErrorFirstLow','var')
                    heb1=errorbar(gca,1:length(Xobj.VsobolFirstIndices(Vfield)),Xobj.VsobolFirstIndices(Vfield),...
                        stdErrorFirstLow,stdErrorFirstUp,'LineWidth',2);
                    set(heb1,'LineStyle','none','Marker','.','Color','b');
                end
            end
        end
    else
        if LtotalIndices
            if LupperBounds
                % CASE 5
                if exist('stdErrorTotalLow','var')
                    heb2=errorbar(gca,1:length(Xobj.VtotalIndices(Vfield)),Xobj.VtotalIndices(Vfield),...
                        stdErrorTotalLow,stdErrorTotalUp,'LineWidth',2);
                set(heb2,'Xdata',get(heb2,'Xdata')-0.15);
                set(heb2,'LineStyle','none','Marker','.','Color','b');
                end
                if exist('stdErrorUpperLow','var')
                    heb3=errorbar(gca,1:length(Xobj.VupperBounds(Vfield)),Xobj.VupperBounds(Vfield),...
                        stdErrorUpperLow,stdErrorUpperUp,'LineWidth',2);
                set(heb3,'Xdata',get(heb3,'Xdata')+0.15);
                set(heb3,'LineStyle','none','Marker','.','Color','r');
                end
            else
                % CASE 2
                if exist('stdErrorTotalLow','var')
                    heb2=errorbar(gca,1:length(Xobj.VsobolFirstIndices(Vfield)),Xobj.VtotalIndices(Vfield),...
                            stdErrorTotalLow,stdErrorTotalUp,'LineWidth',2);
                    set(heb2,'LineStyle','none','Marker','.','Color','b');
                end
            end
        else
            if LupperBounds
                if exist('stdErrorUpperLow','var')
                    heb3=errorbar(gca,1:length(Xobj.VupperBounds(Vfield)),Xobj.VupperBounds(Vfield),...
                        stdErrorUpperLow,stdErrorUpperUp,'LineWidth',2);
                    set(heb3,'LineStyle','none','Marker','.','Color','b');
                end
            else
                % CASE NONE
            end
        end
    end   
end

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



