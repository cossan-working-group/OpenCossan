function m = myCell2Mat(c)
% MYCELL2MAT this function convert a cell array into a array of doubles
% 
% Of course, myCell2Mat is drastically less flexible than the original.
% but it is faster 
% 
% EP
    
  len = cellfun('prodofsize', c);
  
  % Check if all the components have the same lengths
  if all(len==1)
      m=cell2float(c);
  else
      m = zeros(sum(len), 1);
      index = 0;
      for n = 1:numel(c)
        index2 = index + len(n);
        m(index + 1:index2) = c{n}(:); % more general: c{i}(:)
        index = index2;
      end
      m=reshape(m,length(c{1}),size(c,2))'; 
  end
% Reshape it

