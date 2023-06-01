function [Xpf, Xo] = computeFailureProbability(Xhm,Xsimulation)
%COMPUTEFAILUREPROBABILITY this method estimate the failure probabilitiy of the
%hybrud model, Xhm, using a specific Simulations object passed as mandatory
%argument (Xsimulation).
%
% The method return a Failure probability as first output argument and a
% SimulationData as a second output argument.
%
% =====================================================

%% Check input
assert(any(strcmp(superclasses(Xsimulation),'Simulations')),...
    'openCOSSAN:ProbabilisticModel:computeFailureProbability',...
    ['The object ', inputname(2) ' must be a sub-class of Simulation'])

%% Estimate the FailureProbability
[Xpf, Xo]=Xsimulation.computeFailureProbability(Xhm);
