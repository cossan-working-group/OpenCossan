for j=1:length(Tinput)
    Toutput(j).out = 2.5 - 0.2357 * (Tinput(j).RV1 - Tinput(j).RV2) + 0.00463 * (Tinput(j).RV1 + Tinput(j).RV2 - 20)^4; 
end