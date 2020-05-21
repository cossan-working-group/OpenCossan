function fh = plot3DLimitState(obj, names)
    %plot3DLimitState 
    
    if ~exist('names', 'var')
        [~, idx] = sort(abs(obj.Alpha), 'descend');
        names = string(obj.Samples.Properties.VariableNames(idx(1:3)));
    end
    
    validateattributes(names, {'string'}, {'size', [1, 3]});
    
    points = obj.PointsOnLine;
    lines = obj.NumberOfLines;
    sns = obj.Input.map2stdnorm(obj.Samples);
    
    fh = figure();
    
    hold on;
    grid on;
    
    % Plot samples first
    x = reshape(sns.(names{1}), length(points), lines);
    y = reshape(sns.(names{2}), length(points), lines);
    z = reshape(sns.(names{3}), length(points), lines);
    
    for i = 1:lines
        plot3(x([1, length(points)], i), y([1, length(points)], i), z([1, length(points)], i), 'b');
    end
    
    % Plot limit state
    hyperPlane = sns{1:length(points):end, :} - repmat(obj.Alpha .* points(1), lines, 1);
    limitState = hyperPlane +  repmat(obj.Alpha, obj.NumberOfLines, 1) .* obj.LimitState;
    limitState = array2table(limitState);
    limitState.Properties.VariableNames = sns.Properties.VariableNames;
    
    scatter3(limitState.(names{1}), limitState.(names{2}), limitState.(names{3}), 'rx', 'linewidth', 2);
    
    xlabel(names{1});
    ylabel(names{2});
    zlabel(names{3});
    
    hold off;
end