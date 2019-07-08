function Xout = MC_bl_shell(Radius, Length, Thickness, Nsamples)
%% Definition of the input

% set of 6 standard normal RVs used in the K-L expansion of the geometric
% imperfections
Xrv_geo = rv('Sdistribution','normal','mean',0,'variance',1);

Xrvs_geo = rvset('Sdescription',...
    'set w/ the rvs used for KL representation of geo. imp. rf ',...
    'CXrv', {Xrv_geo,Xrv_geo,Xrv_geo,Xrv_geo,Xrv_geo,Xrv_geo},...
    'Cmembers', {'Xrv1_geo','Xrv2_geo','Xrv3_geo','Xrv4_geo','Xrv5_geo','Xrv6_geo'});

% Parameters containing the geometry of the shell
Xpar_Radius = parameters('Sdescription','Radius of the shell', 'value', Radius);
Xpar_Length = parameters('Sdescription','Lenght of the shell', 'value', Length);
Xpar_Thickness = parameters('Sdescription','Thickness of the shell', 'value', Thickness);
% Function computing the classical buckling load from the given parameters
Xfun_Load = Xfunction('Sdescription','Classical buckling load', 'Sexpression',...
            '1.044e11/sqrt(3*(1-0.3^2))*2*pi*<&Xpar_Thickness&>^2');
% load the mean, eigenvalues and eigenvectors of the geometric
% imperfections and store them in a parameter
load b_g_eig
Xpar_mean_imp = parameters('Sdescription','Mean geometric imperfection',...
                'value',mean_imp);
Xpar_eigval = parameters('Sdescription','Eigenvalues of the geometric imperfections',...
              'value',eigval);
Xpar_eigvec = parameters('Sdescription','Eigenvectors of the geometric imperfections',...
              'value',eigvec);
% Function computing the random field
Xfun_gimp = Xfunction('Sdescription','Random field of geometric imperfectons', 'Sexpression',...
    'KL_shell(<&Xpar_mean_imp&>, <&Xpar_eigval&>, <&Xpar_eigvec&>, <&Xrv1_geo&>, <&Xrv2_geo&>, <&Xrv3_geo&>, <&Xrv4_geo&>, <&Xrv5_geo&>, <&Xrv6_geo&>, <&Xpar_Thickness&>)');

Xinp = Xinput('Sdescription','Xinput object');        
Xinp = add(Xinp,Xrvs_geo);
Xinp = add(Xinp,Xpar_Radius);
Xinp = add(Xinp,Xpar_Length);
Xinp = add(Xinp,Xpar_Thickness);
Xinp = add(Xinp,Xfun_Load);
Xinp = add(Xinp,Xpar_mean_imp);
Xinp = add(Xinp,Xpar_eigval);
Xinp = add(Xinp,Xpar_eigvec);
Xinp = add(Xinp,Xfun_gimp);

%% Define injector, extractor and connector

% Define the connector
Xc= connector('Stype','abaqus661','Smaininputfile','cylsh_eig.inp',...
    'Soutputfile','cylsh_eig.msg','Sworkingdirectory','/tmp');

% Define the injectors
Xi1=injector('Stype','scan','Sscanfilename','cylsh_eig.cossan','Sfile','cylsh_eig.inp');
Xc = add(Xc,Xi1);
%
% Xi2=injector('Stype','scan','Sscanfilename','load_step1.cossan','Sfile','load_step1.txt');
% Xc = add(Xc,Xi2);

Xi3=injector('Stype','empty','Nvariable',1,'Sfile','imperfection.dat');
% Manual definition of injection position for geometric imperfections
Tvar=repmat(struct('Sname', 'Xfun_gimp', 'Nindex', [], 'Sfieldformat', '%12.5e',...
    'Nrownum',[],'Ncolnum',[],'Slookoutfor','','Sregexpression','',...
    'Svarname','','Nposition',[]), 1, 19493);
Tvar(1).Nposition=14;
Tvar(1).Nindex=1;
for i=2:19493
    Tvar(i).Nindex=i;
    Tvar(i).Nposition=14+(i-1)*27;
end
Xi3 = set(Xi3,'Tvar',Tvar);
Xc = add(Xc,Xi3);

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

Xc = add(Xc,Xe);

% Define the Grid object
Xg=Xgrid('Stype','GridEngine','Squeue','pizzas64.q');

% create the evaluator
Xeval = evaluator('Xconnector',Xc,'Xgrid',Xg);

% create Xmodel
Xm = Xmodel('Xinput',Xinp,'evaluator', Xeval);

%% MONTE CARLO
Nsimxbatch = min(Nsamples,4); % always run 4 ABAQUS in parallel at max
Nbatches=ceil((Nsamples+2)/Nsimxbatch);
Xmc=Xmontecarlo('Nsamples',Nsamples,'Nbatches',Nbatches);
Xout = apply(Xmc,'Xmodel',Xm);
