%% Reliability Problem 14
%  Target: pF=7.52e-3, beta=2.42
%
%% SID: 1 - PID: 1

Sfolder = fileparts(mfilename('fullpath'));% returns the current folder

%% Monte Carlo
% Calculare reference solution
Xsimulator=MonteCarlo('Nsamples',500000);
% Define the model
run(fullfile(Sfolder,'RP14','RP14.m'))
% Here we go
[XpF, Xoutput] = Xpm.computeFailureProbability(Xsimulator);
sprintf('Failure probability %6.2e (Beta: %4.2f)',XpF.pfhat,XpF.reliabilityIndex)

makePlots(Xoutput,'mc')


%%%% END OF THE EXAMPLE with readeable format %%%%

%% Monte Carlo
specs = struct(...
    'SimType','MC',...
    'N',10000,...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP14');
beta
XpF
Xoutput
% beta =
% 
%     3.0115
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with MonteCarlo method
% ** First Moment
% *** Pfhat     = 1.300e-03
% *** Std       = 3.603e-04
% *** CoV       = 2.772e-01
% ** Second Moment
% *** variance  = 1.298e-03
% ** Simulation details
% *** # samples  = 1.000e+04
% *** # batches  =         1
% *** # lines    =         0
% *** Exit Flag = Maximum no. of samples reached. Samples computed 10000; Maximum allowed samples: 10000
% ===================================================================
% SimulationData Object  - Description:  - apply(@evaluator) - apply(@Model) - apply(@ProbabilisticModel)
% ===================================================================
% * Number of Variables: 8
% ** RV1; RV2; RV3; RV4; RV5; Xthreshold; out; Vg;
% Number of realizations: 10000
%% Line Sampling
% ['IND','PHY','SNS']
specs = struct(...
    'SimType','LS',...
    'N',20,...
    ...'Vset',[0.5,1,2,3,5],...
    'Vset',[2,3,4,5,6],...
    'grad','IND',...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP14');
beta
XpF
Xoutput
% beta =
% 
%     3.1266
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with LineSampling method
% ** First Moment
% *** Pfhat     = 8.843e-04
% *** Std       = 6.797e-04
% *** CoV       = 7.687e-01
% ** Second Moment
% *** variance  =       NaN
% ** Simulation details
% *** # samples  = 1.000e+02
% *** # batches  =         1
% *** # lines    =        20
% *** Exit Flag = Maximum no. of samples reached. Samples computed 100; Maximum allowed samples: 100
% ===================================================================
% LineSamplingOutput Object  - Description: 
% ===================================================================
% * Number of Variables: 8
% ** RV1; RV2; RV3; RV4; RV5; Xthreshold; out; Vg;
% * Batch: 1 - Number of realizations: 100
% * Exit Flag: Maximum no. of samples reached. Samples computed 100; Maximum allowed samples: 100
% * Number of lines: 20
% * Evaluation Points: 100
%% Adaptive Line Sampling
specs = struct(...
    'SimType','ALS',...
    'N',15,...
    ...'Vset',[0.5,1,2,3,5],...
    ...'Vset',[2,3,4,5,6],...
    ...'grad','IND',...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP14');
beta
XpF
Xoutput
% beta =
% 
%     3.3154
% Maximum no. of lines reached. Lines computed 30; Max Lines : 30
% ===================================================================
% FailureProbability Object  -  Description:
% ===================================================================
% * Results obtained with AdaptiveLineSampling method
% ** First Moment
% *** Pfhat     = 7.846e-04
% *** Std       = 1.462e-04
% *** CoV       = 1.864e-01
% ** Second Moment
% *** variance  =       NaN
% ** Simulation details
% *** # samples  = 1.460e+02
% *** # batches  =         1
% *** # lines    =        30
% *** Exit Flag = Maximum no. of lines reached. Lines computed 30; Max Lines : 30
% Number of realizations: 96













%% RP24 - Target: 2.86 1e-3, beta=2.76
%% Set id: 1, Problem id: 2
%% 2 Variables
%% Monte Carlo
specs = struct(...
    'SimType','MC',...
    'N',500000,...
    'plot1', no);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP24');
% Maximum no. of samples reached. Samples computed 500000; Maximum allowed samples: 500000
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with MonteCarlo method
% ** First Moment
% *** Pfhat     = 2.820e-03
% *** Std       = 7.499e-05
% *** CoV       = 2.659e-02
% ** Second Moment
% *** variance  = 2.812e-03
% ** Simulation details
% *** # samples  = 5.000e+05
% *** # batches  =         1
% *** # lines    =         0
% *** Exit Flag = Maximum no. of samples reached. Samples computed 500000; Maximum allowed samples: 500000
%% Monte Carlo with limited number of samples
specs = struct(...
    'SimType','MC',...
    'N',10000,...
    'plot1', no);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP24');
beta
XpF
% beta =
% 
%     2.7703
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with MonteCarlo method
% ** First Moment
% *** Pfhat     = 2.820e-03
% *** Std       = 7.499e-05
% *** CoV       = 2.659e-02
% ** Second Moment
% *** variance  = 2.812e-03
% ** Simulation details
% *** # samples  = 5.000e+05
% *** # batches  =         1
% *** # lines    =         0
% *** Exit Flag = Maximum no. of samples reached. Samples computed 500000; Maximum allowed samples: 500000
% [Status:Evaluator  ]       * Processing solver 1/1
% [Simulation:exportResults] Writing partial results (SimulationData_batch_1_of_1) on the folder: /Users/marco/Documents/MATLAB/20200220T164933
% Maximum no. of samples reached. Samples computed 10000; Maximum allowed samples: 10000
%% Line Sampling
['IND','PHY','SNS']
specs = struct(...
    'SimType','LS',...
    'N',20,...
    ...'Vset',[0.5,1,2,3,5],...
    'Vset',[2,3,4,5],...
    'grad','IND',...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP24');
beta
XpF
Xoutput
% beta =
% 
%     2.7581
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with LineSampling method
% ** First Moment
% *** Pfhat     = 2.907e-03
% *** Std       = 6.044e-04
% *** CoV       = 2.079e-01
% ** Second Moment
% *** variance  =       NaN
% ** Simulation details
% *** # samples  = 8.000e+01
% *** # batches  =         1
% *** # lines    =        20
% *** Exit Flag = Maximum no. of samples reached. Samples computed 80; Maximum allowed samples: 80
% ===================================================================
% LineSamplingOutput Object  - Description: 
% ===================================================================
% * Number of Variables: 5
% ** RV1; RV2; Xthreshold; out; Vg;
% * Batch: 1 - Number of realizations: 80
%% Adaptive Line Sampling
specs = struct(...
    'SimType','ALS',...
    'N',20,...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP24');
beta
XpF
Xoutput
% beta =
% 
%     1.6208
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with AdaptiveLineSampling method
% ** First Moment
% *** Pfhat     = 5.253e-02
% *** Std       = 4.987e-02
% *** CoV       = 9.493e-01
% ** Second Moment
% *** variance  =       NaN
% ** Simulation details
% *** # samples  = 6.900e+01
% *** # batches  =         1
% *** # lines    =        20
% *** Exit Flag = Maximum no. of lines reached. Lines computed 20; Max Lines : 20

% * Batch: 1 - Number of realizations: 69
%%
%%
%%
%% 













%%
%% RP31 - Target: 1.80 1e4, beta = 3.58
%% addpath(pwd)
%% Monte Carlo
specs = struct(...
    'SimType','MC',...
    'N',10000,...
    'plot1', no);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP31');
beta
XpF
% beta =
% 
%     2.6783
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with MonteCarlo method
% ** First Moment
% *** Pfhat     = 3.700e-03
% *** Std       = 6.072e-04
% *** CoV       = 1.641e-01
% ** Second Moment
% *** variance  = 3.687e-03
% ** Simulation details
% *** # samples  = 1.000e+04
% *** # batches  =         1
% *** # lines    =         0
% *** Exit Flag = Maximum no. of samples reached. Samples computed 10000; Maximum allowed samples: 10000
%% Line Sampling
specs = struct(...
    'SimType','LS',...
    'N',15,...
    'Vset',[1,2,3,6],...
    'grad','IND',...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP31');
beta
XpF
Xoutput
% beta =
% 
%     2.8397
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with LineSampling method
% ** First Moment
% *** Pfhat     = 2.257e-03
% *** Std       = 1.321e-03
% *** CoV       = 5.850e-01
% ** Second Moment
% *** variance  =       NaN
% ** Simulation details
% *** # samples  = 6.000e+01
% *** # batches  =         1
% *** # lines    =        15
% *** Exit Flag = Maximum no. of samples reached. Samples computed 60; Maximum allowed samples: 60
% ===================================================================
% LineSamplingOutput Object  - Description: 
% ===================================================================
% * Number of Variables: 5
% ** RV1; RV2; Xthreshold; out; Vg;
% * Batch: 1 - Number of realizations: 60
%% Adaptive Line Sampling
specs = struct(...
    'SimType','ALS',...
    'N',15,...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP31');
beta
XpF
Xoutput





%%
%% RP53 - Target: 3.13 1e2, beta = 1.86
%% Monte Carlo
specs = struct(...
    'SimType','MC',...
    'N',500000,...
    'plot1', no);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP53');
XpF
% Maximum no. of samples reached. Samples computed 500000; Maximum allowed samples: 500000
% ===================================================================
% FailureProbability Object  -  Description:
% ===================================================================
% * Results obtained with MonteCarlo method
% ** First Moment
% *** Pfhat     = 3.128e-02
% *** Std       = 2.462e-04
% *** CoV       = 7.870e-03
% ** Second Moment
% *** variance  = 3.030e-02
% ** Simulation details
% *** # samples  = 5.000e+05
% *** # batches  =         1
% *** # lines    =         0
% *** Exit Flag = Maximum no. of samples reached. Samples computed 500000; Maximum allowed samples: 500000
%
% beta = 1.8623;
%% Monte Carlo
specs = struct(...
    'SimType','MC',...
    'N',10000,...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP53');
beta 
XpF
% beta =
% 
%     1.8564
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with MonteCarlo method
% ** First Moment
% *** Pfhat     = 3.170e-02
% *** Std       = 1.752e-03
% *** CoV       = 5.527e-02
% ** Second Moment
% *** variance  = 3.070e-02
% ** Simulation details
% *** # samples  = 1.000e+04
% *** # batches  =         1
% *** # lines    =         0
% *** Exit Flag = Maximum no. of samples reached. Samples computed 10000; Maximum allowed samples: 10000
%% Line Sampling
specs = struct(...
    'SimType','LS',...
    'N',10,...
    'Vset',[0.5,1,2,3,5],...
    'grad','IND',...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP53');
beta
XpF
Xoutput
% beta =
% 
%     1.9404
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with LineSampling method
% ** First Moment
% *** Pfhat     = 2.616e-02
% *** Std       = 2.147e-02
% *** CoV       = 8.205e-01
% ** Second Moment
% *** variance  =       NaN
% ** Simulation details
% *** # samples  = 5.000e+01
% *** # batches  =         1
% *** # lines    =        10
% *** Exit Flag = Maximum no. of samples reached. Samples computed 50; Maximum allowed samples: 50
% ===================================================================
% LineSamplingOutput Object  - Description: 
% ===================================================================
% * Number of Variables: 5
% ** RV1; RV2; Xthreshold; out; Vg;
% * Batch: 1 - Number of realizations: 50
%% Adaptive Line Sampling
specs = struct(...
    'SimType','ALS',...
    'N',15,...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP53');
beta
XpF
Xoutput
% beta =
% 
%     1.7089
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with AdaptiveLineSampling method
% ** First Moment
% *** Pfhat     = 4.373e-02
% *** Std       = 2.627e-02
% *** CoV       = 6.007e-01
% ** Second Moment
% *** variance  =       NaN
% ** Simulation details
% *** # samples  = 1.050e+02
% *** # batches  =         1
% *** # lines    =        15
% *** Exit Flag = Maximum no. of lines reached. Lines computed 15; Max Lines : 15
% ===================================================================
% SimulationData Object  - Description:  - apply(@evaluator) - apply(@Model) - apply(@ProbabilisticModel)
% ===================================================================
% * Number of Variables: 5
% ** RV1; RV2; Xthreshold; out; Vg;
% * Batch: 1 - Number of realizations: 105
% * Values stored in a matrix and structure format
% * Exit Flag: Maximum no. of lines reached. Lines computed 15; Max Lines : 15
% * Batches stored in the folder: /Users/marco/Documents/MATLAB//20200221T170537















%% RP54 - Target: 9.98 1e4, beta = 3.09
%% 20 Variables
%%
yes= true;
no = false;
%% Monte Carlo
specs = struct(...
    'SimType','MC',...
    'N',500000,...
    'plot1', no);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP54');

beta
XpF
Xoutput
% beta =
% 
%     3.0820
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with MonteCarlo method
% ** First Moment
% *** Pfhat     = 1.028e-03
% *** Std       = 4.532e-05
% *** CoV       = 4.409e-02
% ** Second Moment
% *** variance  = 1.027e-03
% ** Simulation details
% *** # samples  = 5.000e+05
% *** # batches  =         1
% *** # lines    =         0
% *** Exit Flag = Maximum no. of samples reached. Samples computed 500000; Maximum allowed samples: 500000
% ===================================================================
% SimulationData Object  - Description:  - apply(@evaluator) - apply(@Model) - apply(@ProbabilisticModel)
% ===================================================================
% * Number of Variables: 23
% ** RV1; RV2; RV3; RV4; RV5; RV6; RV7; RV8; RV9; RV10; RV11; RV12; RV13; RV14; RV15; RV16; RV17; RV18; RV19; RV20; Xthreshold; out; Vg;
% * Batch: 1 - Number of realizations: 500000
%% Monte Carlo
specs = struct(...
    'SimType','MC',...
    'N',10000,...
    'plot1', no);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP54');
beta 
XpF
% beta = 3.068;
% XpF
% ===================================================================
% FailureProbability Object  -  Description:
% ===================================================================
% * Results obtained with MonteCarlo method
% ** First Moment
% *** Pfhat     = 1.100e-03
% *** Std       = 3.315e-04
% *** CoV       = 3.014e-01
% ** Second Moment
% *** variance  = 1.099e-03
% ** Simulation details
% *** # samples  = 1.000e+04
% *** # batches  =         1
% *** # lines    =         0
% *** Exit Flag = Maximum no. of samples reached. Samples computed 10000; Maximum allowed samples: 10000
%% Line Sampling
specs = struct(...
    'SimType','LS',...
    'N',15,...
    'Vset',[0.5,1,2,3,5],...
    'grad','IND',...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP54');
beta
XpF
Xoutput
% beta =
% 
%     3.2327
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with LineSampling method
% ** First Moment
% *** Pfhat     = 6.131e-04
% *** Std       = 2.311e-04
% *** CoV       = 3.769e-01
% ** Second Moment
% *** variance  =       NaN
% ** Simulation details
% *** # samples  = 7.500e+01
% *** # batches  =         1
% *** # lines    =        15
% *** Exit Flag = Maximum no. of samples reached. Samples computed 75; Maximum allowed samples: 75
% ===================================================================
% LineSamplingOutput Object  - Description: 
% ===================================================================
% * Number of Variables: 23
% ** RV1; RV2; RV3; RV4; RV5; RV6; RV7; RV8; RV9; RV10; RV11; RV12; RV13; RV14; RV15; RV16; RV17; RV18; RV19; RV20; Xthreshold; out; Vg;
% * Batch: 1 - Number of realizations: 75
%% Adaptive Line Sampling
specs = struct(...
    'SimType','ALS',...
    'N',15,...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP54');
beta
XpF
Xoutput
% beta =
% 
%     3.0125
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with AdaptiveLineSampling method
% ** First Moment
% *** Pfhat     = 1.296e-03
% *** Std       = 7.290e-04
% *** CoV       = 5.627e-01
% ** Second Moment
% *** variance  =       NaN
% ** Simulation details
% *** # samples  = 7.900e+01
% *** # batches  =         1
% *** # lines    =        15
% *** Exit Flag = Maximum no. of lines reached. Lines computed 15; Max Lines : 15
% ===================================================================
% SimulationData Object  - Description:  - apply(@evaluator) - apply(@Model) - apply(@ProbabilisticModel)
% ===================================================================
% * Number of Variables: 23
% ** RV1; RV2; RV3; RV4; RV5; RV6; RV7; RV8; RV9; RV10; RV11; RV12; RV13; RV14; RV15; RV16; RV17; RV18; RV19; RV20; Xthreshold; out; Vg;
% * Batch: 1 - Number of realizations: 79

%%










%%
%% RP75 - Target: 1.07 1e2, beta = 2.33
%% Monte Carlo
specs = struct(...
    'SimType','MC',...
    'N',500000,...
    'plot1', no);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP75');
beta
XpF
% Maximum no. of samples reached. Samples computed 500000; Maximum allowed samples: 500000
% ===================================================================
% FailureProbability Object  -  Description:
% ===================================================================
% * Results obtained with MonteCarlo method
% ** First Moment
% *** Pfhat     = 9.686e-03
% *** Std       = 1.385e-04
% *** CoV       = 1.430e-02
% ** Second Moment
% *** variance  = 9.592e-03
% ** Simulation details
% *** # samples  = 5.000e+05
% *** # batches  =         1
% *** # lines    =         0
% *** Exit Flag = Maximum no. of samples reached. Samples computed 500000; Maximum allowed samples: 500000

% beta = 2.338;

%% Line Sampling
specs = struct(...
    'SimType','LS',...
    'N',20,...
    'Vset',[0.5,1,2,3],...
    'grad','IND',...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP54');
beta
XpF
Xoutput
%% Adaptive Line Sampling
specs = struct(...
    'SimType','ALS',...
    'N',10,...
    'plot1', yes);

[pF,beta,XpF,Xoutput] = computeFailureProbability(specs,'RP54');
beta
XpF
Xoutput
% beta =
% 
%     3.0061
% 
% ===================================================================
% FailureProbability Object  -  Description: 
% ===================================================================
% * Results obtained with AdaptiveLineSampling method
% ** First Moment
% *** Pfhat     = 1.323e-03
% *** Std       = 7.212e-04
% *** CoV       = 5.450e-01
% ** Second Moment
% *** variance  =       NaN
% ** Simulation details
% *** # samples  = 5.700e+01
% *** # batches  =         1
% *** # lines    =        10
% *** Exit Flag = Maximum no. of lines reached. Lines computed 10; Max Lines : 10
% ===================================================================
% SimulationData Object  - Description:  - apply(@evaluator) - apply(@Model) - apply(@ProbabilisticModel)
% ===================================================================
% * Number of Variables: 23
% ** RV1; RV2; RV3; RV4; RV5; RV6; RV7; RV8; RV9; RV10; RV11; RV12; RV13; RV14; RV15; RV16; RV17; RV18; RV19; RV20; Xthreshold; out; Vg;
% * Batch: 1 - Number of realizations: 57
% * Values stored in a matrix and structure format
% * Exit Flag: Maximum no. of lines reached. Lines computed 10; Max Lines : 10
% * Batches stored in the folder: /Users/marco/Documents/MATLAB//20200221T152633
%%
%%
%%
