%% Tutotial for the Object FailureProbability
%
%   This tutorial is intended for showing how to use the object
%   FailureProbability.
%
%
% See Also: http://cossan.co.uk/wiki/index.php/@FailureProbability
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 

%% CREATE FailureProbability OBJECT (Constructor)
% The object FailureProbability can be constructor passing the values of the
% estimation of the failure probability, the variance of the estimator and the number of samples 
Xopf=FailureProbability('pf',0.01,'variancepf',0.00001,'Nsamples',10,'Smethod','UserDefined');

% Show the object details
display(Xopf)

%% CREATE FailureProbability OBJECT using Simulation Output
% The object can also be constructed passing a SimulationData object and
% the name of the performance function (only for MCS IS HS and SS)

% Construct a SimulationData object

T = cell2struct({rand(1,1)},'a');
Xsimout = SimulationData('Sdescription','new output','Tvalues',T);

Xopf=FailureProbability('XsimulationData',Xsimout,'Sperformancefunction','a','Smethod','MonteCarlo');

display(Xopf)

%% CREATE FailureProbability OBJECT using COSSAN objects

Xsim=MonteCarlo('Nsamples',1); %#ok<SNASGU>
Xprobmod=PerformanceFunction('Soutputname','a','Scapacity','a','Sdemand','a'); %#ok<SNASGU>
Xopf=FailureProbability('Csmembers',{'Xsimout','Xsim','Xprobmod'});

display(Xopf)

% The object passed with Cmembers must be present in the base workspace
% The object ProbabilisticModel can also be used instead of the object PerformanceFunction

%% Add new batches
Xopf=Xopf.addBatch('Xsimulationoutput',Xsimout);
% the object now contains 2 batches
display(Xopf)

Xopf=Xopf.addBatch('pf',0.1,'variancepf',0.04,'Nsamples',15,'secondMoment',0.1);

display(Xopf)


%% Show values
% display pfhat
Xopf.pfhat
% show pf of all batches
Xopf.Vpf

% display CoV
Xopf.cov
% show Variance pf all batches
Xopf.VvariancePf


