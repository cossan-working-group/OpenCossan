%% Problem Definition

Sfilename=mfilename;

% Define random variables
RV1=RandomVariable('Sdistribution','normal','mean',10,'std',3.0);
RV2=RandomVariable('Sdistribution','normal','mean',10,'std',3.0);

% Define the RVset
Xrvs = RandomVariableSet(...
    'Cmembers',{'RV1','RV2'},...
    'CXrv',{RV1 RV2}); %% Define the evaluator

% Define Input object
Xin = Input('Sdescription','Blackbox reliability challenge',...
    'CSmembers',{'Xrvs'},'CXmembers',{Xrvs});

% Define a Model
Xmdl=Model('Xevaluator',Evaluator,'Xinput',Xin);

Xmio=Mio('Sdescription', 'Performance function', ...
                'Spath',pwd,'Sfile',strcat('g',Sfilename),...
                'Coutputnames',{'out'},...
                'Cinputnames',{'RV1','RV2'},...
				'Liomatrix',true,'Lfunction',true); % This flag specify if the .m file is a script or a function. 

Xperfun=PerformanceFunction('Xmio',Xmio); % This flag specify if the .m file is a script or a function. 
            
% Construct the reliability model
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xperfun);
