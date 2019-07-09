function b = matvecprodHomogeneous(x,Vx,Xfun)

n = length(Vx);    
b = zeros(n,1); %vector storing matvec prod.

Vxi = repmat(Vx(:,1),1,length(Vx));
Vxj = Vx;
Vcov1 = Xfun.evaluate([Vxi;Vxj])';

for i = 1:n,
    Vcov = [fliplr(Vcov1(1:i)) Vcov1(2:end-(i-1))];
    b(i) = Vcov*x; 
end
