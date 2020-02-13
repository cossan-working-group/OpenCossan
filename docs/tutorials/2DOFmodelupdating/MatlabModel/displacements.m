function out = displacements(in)
    
    out = table();
    y = zeros(height(in), 2);
    for i = 1:height(in)
        y(i, :) = ([1.0 ./ in.k1(i) 1.0 ./ in.k1(i); 1.0 ./in.k1(i) (in.k1(i) + in.k2(i)) ./ (in.k1(i) .* in.k2(i))]) * [in.F1(i); in.F2(i)];
    end
    out.y1 = y(:, 1);
    out.y2 = y(:, 2);
    
end