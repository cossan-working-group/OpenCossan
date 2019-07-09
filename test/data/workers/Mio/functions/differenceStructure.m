function Toutput = differenceStructure(Tinput)

for isample=1:length(Tinput)
    Toutput(isample).diff1 = Tinput(isample).Xrv1 - Tinput(isample).Xrv2; %#ok<AGROW>
    Toutput(isample).diff2 = Tinput(isample).Xrv2 - Tinput(isample).Xrv1; %#ok<AGROW>
end

return;