function fh = plot2DLimitState(obj, names)
    %plot2DLimitState
    
    if ~exist('names', 'var')
        [~, idx] = sort(abs(obj.Alpha), 'descend');
        names = string(obj.Samples.Properties.VariableNames(idx(1:2)));
    end
    
    fh = figure();
    
    hold on;
    grid on;
    
    x = find(obj.Samples.Properties.VariableNames == names(1));
    y = find(obj.Samples.Properties.VariableNames == names(2));
    
    %% Plot first and last alpha
    alpha = obj.LineData{[1, end], 'alpha'};
    c = obj.LineData{[1, end], 'c'};
    
    l1 = plot([0 c(1) * alpha(1,1)], [0 c(1) * alpha(1,2)], 'color', '#D95319', 'linestyle', '-', 'linewidth', 2);
    l2 = plot([0 c(2) * alpha(2,1)], [0 c(2) * alpha(2,2)], 'color', '#77AC30', 'linestyle', '-', 'linewidth', 2);
    
    %% Plot lines
    for i = 2:height(obj.LineData)
        u1 = obj.LineData{i, 'u'}([x y]);
        c = obj.LineData{i, 'c'};
        alpha = obj.LineData{i, 'alpha'};
        
        u2 = u1 + c * alpha;
        
        plot([u1(1) u2(1)], [u1(2) u2(2)], 'color', '#0072BD', 'linestyle', ':');
        plot(u2(1), u2(2), 'x', 'color', '#D95319', 'linewidth', 2);
    end
    
    %% Plot Hyperplane
    [~, xmin] = min(obj.LineData{:, 'u'}(:, x));
    [~, xmax] = max(obj.LineData{:, 'u'}(:, x));
    
    x = obj.LineData{:, 'u'}(:, x);
    x = x([xmin, xmax]);
    y = obj.LineData{:, 'u'}(:, y);
    y = y([xmin, xmax]);
    
    plot(x, y, 'b', 'linestyle', '--', 'linewidth', 2);
    
    xlabel(names{1});
    ylabel(names{2});
    
    legend([l1 l2], 'Initial Direction', 'Final Direction');
    
    hold off;
end