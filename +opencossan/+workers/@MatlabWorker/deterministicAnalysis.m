function [XSimOut, Poutput] = deterministicAnalysis(Xmio,Xinput)
%DETERMINISTICANALYSIS This method evaluate the user defined
%script/function, using the nominal values of the Input 
%
%   RUN     evaluates the function defined inside the Mio object
%
%   MANDATORY ARGUMENTS:
%
%     - Xinput: input object with the model parameters
%
%   OUTPUT:
%
%   - XsimOut : SimulationData object
%   - Poutput : variables returned by the user defined script/function
%
%   USAGE:
%
%   XsimOut = deterministicAnalysis(Xmio) returns a SimulationData object
%
%   [XsimOut,Poutput] = XsimOut(Xmio,Psamples) returns the SimulationData
%   object, XsimOut; the structure/matrix of outputs, Poutput
%
%
% [EP]: P stands for polymorphism
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2010 IfM
% =====================================================


% Retrieve nominal values
Tinput=Xinput.get('DefaultValues');
% run the mio with the deafult values
[XSimOut, Poutput] = Xmio.run(Tinput);

end

