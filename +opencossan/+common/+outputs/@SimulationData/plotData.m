function varargout=plotData(Xobj,varargin)
%PLOTDATA This method plots the variables stored in the SimulationData object
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/plotData@SimulationData
%
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli

%% Process inputs
Stitle=Xobj.Sdescription;
Svisible='on';
NfontSize=16;
Lstatistics=true;
Cnames=Xobj.Cnames;

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'sfigurename'
            SfigureName=varargin{k+1};
        case 'sexportformat'
            Sexportformat=varargin{k+1};
        case 'nfontsize'
            NfontSize=varargin{k+1};
        case 'lvisible'
            if varargin{k+1}
                Svisible='on';
            else
                Svisible='off';
            end
        case 'stitle'
            Stitle=varargin{k+1};
        case 'sname'
            %check input
            Cnames = varargin(k+1);
        case {'cnames','csname'}
            %check input
            Cnames = varargin{k+1};
        case {'lstatistics'}
            Lstatistics=varargin{k+1};
        otherwise
            error('openCOSSAN:Optimum:plotConstraint',...
                ['PropetyName (' varargin{k} ') not allowed']);
    end
end



[Mstats Mout]= getStatistics(Xobj,'Cnames',Cnames);

% Initialize figure
figHandle=figure('Visible',Svisible);
varargout{1}=figHandle;
% Create axes
axes1 = axes('Parent',figHandle);
box(axes1,'on');
hold(axes1,'all');


for n=1:size(Mstats,2)
    % Create plot
    plot1 = plot(1:Xobj.Nsamples,Mout(:,n),'Parent',axes1,'DisplayName',Cnames{n});
    if Lstatistics
        % Get xdata from plot
        xdata1 = get(plot1, 'xdata');
        % Get ydata from plot
        ydata1 = get(plot1, 'ydata');
        % Make sure data are column vectors
        xdata1 = xdata1(:);
        ydata1 = ydata1(:);
        
        % Get axes xlim
        axXLim1 = get(axes1, 'xlim');
        
        % Find the min
        ymin1 = min(ydata1);
        % Get coordinates for the min line
        minValue1 = [ymin1 ymin1];
        % Plot the min
        statLine1 = plot(axXLim1,minValue1,'DisplayName',' * min','Parent',axes1,...
            'Tag','min y',...
            'LineStyle','-.',...
            'Color',[0 0.75 0.75]);
        
        % Set new line in proper position
        setLineOrder(axes1, statLine1, plot1);
        
        % Find the max
        ymax1 = max(ydata1);
        % Get coordinates for the max line
        maxValue1 = [ymax1 ymax1];
        % Plot the max
        statLine2 = plot(axXLim1,maxValue1,'DisplayName',' * max','Parent',axes1,...
            'Tag','max y',...
            'LineStyle','-.',...
            'Color',[0 0 1]);
        
        % Set new line in proper position
        setLineOrder(axes1, statLine2, plot1);
        
        % Find the mean
        ymean1 = mean(ydata1);
        % Get coordinates for the mean line
        meanValue1 = [ymean1 ymean1];
        % Plot the mean
        statLine3 = plot(axXLim1,meanValue1,'DisplayName',' * mean','Parent',axes1,...
            'Tag','mean y',...
            'LineStyle','-.',...
            'Color',[0 0.5 0]);
        
        % Set new line in proper position
        setLineOrder(axes1, statLine3, plot1);
        
        % Find the median
        ymedian1 = median(ydata1);
        % Get coordinates for the median line
        medianValue1 = [ymedian1 ymedian1];
        % Plot the median
        statLine4 = plot(axXLim1,medianValue1,'DisplayName',' * median','Parent',axes1,...
            'Tag','median y',...
            'LineStyle','-.',...
            'Color',[1 0 0]);
        
        % Set new line in proper position
        setLineOrder(axes1, statLine4, plot1);
        
        % Find the std
        ystd1 = std(ydata1);
        
        % Prepare values to plot std; first find the mean
        ymean2 = mean(ydata1);
        % Compute bounds as mean +/- std
        lowerBound1 = ymean2 - ystd1;
        upperBound1 = ymean2 + ystd1;
        % Get coordinates for the std bounds line
        stdValue1 = [lowerBound1 lowerBound1 NaN upperBound1 upperBound1 NaN];
        axXStdLim1 = [axXLim1 NaN axXLim1 NaN];
        
        % Plot the bounds
        statLine5 = plot(axXStdLim1,stdValue1,'DisplayName',' * std','Parent',axes1,...
            'Tag','std y',...
            'LineStyle','-.',...
            'Color',[0.75 0 0.75]);
        
        % Set new line in proper position
        setLineOrder(axes1, statLine5, plot1);
    end
end
% Create legend


set(gca(figHandle),'Box','on','FontSize',NfontSize)
title(gca(figHandle),Stitle);

legend1 = legend(axes1,'show');
set(legend1,'FontSize',NfontSize-4);

xlabel(gca(figHandle),'Realizations')
ylabel(gca(figHandle),'Values')

% Export Figure
if exist('SfigureName','var')
    if exist('Sexportformat','var')
        exportFigure('figureHandle',figHandle,'SfigureName',SfigureName,'SexportFormat',Sexportformat)
    else
        exportFigure('figureHandle',figHandle,'SfigureName',SfigureName)
    end
end

end

%-------------------------------------------------------------------------%
function setLineOrder(axesh1, newLine1, associatedLine1)
%SETLINEORDER(AXESH1,NEWLINE1,ASSOCIATEDLINE1)
%  Set line order
%  AXESH1:  axes
%  NEWLINE1:  new line
%  ASSOCIATEDLINE1:  associated line

% Get the axes children
hChildren = get(axesh1,'Children');
% Remove the new line
hChildren(hChildren==newLine1) = [];
% Get the index to the associatedLine
lineIndex = find(hChildren==associatedLine1);
% Reorder lines so the new line appears with associated data
hNewChildren = [hChildren(1:lineIndex-1);newLine1;hChildren(lineIndex:end)];
% Set the children:
set(axesh1,'Children',hNewChildren);

end


