function fh = plot2DLimitState(obj, names)
    %plot2DLimitState p
    
    if ~exist('names', 'var')
        [~, idx] = sort(abs(obj.Alpha), 'descend');
        names = string(obj.Samples.Properties.VariableNames(idx(1:2)));
    end
    
    points = obj.PointsOnLine;
    lines = obj.NumberOfLines;
    sns = obj.Input.map2stdnorm(obj.Samples);
    
    fh = figure();
    
    hold on;
    grid on;
    
    % Plot samples first
    x = reshape(sns.(names(1)), length(points), lines);
    y = reshape(sns.(names(2)), length(points), lines);
    for i = 1:size(x, 2)
        plot(x([1, length(points)], i), y([1, length(points)], i), 'b');
    end
    
    % Plot limit state
    hyperPlane = sns{1:length(points):end, :} - repmat(obj.Alpha .* points(1), lines, 1);
    limitState = hyperPlane +  repmat(obj.Alpha, obj.NumberOfLines, 1) .* obj.LimitState;
    limitState = array2table(limitState);
    limitState.Properties.VariableNames = sns.Properties.VariableNames;
    
    scatter(limitState.(names(1)), limitState.(names(2)), 'rx', 'linewidth', 2);
    
    xlabel(names{1});
    ylabel(names{2});
    
    axis equal;
    axis square;
    
    hold off;
end