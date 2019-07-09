function Xout = MC_bl_shell(Radius, Length, Thickness, Nsamples)
%% Definition of the input

% % fake data for debbuging
% Radius=10;
% Length=10;
% Thickness=1;
% Nsamples=10;

% Parameters containing the geometry of the shell
Xpar_Radius = Parameter('Sdescription','Radius of the shell', 'value', Radius);
Xpar_Length = Parameter('Sdescription','Lenght of the shell', 'value', Length);
Xpar_Thickness = Parameter('Sdescription','Thickness of the shell', 'value', Thickness);
% Function computing the classical buckling load from the given parameters
% Xfun_Load = Xfunction('Sdescription','Classical buckling load', 'Sexpression',...
%             '1.044e11/sqrt(3*(1-0.3^2))*2*pi*<&Xpar_Thickness&>^2');

%% replace by Cossan RF generation     

Xrf    = StochasticProcess('Sdistribution','normal','Vmean',0,'Mcovariance',Mcovariance);

%% --
Xinp = Input('Sdescription','Xinput object');        
Xinp = add(Xinp,Xrvs_geo);
Xinp = add(Xinp,Xpar_Radius);
Xinp = add(Xinp,Xpar_Length);
Xinp = add(Xinp,Xpar_Thickness);



%% define connector for injection of RF values
Xc1= Connector();

%% Define injector, extractor and connector for the execution of FE analysis

% Define the connector
Xc2= Connector('SpredefinedType','abaqus','Smaininputfile','cylsh_eig.inp',...
    'Soutputfile','cylsh_eig.msg','Sworkingdirectory','/tmp');
%%
% Define the injectors
Xi1=injector('Stype','scan','Sscanfilename','cylsh_eig.cossan','Sfile','cylsh_eig.inp');
Xc2 = add(Xc2,Xi1);


Xe=extractor('Stype','',...
    'Sdescription','Extractor for cylsh_step1.msg', ...
    'Spath','.', ... % this is the directory where the input and output are contained
    'Sfile','cylsh_eig.msg', ...
    'Nresponse',1, ...
    'Sname', 'Load', ...
    'Sfieldformat', '%11e%*', ...
    'Clookoutfor',{' EIGENVALUES REQUESTED BY THE USER';}, ...
    'Ncolnum',4, ...
    'Nrownum',1 ...
    );

Xc2 = add(Xc2,Xe);

% Define the JobManager
Xjm = JobManagerInterface('Stype','gridengine','Squeue','pizzas64.q');
Xjob = JobManager('Sdescription','test job','Xjobmanagerinterface',Xjm,'Nconcurrent',4);



% create the evaluator
Xeval = evaluator('Xconnector',Xc2,'Xjobmanager',Xjob);

% create Xmodel
Xm = Model('Xinput',Xinp,'evaluator', Xeval);

%% MONTE CARLO
% TODO: use Nconcurrent instead of batches
Nsimxbatch = min(Nsamples,4); % always run 4 ABAQUS in parallel at max
Nbatches=ceil((Nsamples+2)/Nsimxbatch);
Xmc=Xmontecarlo('Nsamples',Nsamples,'Nbatches',Nbatches);
Xout = apply(Xmc,'Xmodel',Xm);
