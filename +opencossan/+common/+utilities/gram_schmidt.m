function Q = gram_schmidt(A)
%
%
%
n = size(A,2);
Q = A;

for k = 1:n-1
  v = norm(A(:,k));
  if(v>0)
  Q(:,k) = A(:,k)/ v;
  A(:,k+1:n) = A(:,k+1:n) - Q(:,k) * (Q(:,k)'* A(:,k+1:n));
  else
  break;
  end
end
v = norm(A(:,n));
if(v>0)
  Q(:,n) = A(:,n) ./ v;
end
