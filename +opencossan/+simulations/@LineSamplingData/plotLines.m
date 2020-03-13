function fh = plotLines(obj, varargin)
%PLOTLINES
performance = obj.Samples.(obj.PerformanceFunctionVariable);
performance = reshape(performance, length(obj.PointsOnLine), obj.NumberOfLines);

fh = figure();

hold on;
plot(obj.PointsOnLine, zeros(length(obj.PointsOnLine), 1), 'r', 'linestyle', '--');

for i = 1:size(performance, 2)
    plot(obj.PointsOnLine, performance(:, i));
end

grid on;
xlabel('Distance from the orthogonal plane');
ylabel(obj.PerformanceFunctionVariable);

hold off;

end




