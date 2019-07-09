%% %% Tutorial Beam 3-point bending (Performing Reliability Analysis)
% Here reliability analysis will be performed with the Beam 3-point bending model. 
% A performance function requires to be defined before performing reliability analysis. In this example failure is defined as a displacement of the mid-point of the beam below a critical value. Here failure occurs when the displacement is above 0.015 mm. A parameter whose value is the critical displacement is created. 
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/Beam_3-point_bending_(overview)
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Pierre~Beaurepaire$ 

%set random stream
OpenCossan.resetRandomNumberGenerator(31415)
assert(logical(exist('Xmodel','var')),'openCOSSAN:Tutorials',...
    'Please define first the model of teh 3-point bending beam')

%% Define a Performance Function

Xperfun = reliability.PerformanceFunction('OutputName','Vg','Demand','disp','Capacity','max_disp');

%% Define a Probabilistic Model

XprobModel = reliability.ProbabilisticModel('Xmodel',Xmodel,'XperformanceFunction',Xperfun);

%% Perform Reliability Analysis using DMCS

% the number of samples is adapted to the solver used
if isa(Xmodel.Xevaluator.CXsolvers{1},'workers.Mio')
    Nsamples = 1e4;
else
    Nsamples = 100;
end

% Define a MonteCarlo simulation
Xmc = simulations.MonteCarlo('Nsamples',Nsamples,'Nbatches',1);

% Perform the MonteCarlo simulation
[Xpf Xo] = Xmc.computeFailureProbability(XprobModel);

% See summary of the results
display(Xpf)

% Reference solution:
% Matlab  Pf  ~ 5.750e-02
% Ansys   Pf  ~ 1.000e-02
% Abaqus  Pf  ~ 7.000e-02
% Nastran Pf  ~ 7.000e-02
