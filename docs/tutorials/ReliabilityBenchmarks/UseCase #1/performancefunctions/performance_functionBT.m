function Tout = performance_functionBT(Tin)

% Benckmark problem 
% Noise function

%% 1. Parameters


for isample=1:length(Tin)
    Tout(isample).outB=2.500-Tin(isample).RV_2-Tin(isample).RV_3;
% g2=-x2-x3;
% g3=2.323-x3-x4;
% g4=2.225-x4-x5;
% output = max([g1 g2 g3 g4],[],2);
end



