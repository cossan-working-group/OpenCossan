function Pout = differenceStructure(Pinput)

for i = 1:length(Pinput)
    Pout(i).diff1 = Pinput(i).Xrv1 - half(Pinput(i).Xrv2);
    Pout(i).diff2 = Pinput(i).Xrv2 - Pinput(i).Xrv1;
end

return;