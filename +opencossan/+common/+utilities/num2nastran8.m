function value = num2nastran8(number)
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
sh = 9;

s = 0;
if sign(number) == 1
    if number < 1e-9 && number >= 0
        aux = sprintf('%0.14e',number);
        value = [aux(1:5+s) aux(9+sh:11+sh)];
    elseif number <1 && number >= 1e-9
        aux = sprintf('%0.14e',number);
        value = [aux(1:6+s) aux(9+sh) aux(11+sh)];
    elseif number >= 1 && number < 10
        aux = sprintf('%0.14e',number);
        value = [aux(1:8+s)];
    elseif number >= 10 && number < 100
        aux = sprintf('%0.14e',number);
        value = [aux(1:6+s) aux(9+sh) aux(11+sh)];
    elseif number >= 100 && number < 1e10
        aux = sprintf('%0.14e',number);
        value = [aux(1:6+s) aux(9+sh) aux(11+sh)];
    elseif number >= 1e10
        aux = sprintf('%0.14e',number);
        value = [aux(1:5+s) aux(9+sh:11+sh)];
    end
elseif sign(number) == -1;
    number = abs(number);
    if number < 1e-9 && number >= 0
        aux = sprintf('%0.14e',number);
        value = ['-' aux(1:4+s) aux(9+sh:11+sh)];
    elseif number <1 && number >= 1e-9
        aux = sprintf('%0.14e',number);
        value = ['-' aux(1:5+s) aux(9+sh) aux(11+sh)];
    elseif number >= 1 && number < 10
        aux = sprintf('%0.14e',number);
        value = ['-' aux(1:7+s)];
    elseif number >= 10 && number < 100
        aux = sprintf('%0.14e',number);
        value = ['-' aux(1:5+s) aux(9+sh) aux(11+sh)];
    elseif number >= 100 && number < 1e10
        aux = sprintf('%0.14e',number);
        value = ['-' aux(1:5+s) aux(9+sh) aux(11+sh)];
    elseif number >= 1e10
        aux = sprintf('%0.14e',number);
        value = ['-' aux(1:4+s) aux(9+sh:11+sh)];
    end
else %sign(number) == 0;
    value = 0;
end
