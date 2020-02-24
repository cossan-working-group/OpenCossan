%% Problem Definition for the Reliability Problem 14

% Get file name of this script
Sfilename=mfilename;

% Define random variables
RV1=RandomVariable('Sdistribution','uniform', 'lowerbound',70,'upperbound',80);
RV2=RandomVariable('Sdistribution','normal',  'mean',39,    'std',0.1);
RV3=RandomVariable('Sdistribution','gumbel',  'parameter1',1342,  'parameter2',1/272.9);
RV4=RandomVariable('Sdistribution','normal',  'mean',400,   'std',0.1);
RV5=RandomVariable('Sdistribution','normal',  'mean',250000,'std',35000);

% Define the RVset
Xrvs = RandomVariableSet(...
    'Cmembers',{'RV1','RV2','RV3','RV4','RV5'},...
    'CXrv',{RV1 RV2 RV3 RV4 RV5}); %% Define the evaluator

% Define Input object
Xin = Input('Sdescription','Blackbox reliability challenge',...
    'CSmembers',{'Xrvs'},'CXmembers',{Xrvs});

% Define a Model
Xmdl=Model('Xevaluator',Evaluator,'Xinput',Xin);

Xmio=Mio('Sdescription', 'Performance function', ...
                'Spath',pwd,'Sfile',strcat('g',Sfilename),...
                'Coutputnames',{'out'},...
                'Cinputnames',{'RV1','RV2','RV3','RV4','RV5'},...
				'Liomatrix',true,'Lfunction',true); % This flag specify if the .m file is a script or a function. 

% Construct a Mio object
Xperfun=PerformanceFunction('Xmio',Xmio); % This flag specify if the .m file is a script or a function. 
            
% Construct the reliability model
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xperfun);
% Define a Monte Carlo object
% The montecarlo object defines the number of simulations to be used, the number of batches

%assert(exists(Xsimilator),'No Simulator defined file: %s',mfilename('Fullpath'))


