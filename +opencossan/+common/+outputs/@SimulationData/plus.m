function XSimOut = plus(XSimOut1,XSimOut2)
%PLUS adds one SimulationData object to the other
%
%
%  Usage: PLUS(XSimOut1,XSimOut2) adds the values of the Output object XSimOut2
%  to the  valus of the Output object XSimOut1
%  Example:  plus(XSimOut1,XSimOut2)
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% =====================================================

Vindex = strcmp(XSimOut1.TableValues.Properties.VariableNames,XSimOut2.Cnames);
if ~all(Vindex)==1
    error('openCOSSAN:SimulationData:plus',...
        'the two objects do not contain the same output variables');
end

if XSimOut1.Nsamples ~= XSimOut2.Nsamples
    error('openCOSSAN:SimulationData:plus',...
        'the two objects do not contain the same number of simulations');
end

Mvalues = XSimOut1.TableValues{:,:} + XSimOut2.TableValues{:,:};

XSimOut = opencossan.common.outputs.SimulationData('Mvalues',Mvalues,'Cnames',XSimOut1.Cnames);
end

