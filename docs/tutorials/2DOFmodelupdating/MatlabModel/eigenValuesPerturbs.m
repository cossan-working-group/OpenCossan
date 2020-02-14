function out = eigenValuesPerturbs(in)
    
    out = table();
    y = zeros(height(in), 2);
    for i = 1:height(in)
        mat = [in.k1(i) + in.k2(i) in.k2(i); in.k2(i) in.k2(i)];
        y(i,:) = eig(mat);
    end
    out.y1 = y(:, 1) + in.p1;
    out.y2 = y(:, 2) + in.p2;
    
end