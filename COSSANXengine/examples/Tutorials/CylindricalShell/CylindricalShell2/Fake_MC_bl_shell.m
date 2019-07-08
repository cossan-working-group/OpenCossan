function Xout = Fake_MC_bl_shell(Radius, Length, Thickness, Nsamples)
%% Definition of the input

% % fake data for debbuging
% Radius=10;
% Length=10;
% Thickness=1;
% Nsamples=10;

% Parameters containing the geometry of the shell
Xpar_Radius = Parameter('Sdescription','Radius of the shell', 'value', Radius);
% Xpar_Length = Parameter('Sdescription','Lenght of the shell', 'value', Length);
Xpar_Length = RandomVariable('Sdescription','Lenght of the shell','Sdistribution','norm' ,'mean', Length,'cov',.1); %fake
Xpar_Lengthset = RandomVariableSet('Cmembers',{'Xpar_Length'},'Xrv', Xpar_Length);
Xpar_Thickness = Parameter('Sdescription','Thickness of the shell', 'value', Thickness);
% Function computing the classical buckling load from the given parameters
% Xfun_Load = Xfunction('Sdescription','Classical buckling load', 'Sexpression',...
%             '1.044e11/sqrt(3*(1-0.3^2))*2*pi*<&Xpar_Thickness&>^2');

%% replace by Cossan RF generation     

% Xrf    = StochasticProcess('Sdistribution','normal','Vmean',0,'Mcovariance',Mcovariance);

%% --
Xinp = Input('Sdescription','Xinput object');        
Xinp = add(Xinp,Xpar_Radius);
Xinp = add(Xinp,Xpar_Lengthset);
% Xinp = add(Xinp,Xpar_Thickness);

%%

Xm  = Mio('Sdescription', 'Performance function', ...
                'Spath','./', ...
                'Sfile','ExampleMioStructure', ...
                'Liostructure',true,...     % This flag specify the type of I/O
                'Liomatrix',false, ...  % This flag specify the type of I/O
                'Coutputnames',{'Out1';'Out2'},... % This field is mandatory
                'Cinputnames',{'Xpar_Radius';'Xpar_Length'},...          % This field is mandatory
				'Lfunction',true); % This flag specify if the .m file is a script or a function. 



% create the evaluator
Xeval = evaluator('Xmio',Xm);

% create Xmodel
Xm = Model('Xinput',Xinp,'Xevaluator', Xeval);

%% MONTE CARLO
% TODO: use Nconcurrent instead of batches
Nsimxbatch = min(Nsamples,4); % always run 4 ABAQUS in parallel at max
Nbatches=ceil((Nsamples+2)/Nsimxbatch);
Xmc=Montecarlo('Nsamples',Nsamples,'Nbatches',Nbatches);
Xout = apply(Xmc,Xm);
