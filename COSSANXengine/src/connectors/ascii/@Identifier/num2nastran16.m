function value = num2nastran16(number)
%num2NASTRAN          number in optimal NASTRAN-format
%
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2006 IfM
% =====================================================
%
% History:
% LP, 05-jul-2007
% LP, 22-aug-2007 expanded to NASTRAN 'large field format'
% =====================================================
sh = 9; %#ok<NASGU>
s = 8; %#ok<NASGU>
if sign(number) == 1
	if number < 1e-9 && number >= 0
		value = sprintf('%0.10e',number);
	elseif number <1 && number >= 1e-9
		value = sprintf('%0.10e',number);
	elseif number >= 1 && number < 10
		value = sprintf('%0.10e',number);
	elseif number >= 10 && number < 100
		value = sprintf('%0.10e',number);
	elseif number >= 100 && number < 1e10
		value = sprintf('%0.10e',number);
	elseif number > 1e10
		value = sprintf('%0.10e',number);
	end
elseif sign(number) == -1;
	number0 = abs(number);
	if number0 < 1e-9 && number0 >= 0
		value = sprintf('%0.9e',number);
	elseif number0 <1 && number0 >= 1e-9
		value = sprintf('%0.9e',number);
	elseif number0 >= 1 && number0 < 10
		value = sprintf('%0.9e',number);
	elseif number0 >= 10 && number0 < 100
		value = sprintf('%0.9e',number);
	elseif number0 >= 100 && number0 < 1e10
		value = sprintf('%0.9e',number);
	elseif number0 > 1e10
		value = sprintf('%0.9e',number);
	end
else %sign(number)==0;
	value = 0;
end

