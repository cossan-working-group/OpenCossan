for j=1:length(Tinput)
    Toutput(j).out = sin(5 * Tinput(j).RV1/2) + 2 - ...
        ( Tinput(j).RV1^2 + 4) * ( Tinput(j).RV2 - 1 )/20; 
end