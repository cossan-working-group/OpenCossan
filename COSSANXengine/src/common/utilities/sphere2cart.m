function Moutput=sphere2cart(Minput)

% 5-dimensional case
% x1 = r cos(a1)
% x2 = r sin(a1) cos(a2)
% x3 = r sin(a1) sin(a2) cos(a3)
% x4 = r sin(a1) sin(a2) sin(a3) cos(a4)
% x5 = r sin(a1) sin(a2) sin(a3) sin(a4)

[Nsamples, Nvar]=size(Minput);

Moutput=zeros(Nsamples,Nvar);

if Nvar==1
    Moutput=Minput(:,1);
else
    Moutput(:,1)=cos(Minput(:,2));
    for n=2:Nvar-1
        Moutput(:,n)=prod(sin(Minput(:,2:n)),2).*cos(Minput(:,n+1));
    end
    Moutput(:,Nvar)=prod(sin(Minput(:,2:Nvar)),2);
    Moutput=Moutput.*repmat(Minput(:,1),1,Nvar);
end