function out = myind2sub(siz,ndx)
%IND2SUB Multiple subscripts from linear index.
%   IND2SUB is used to determine the equivalent subscript values
%   corresponding to a given single index into an array.

subindex=cell(1,length(siz));
nout = length(siz);
siz = double(siz);


if nout == 2
    vi = rem(ndx-1, siz(1)) + 1;
    subindex{2} = (ndx - vi)/siz(1) + 1;
    subindex{1} = vi;
else
    k = [1 cumprod(siz(1:end-1))];
    for i = nout:-1:1,
        vi = rem(ndx-1, k(i)) + 1;
        vj = (ndx - vi)/k(i) + 1;
        subindex{i} = vj;
        ndx = vi;
    end
    
end
out=[subindex{:}];

