function XSimOut = minus(XSimOut1,XSimOut2)
%MINUS substracts XSimOut2 from XSimOut1
%
%
%  Usage: MINUS(XSimOut1,XSimOut2) substracts the Output object XSimOut2
%  from XSimOut1
%  Example:  minus(XSimOut1,XSimOut2)
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% =====================================================


Vindex = strcmp(XSimOut1.TableValues.Properties.VariableNames,XSimOut2.Cnames);
if ~all(Vindex)==1
    error('openCOSSAN:SimulationData:minus',...
        'the two objects do not contain the same output variables');
end

if XSimOut1.Nsamples ~= XSimOut2.Nsamples
    error('openCOSSAN:SimulationData:minus',...
        'the two objects do not contain the same number of simulations');
end

Mvalues = XSimOut1.TableValues{:,:} - XSimOut2.TableValues{:,:};

XSimOut = opencossan.common.outputs.SimulationData('Mvalues',Mvalues,'Cnames',XSimOut1.Cnames);

end

