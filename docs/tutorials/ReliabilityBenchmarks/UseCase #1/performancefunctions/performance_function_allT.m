function Tout = performance_function_allT(Tin)

% Benckmark problem 
% Noise function

%% 1. Parameters

Tout=cell2struct(cell(length(Tin),1),'outALL',2);

%% 2.   Random Variables
for isample=1:length(Tin)
		x1 = Tin(isample).RV_1;
		x2 = Tin(isample).RV_2;
		x3 = Tin(isample).RV_3;
		x4 = Tin(isample).RV_4;
		x5 = Tin(isample).RV_5;
		g1=2.677-x1-x2;
		g2=2.500-x2-x3;
		g3=2.323-x3-x4;
		g4=2.225-x4-x5;
		Tout(isample).outALL = max([g1 g2 g3 g4],[],2);
end
