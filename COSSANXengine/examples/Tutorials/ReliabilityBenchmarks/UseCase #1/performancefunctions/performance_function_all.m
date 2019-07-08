function [output] = performance_function_all(MX)

% Benckmark problem 
% Noise function

%% 1. Parameters

%% 2.   Random Variables
switch size(MX,2)
	case 1
		error('Too few RV');
	case 2 % HJP example
		x1 = MX(:,1);
		x2 = MX(:,2);
		g1=2.677-x1-x2;
		g2=2.500+x1-x2;	
		output = max([g1 g2],[],2);
	case 3
		x1 = MX(:,1);
		x2 = MX(:,2);
		x3 = MX(:,3);
		g1=2.677-x1-x2;
		g2=2.500-x2-x3;
		output = max([g1 g2],[],2);
	case 4
		x1 = MX(:,1);
		x2 = MX(:,2);
		x3 = MX(:,3);
		x4 = MX(:,4);
		g1=2.677-x1-x2;
		g2=2.500-x2-x3;
		g3=2.323-x3-x4;
		output = max([g1 g2 g3 ],[],2);
	otherwise
		x1 = MX(:,1);
		x2 = MX(:,2);
		x3 = MX(:,3);
		x4 = MX(:,4);
		x5 = MX(:,5);
		g1=2.677-x1-x2;
		g2=2.500-x2-x3;
		g3=2.323-x3-x4;
		g4=2.225-x4-x5;
		output = max([g1 g2 g3 g4],[],2);
end
