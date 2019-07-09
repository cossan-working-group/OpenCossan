%% Tutorial Beam 3-point bending (NASTRAN)
% The displacements are blocked in all the direction at one of the extremity of the beam 
% (however, rotation is possible). The other extremity can move freely in 
% the horizontal direction.
% 
% The beam is assumed to have a rectangular cross section. The length L of 
% the beam is 100mm, a force is applied at 25mm from an extremity.
% The quantity of interest is the displacement (in the  vertical direction)
% at the middle of the beam.
%
% The model is analysed using a Nastran
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/Beam_3-point_bending_(overview)
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Pierre~Beaurepaire$ 
clear, clc
% Retrieve the directory where this tutorial is stored
% StutorialPath = fileparts(which(mfilename));
% assert(~isempty(StutorialPath),'openCOSSAN:Tutorial','The tutorial folder must be contained in the path.')
% Copy the tutorial files in a working directory. The FE input files can be
% written or created in this directory. The directory is on a network
% share, reachable by every cluster machine, and the user has write
% permission on it.
% copyfile([StutorialPath '/*'],...
%     fullfile(OpenCossan.getCossanWorkingPath,'TutorialWorkingDir'),'f');

if isunix
    SworkingPath = fullfile(strrep(userpath,':',''),'workfolder');
elseif ispc
    SworkingPath = fullfile(strrep(userpath,';',''),'workfolder');
end
OpenCossan('SworkingPath',SworkingPath,...
    'SmatlabPath','/usr/software/MATLAB/R2013a/',...
    'SmcrPath','/usr/software/matlab/MATLAB_Compiler_Runtime/v81')
%% Create the input
% accelerogram inputs
wg = Parameter('value',12.5); % Kanai Tajimi  filter circular frequency 
csig    = Parameter('value',0.6); %Kanai Tajimi filter damping factor   
wf = Parameter('value',2); % Clough Penzien filter circular frequency 
csif = Parameter('value',0.7); % Clough Penzien filter damping factor
S0 = Parameter('value',0.013); % Seismic intensity parameter
dt = Parameter('value',0.01); %deltaT
t_tot = Parameter('value',30); %total duration 
Nrviid = floor(t_tot.value/dt.value + 1);
Xrv = RandomVariable('Sdistribution','normal','mean',0,'std',1);
Xrvset_acc = RandomVariableSet('Xrv',Xrv,'Nrviid',Nrviid);

% structure inputs
IDR_threshold=Parameter('value',0.007,'Sdescription','Maximum allowed interstorey drift ratio');
p_damper1 = Parameter('value',3); 
p_damper2 = Parameter('value',3); 
p_damper3 = Parameter('value',3); 
c_damper1 = Function('Sexpression','<&p_damper1&>*10000'); 
c_damper2 = Function('Sexpression','<&p_damper2&>*10000'); 
c_damper3 = Function('Sexpression','<&p_damper3&>*10000'); 
alpha_damper = Parameter('value',0.7);

% mass    = RandomVariable('Sdistribution','lognormal','mean',454.5455,'cov',0.1); 
% stiffness   = RandomVariable('Sdistribution','lognormal','mean',(2*pi/1)^2*mass.mean,'cov',0.1);    
% Mcorrelation=eye(2);
% Xrvset_struct = RandomVariableSet('Cmembers',{'mass','stiffness'},'Mcorrelation',Mcorrelation);
% circ_freq  = Function('Sexpression','sqrt(<&stiffness&>./<&mass&>)');

% Xinput=Input('CXmembers',{c_damper alpha_damper Xrvset_struct circ_freq disp_threshold ...
%     Xrvset_acc wg csig wf csif S0 dt t_tot},...
%     'CSmembers',{'c_damper' 'alpha_damper' 'Xrvset_struct' 'circ_freq' 'disp_threshold' ...
%     'Xrvset_acc' 'wg' 'csig' 'wf' 'csif' 'S0' 'dt' 't_tot'});

Xinput=Input('CXmembers',{p_damper1 p_damper2 p_damper3 c_damper1 c_damper2 c_damper3 alpha_damper IDR_threshold ...
    Xrvset_acc wg csig wf csif S0 dt t_tot},...
    'CSmembers',{'p_damper1' 'p_damper2' 'p_damper3' 'c_damper1' 'c_damper2' 'c_damper3' 'alpha_damper' 'IDR_threshold' ...
    'Xrvset_acc' 'wg' 'csig' 'wf' 'csif' 'S0' 'dt' 't_tot'});
	

% See summary of the Input
display(Xinput)

%% Create the mio for the accelerogram creation
for irv=1:Nrviid
    Crvnames{irv} = ['Xrv_' num2str(irv)]; %#ok<SAGROW>
end

Xmio_acc_gen = Mio('Sfile', 'miofun_cp_gen','Spath',pwd,...
    'CinputNames',[Crvnames {'wg' 'csig' 'wf' 'csif' 'S0' 'dt' 't_tot'}],...
    'CoutputNames',{'ground_acc'},...
    'Lfunction',true,...
    'Liostructure',true,...
    'Liomatrix',false);
%% Create the Injector
% The Injector is created by scanning the .cossan file containing the
% identifiers. A file without identifiers, Nastran.dat, is created in the
% tutorial working directory.
Sdirectory = fullfile(pwd);%OpenCossan.getCossanWorkingPath,'TutorialWorkingDir'
Xinjector1  = Injector('Stype','scan','SscanFilePath',Sdirectory,...
                     'Sscanfilename','MDOF_damp.cossan.tcl','Sfile','MDOF_damp.tcl');
Xinjector2  = TableInjector('Stype','matlab16','Sfile','acc.thf','Cinputnames',{'ground_acc'});
%% Extractor
% The extractor object is created with one Response. The string specified 
% in Clookoutfor is searched in the ASCII output file xxxx, then 23
% lines are skipped and the number starting at column 42 is extracted and
% assigned to the output named "disp".

% Xextractor = Extractor('Srelativepath','./','Sfile','BeamOpenSees.tcl');

Xextractor1 = TableExtractor('Srelativepath','./','Sfile','th_Node_DefoShape_Dsp.out',...
    'LextractColumns',true,...
    'LextractCoord',true,...
    'SoutputName','disp_history1',...
    'CcolumnPosition',{2},...
    'Sdelimiter',' ');
Xextractor2 = TableExtractor('Srelativepath','./','Sfile','th_Node_DefoShape_Dsp.out',...
    'LextractColumns',true,...
    'LextractCoord',true,...
    'SoutputName','disp_history2',...
    'CcolumnPosition',{3},...
    'Sdelimiter',' ');
Xextractor3 = TableExtractor('Srelativepath','./','Sfile','th_Node_DefoShape_Dsp.out',...
    'LextractColumns',true,...
    'LextractCoord',true,...
    'SoutputName','disp_history3',...
    'CcolumnPosition',{4},...
    'Sdelimiter',' ');

Xextractor4 = TableExtractor('Srelativepath','./','Sfile','Truss_Forc.out',...
    'LextractColumns',true,...
    'LextractCoord',true,...
    'SoutputName','damper_force_history1',...
    'CcolumnPosition',{2},...
    'Sdelimiter',' ');
Xextractor5 = TableExtractor('Srelativepath','./','Sfile','Truss_Forc.out',...
    'LextractColumns',true,...
    'LextractCoord',true,...
    'SoutputName','damper_force_history2',...
    'CcolumnPosition',{3},...
    'Sdelimiter',' ');
Xextractor6 = TableExtractor('Srelativepath','./','Sfile','Truss_Forc.out',...
    'LextractColumns',true,...
    'LextractCoord',true,...
    'SoutputName','damper_force_history3',...
    'CcolumnPosition',{4},...
    'Sdelimiter',' ');

%% Construct the connector
% A connector using a predefined set of options for Nastran is created. The
% working directory, that is the directory where the FE solver is executed,
% is set to /tmp. This is done because it is much faster to execute the FE
% solver on a local folder than on a network shared folder.
Xconnector = Connector('Ssolverbinary','/usr/software/OpenSees/OpenSees-2.4.2',...
    'Sexecmd','%Ssolverbinary %Smaininputfile',...
        ...%                'Sworkingdirectory','pwd',...
               'Smaininputpath',Sdirectory,...
               'Smaininputfile','MDOF_damp.tcl',...
               ...%'Soutputfile','StaticDefaultCase_Node_DefoShape_Dsp.out',...
               'CXmembers', {Xinjector1 Xinjector2 Xextractor1 Xextractor2 Xextractor3 Xextractor4 Xextractor5 Xextractor6},...
               'LkeepSimulationfiles',false);

%% Construct the postprocessing mio
% this mio retrieve the maximum IDR and the maximum damper force
Xmio_post = Mio('Sfile', 'miofun_post','Spath',pwd,...
    'Cinputnames',{'disp_history1','disp_history2','disp_history3','damper_force_history1','damper_force_history2','damper_force_history3'},...
    'Coutputnames',{'max_IDR' 'sum_damper_forces'},'Liomatrix',false,'Lfunction',true,'Liostructure',true); 
%% Preparation of the Evaluator
Xjmi = JobManagerInterface('Stype','GridEngine');
Xevaluator = Evaluator('XjobManagerInterface',Xjmi,...
    'CXmembers',{Xmio_acc_gen Xconnector Xmio_post},...
    'CSmembers',  {'Xmio_acc_gen' 'Xconnector' 'Xmio_post'},...
    'CSqueues',   {''             'standard'   ''},...
    'Vconcurrent',[1              100           1],...
    'LremoteInjectExtract',true);

%% Preparation of the Model

Xmodel = Model('Xinput',Xinput,'Xevaluator',Xevaluator);

% See summary of the Model
display(Xmodel)


%% test the model
% Xinput = Xinput.sample('Nsamples',1);
% Xout = Xmodel.apply(Xinput);
% IDR=mean(Xout.getValues('Cnames',{'max_IDR'}))
% FORCES=mean(Xout.getValues('Cnames',{'sum_damper_forces'}))

% a = Xout.getDataseries('Cnames',{'ground_acc','disp_history1'});
% ground_acc = a{1}; disp_history = a{2};
% % plot the ground acceleration
% plot(ground_acc)
% % plot the displacement
% plot(disp_history)
% % put all the max diplacements in a matrix
% Mdisp = vertcat(disp_history.Vdata);
% Max_disp=max(abs(Mdisp),[],2);


% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED



%% Construct User Defined Performance Function
% A Mio object is used to define a PerformanceFunction
Xm=Mio('Sscript','for n=1:length(Tinput), Toutput(n).Vg=Tinput(n).IDR_threshold-Tinput(n).max_IDR; end', ...
      'Cinputnames',{'max_IDR','IDR_threshold'},...
      'Coutputnames',{'Vg'},'Liomatrix',false,'Lfunction',false,'Liostructure',true);
  
% Construct PerformanceFunction  
Xperfun=PerformanceFunction('Sdescription','User defined PerformanceFunction', ...
                        'Xmio',Xm);
                    
% Define a Probabilistic Model
XprobModelSDOFMatlab=ProbabilisticModel('Xmodel',Xmodel,'XperformanceFunction',Xperfun);

%% Reliability Analysis via Latin Hypercube Sampling
% % Definition of the Simulation object
% Xlhs=LatinHypercubeSampling('Nsamples',1);
% % Run Reliability Analysis
% % XfailireProbLHS=Xlhs.computeFailureProbability(XprobModelSDOFMatlab);
% 
% [Xpf Xo]=Xlhs.computeFailureProbability(XprobModelSDOFMatlab)
% display(Xpf)
% display(Xo)
% a = Xo.getDataseries('Cnames',{'ground_acc','disp_history'})

%% Define Outer loop Optimization problem 
% The outer loop optimization problem takes the output of the inner loop as
% inputs of an optimization. The sections of the beams are introduced here
% as design variables.

% Define Design Variables. 
Xdvc_damper = DesignVariable('value',3,'lowerbound',1e-6,'upperbound',4);
Xdvalpha_damper = DesignVariable('value',0.7,'lowerbound',0.3,'upperbound',1);

Xinput_opt = Input('CXmembers',{Xdvc_damper,Xdvalpha_damper,IDR_threshold},...
    'CSmembers',{'Xdvc_damper','Xdvalpha_damper','IDR_threshold'});
%% Definition of the constrain
Xcon = Constraint('Sscript',['for n=1:length(Tinput);' ...
'Toutput(n).muConstraint=+mean(Tinput(n).max_IDR)./Tinput(n).IDR_threshold-1;end'],...
    'Cinputnames',{'IDR_threshold' 'max_IDR'},...
    'Soutputname','muConstraint',...
    'Linequality',true,...
    'Liostructure',true);

  
%% Definition of the objective function
% The objective function is the total volume of the truss structure. The
% inner loop model returns the beam volumes for each execution of the
% matlab function. Since the volume does not depend on random parameters,
% only the volume of the first sample is kept.
XobjFun = ObjectiveFunction('Sscript',['for n=1:length(Tinput);' ...
    'Toutput(n).mu_sumdampforces = mean(Tinput(n).sum_damper_forces);end'],...
    'Cinputnames',{'sum_damper_forces'},...
    'Soutputname','mu_sumdampforces',...
    'Liostructure',true);

%% Define the RobustDesign 
% The RobustDesign problem is defined by combining a model, an Objective
% function and Constraint, an Input containing the Design Variables and 
% finally a mapping between the DesignVariable and the input of the Model.
XrobustDesign = RobustDesign('Sdescription','Damper properties robust design optimization', ...
        'XinnerLoopModel',Xmodel, ...
        'Xinput',Xinput_opt, ...
        'XobjectiveFunction',XobjFun,...
        'Xconstraint',Xcon,...
        'Xsimulator',LatinHypercubeSampling('Nsamples',1),...
        'CSinnerLoopOutputNames',{'max_IDR','sum_damper_forces'},...
        'CdesignvariableMapping',{'Xdvc_damper' 'p_damper1' 'parametervalue';...
        'Xdvc_damper' 'p_damper2' 'parametervalue';...
        'Xdvc_damper' 'p_damper3' 'parametervalue';...
        'Xdvalpha_damper' 'alpha_damper' 'parametervalue';}...
        );
    
%% Create optimizer
% The optimization algorithm of choice is Sequential Quadratic Programming.
% Since no optional parameter is passed to the constructor, the default
% parameters values of the algorithm are used.
%Xoptimizer   = SequentialQuadraticProgramming('toleranceObjectiveFunction',1e-3,...
%     'toleranceConstraint',1e-6,'toleranceDesignVariables',1e-4);
%Xoptimizer   = Cobyla;

% Nga=10;
% Mpop=[Xdvc_damper.lowerBound+(Xdvc_damper.upperBound-Xdvc_damper.lowerBound)*rand(10,1),...
%     Xdvalpha_damper.lowerBound+(Xdvalpha_damper.upperBound-Xdvalpha_damper.lowerBound)*rand(10,1)];
%  Xoptimizer   = GeneticAlgorithms('NPopulationSize',Nga,...
%      'NEliteCount',4,...
%      'MinitialPopulation',Mpop,...
%      'crossoverfraction',0.8,...
%      'mutationrate',0.01);

Xoptimizer   = SequentialQuadraticProgramming('toleranceObjectiveFunction',1e-3,...
    'toleranceConstraint',1e-6,'finiteDifferencePerturbation',0.001);
% Xoptimizer   = Cobyla('toleranceObjectiveFunction',1e-3,...
%     'toleranceConstraint',1e-6,'rho_ini',1,'rho_end',1e-3);

% Xoptimizer   = GeneticAlgorithms;
%% Perform the analysis
% The optimization analysis is performed. The initial solution is set to
% the default values of the parameters defined for the inner loop model.
Xoptimum = XrobustDesign.optimize('Xoptimizer',Xoptimizer,...
    'VinitialSolution',[5,1]);
% Xoptimum = XrobustDesign.optimize('Xoptimizer',Xoptimizer,...
%     'MinitialSolutions',Mpop);
OpenCossan.setVerbosityLevel(3) % increase verbosity to show more info with display
display(Xoptimum)
% plot the objective function evolution
f1=Xoptimum.plotObjectiveFunction;
% plot the constraint evolution
f2=Xoptimum.plotConstraint;
% plot the design variable evolution
f3=Xoptimum.plotDesignVariable;

%% Close figures and validate solution
close(f1); close(f2); close(f3);
