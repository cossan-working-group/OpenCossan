function b = matvecprodNonhomogeneous(x,Vx,Xfun)

n = length(Vx);    
b = zeros(n,1); %vector storing matvec prod.

for i = 1:n,
    Vxi = repmat(Vx(:,i),1,length(Vx));
    Vxj = Vx;
    Vcov = Xfun.compute([Vxi;Vxj])';
    b(i) = Vcov*x; 
end
