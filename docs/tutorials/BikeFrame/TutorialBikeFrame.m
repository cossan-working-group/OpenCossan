%% Tutorial TutorialBikeFrame
%
% In this tutorial, reliability analysis of a bicycle frame is performed.
% The Young modulus and the thickness of the frame are modeled with RandomVariables
%
% Reliability is performed using Monte Carlo simulation

disp(['This tutorial has been created on ',date])

% 
global OPENCOSSAN
OpenCossan.setVerbosityLevel(4)
% disable the database in order to avoid writting hundreds of megabytes of
% files
OPENCOSSAN.XdatabaseDriver =[];

% Retrieve the directory where this tutorial is stored
StutorialPath = fileparts(which('TutorialBikeFrame.m'));
% Copy the tutorial files in a working directory. The FE input files can be
% written or created in this directory.
copyfile([StutorialPath '/*'],...
    fullfile(OpenCossan.getCossanWorkingPath,'TutorialWorkingDir'),'f');

%set random stream
OpenCossan.resetRandomNumberGenerator(31415)
%   Definition of basic input

% Creation of the randomvariablesc
% The Young modulus
E = RandomVariable('Sdistribution','lognormal','mean',7e4,'cov',0.1);
% the thickness of the frame
thickness1 = RandomVariable('Sdistribution','lognormal','mean',2,'cov',0.1);
thickness2 = RandomVariable('Sdistribution','lognormal','mean',1,'cov',0.1);

% Creation of the randomvariableset with the randomvariables
Xrvs = RandomVariableSet('Cmembers',{'E','thickness1','thickness2'});

% Creation of an empty input
Xin = Input;
% adding the set
Xin = Xin.add(Xrvs);
% maximum displacement allowed (defines the demand of the performance function)
Xth  =Parameter('value',.18);
Xin = Xin.add(Xth);
%%   Injector
Sdirectory = fullfile(OpenCossan.getCossanWorkingPath,'TutorialWorkingDir');
Xi  = Injector(...
    'SscanFilePath',Sdirectory,...
    'Sscanfilename','frame.cossan',...
    'Sfile','frame.inp'...
    );

%% Create Response & Extractor
% Response related with displacement 
Xresp1 = Response('Sname', 'displacement', ...
             'Sfieldformat', '%17e%', ...
             'Clookoutfor',{'  THE FOLLOWING DEGREE OF FREEDOM RESULTS ARE'}, ...
             'Ncolnum',11, ...
             'Nrownum',8 ...
             );
% Extractor
Xe1=Extractor( ...
             'Srelativepath','./', ...
             'Sfile','AnsysResult.txt',...
             'Xresponse',Xresp1 );       

%% Construct the connector
% A connector using a predefined set of options for Ansys is created. The
% working directory, that is the directory where the FE solver is executed,
% is set to /tmp. This is done because it is much faster to execute the FE
% solver on a local folder than on a network shared folder.
Xc = Connector('SpredefinedType','ansys',...
               'Sworkingdirectory','/tmp/',...
               'Smaininputpath',Sdirectory,...
               'Smaininputfile','frame.inp');
           
Xc.Sexeflags = '-p aa_t_i -o AnsysResult.txt';

%% Add Injector & Extractor
Xc = Xc.add(Xi);
Xc = Xc.add(Xe1);

%% Create Evaluator & Model

Xe = Evaluator('CXmembers',{Xc});
Xmdl=Model('Xinput',Xin,'Xevaluator',Xe);

%% Define a Monte Carlo object
% The montecarlo object defines the number of simulations to be used and the number
% of batches

Xmc=MonteCarlo('Nsamples',1000,'Nbatches',1);

%% Construct the Probabilistic Model
% Define performance function 
Xpf=PerformanceFunction('OutputName','Vg','Capacity','displacement','Demand','Xth');
% Construct the model
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xpf);


%% Run simulation 
% The method pf allows to perform the Monte Carlo simulation
OpenCossan.setVerbosityLevel(0)
[Xpf Xo]  = Xmc.computeFailureProbability(Xpm);
OpenCossan.setVerbosityLevel(2)


%% show results
% 
% failure probability
display(Xpf)

%histogramm of the displacement
hist(Xo.getValues('Sname','displacement'))

disp(['This tutorial has been created on ',date])
