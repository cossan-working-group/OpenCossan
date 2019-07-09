x1_grid = [1 3 5 1 3 5 1 3 5];
x2_grid = [1 1 1 3 3 3 5 5 5];

mean_blgrid = zeros(length(x1_grid)*length(x1_grid));
std_blgrid = zeros(length(x1_grid)*length(x1_grid));

for i=1:length(x1_grid)
    for j=1:length(x2_grid)
        [gx, mean_blgrid((i-1)*length(x2_grid) +j), std_blgrid((i-1)*length(x2_grid) +j)] =...
            sixsigma_constraint(x1_grid(i), x2_grid(j));
    end
end

save results