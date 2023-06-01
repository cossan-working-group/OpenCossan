function McoordSphere=cart2sphere(McoordCart)

%CART2SPHERE 

[Nsamples, Nvar]=size(McoordCart);
McoordSphere=zeros(Nsamples,Nvar);
McoordSphere(:,1)=sqrt(sum(McoordCart.^2,2));
if Nvar>2
    for ivar=2:Nvar-1
        McoordSphere(:,ivar)=acos(McoordCart(:,ivar-1)./sqrt(sum(McoordCart(:,ivar-1:Nvar).^2,2)));
    end
end

indOver=(McoordCart(:,Nvar)>=0);
indBelow=(McoordCart(:,Nvar)<0);

McoordSphere(indOver,Nvar)=acos(McoordCart(indOver,Nvar-1)./sqrt(McoordCart(indOver,Nvar).^2+McoordCart(indOver,Nvar-1).^2));


McoordSphere(indBelow,Nvar)=2*pi-acos((McoordCart(indBelow,Nvar-1)./sqrt(McoordCart(indBelow,Nvar).^2+McoordCart(indBelow,Nvar-1).^2)));

