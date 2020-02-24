%% Problem Definition
% Define random variables
RV1=RandomVariable('Sdistribution','normal', 'mean',10,    'std',3.0);
RV2=RandomVariable('Sdistribution','normal',  'mean',10,    'std',3.0);

% Define the RVset
Xrvs = RandomVariableSet(...
    'Cmembers',{'RV1','RV2'},...
    'CXrv',{RV1 RV2}); %% Define the evaluator
% Construct a Mio object
Xm=Mio(         'Sdescription', 'Performance function', ...
                ...'Sscript','for j=1:length(Tinput), Toutput(j).out1=sqrt(Tinput(j).RV1^2+Tinput(j).RV2^2); end', ...
                'Spath',pwd,...
                'Sfile',[specs.Problem,'_mio'],...
                'Liostructure',true,...
                'Coutputnames',{'out'},...
                'Cinputnames',{'RV1','RV2'},...
				'Lfunction',false); % This flag specify if the .m file is a script or a function.

% Construct the Evaluator
Xeval = Evaluator('Xmio',Xm,'Sdescription','Evaluator xmio');
% Define Input object
Xin = Input('Sdescription','Blackbox reliability challenge');
Xthreshold = Parameter('value',0);
Xin = Xin.add('Xmember',Xrvs,'Sname','Xrvs');
Xin = Xin.add('Xmember',Xthreshold,'Sname','Xthreshold');
% Define a Model
Xmdl=Model('Xevaluator',Xeval,'Xinput',Xin);
% Define performance function
Xpf=PerformanceFunction('Scapacity','out','Sdemand','Xthreshold','Soutputname','Vg');
% Construct the model
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xpf);
% Define a Monte Carlo object
% The montecarlo object defines the number of simulations to be used, the number of batches

Xsimulator = constructSimulator(specs,Xpm);
%%
[XpF, Xoutput] = Xpm.computeFailureProbability(Xsimulator);

makePlots
