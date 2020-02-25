%% Problem Definition for the Reliability Problem 8

% Reference solution 7.84?10?4

% Get file name of this script
Sfilename=mfilename;

% Define random variables
RV1=RandomVariable('Sdistribution','lognormal', 'mean',120,'std',12);
RV2=RandomVariable('Sdistribution','lognormal', 'mean',120,'std',12);
RV3=RandomVariable('Sdistribution','lognormal', 'mean',120,'std',12);
RV4=RandomVariable('Sdistribution','lognormal', 'mean',120,'std',12);
RV5=RandomVariable('Sdistribution','lognormal', 'mean',50,'std',10);
RV6=RandomVariable('Sdistribution','lognormal', 'mean',40,'std',8);

% Define the RVset
Xrvs = RandomVariableSet(...
    'Cmembers',{'RV1','RV2','RV3','RV4','RV5','RV6'},...
    'CXrv',{RV1 RV2 RV3 RV4 RV5 RV6}); %% Define the evaluator

% Define Input object
Xin = Input('Sdescription','Blackbox reliability challenge',...
    'CSmembers',{'Xrvs'},'CXmembers',{Xrvs});

% Define a Model
Xmdl=Model('Xevaluator',Evaluator,'Xinput',Xin);

Xmio=Mio('Sdescription', 'Performance function', ...
                'Spath',pwd,'Sfile',strcat('g',Sfilename),...
                'Coutputnames',{'out'},...
                'Cinputnames',{'RV1','RV2','RV3','RV4','RV5' 'RV6'},...
				'Liomatrix',true,'Lfunction',true); % This flag specify if the .m file is a script or a function. 

% Construct a Mio object
Xperfun=PerformanceFunction('Xmio',Xmio); % This flag specify if the .m file is a script or a function. 
            
% Construct the reliability model
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xperfun);
% Define a Monte Carlo object
% The montecarlo object defines the number of simulations to be used, the number of batches


