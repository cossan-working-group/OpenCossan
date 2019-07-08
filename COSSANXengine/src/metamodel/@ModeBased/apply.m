function Xmodes = apply(Xobj,Xinput)


if ~isempty(Xinput.Xsamples)
    X = Xinput.Xsamples.MsamplesStandardNormalSpace;
else
    error('openCOSSAN:metamodel:apply',...
        'Xinput does not contain any samples.');
end


Xmodes = Modes;

for isim = 1:size(X,1)
    Vapprox = Xobj.Mlincomb*X(isim,:)';
    
    Vlambda = zeros(max(Xobj.Vmodes),1);
    Phi = zeros(size(Xobj.Xmodes0.MPhi,1),max(Xobj.Vmodes));
    Nskip = 0;
    
    if size(Xobj.Vmodes,1)>1
        Xobj.Vmodes = Xobj.Vmodes';
    end
    
    for k = Xobj.Vmodes
        Vlambda(k) = (1+Vapprox(2+Nskip))^2*Xobj.Xmodes0.Vlambda(k);
        Valpha_hat = Vapprox(3+Nskip:3+Nskip+length(Xobj.Cindexmodes{k})-2);
        kk = find(Xobj.Cindexmodes{k} == k);
        alphakk_hat = (1+Vapprox(1+Nskip))*sqrt(1-sum(Valpha_hat.^2));
        Phi(:,k) = alphakk_hat*Xobj.Xmodes0.MPhi(:,k);
        ii = 0;
        for mkmodes = setdiff(1:length(Xobj.Cindexmodes{k}),kk)
            ii = ii+1;
            Phi(:,k) = Phi(:,k) + (1+Vapprox(1+Nskip))* ...
                Valpha_hat(ii)*Xobj.Xmodes0.MPhi(:,Xobj.Cindexmodes{k}(mkmodes));
        end
        Nskip = Nskip + length(Xobj.Cindexmodes{k})+1;
        Phi(:,k) = Phi(:,k)/sqrt(Phi(:,k)'*Xobj.Mmass0*Phi(:,k));
    end
    Xmodes(isim).MPhi = Phi;
    Xmodes(isim).Vlambda = Vlambda;
end

return;