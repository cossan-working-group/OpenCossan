for isamples = 1:length(Tinput)
    Toutput(isamples).diff1 = Tinput(isamples).Xrv1 - Tinput(isamples).Xrv2;
    Toutput(isamples).diff2 = Tinput(isamples).Xrv2 - Tinput(isamples).Xrv1;
end

