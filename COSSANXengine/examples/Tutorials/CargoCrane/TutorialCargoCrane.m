%% Cargo Crane Tutorial
% 
% This example shows how to extract the time dependent response in a
% transient analysis using the FE software Abaqus. The model used is a
% cargo crane which is loaded by a dropped tip load. The response of tip of
% the structure is extracted and visualized. In this example, all the
% structural parameters and also the load characteristics are deteministic.

% See Also: https://cossan.co.uk/wiki/index.php/Cargo_Crain
%
% This tutorial used an FE-input file of a cargo crane which has been 
% taken from the documentation of Abaqus 6.9

% $Original Author: Barbara Goller$ 
% $Author: Matteo Broggi$ 

Spath = fileparts(which('TutorialCargoCrane'));
%% define Input
Emod  = RandomVariable('Sdistribution','normal','mean',200.E9,'std',200E8);
density  = RandomVariable('Sdistribution','normal','mean',7800.,'std',780.);
Cmems   = {'Emod'; 'density'};
Xrvs1     = RandomVariableSet('Cmembers',Cmems);
Xin     = Input;
Xin     = add(Xin,Xrvs1);

% Definition of stochastic process
Xcovfun  = CovarianceFunction('Sdescription','covariance function', ...
    'Lfunction',false,'Liostructure',true,'Liomatrix',false,...
    'Cinputnames',{'t1','t2'},... % Define the inputs
    'Sscript', 'sigma = 1; b = 0.5; for i=1:length(Tinput), Toutput(i).fcov  = sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1)); end', ...
    'Coutputnames',{'fcov'}); % Define the outputs
time   = 0:0.001:0.5;
SP1    = StochasticProcess('Sdistribution','normal','Vmean',1.0,'Xcovariancefunction',Xcovfun,'Mcoord',time,'Lhomogeneous',true);
SP1    = KL_terms(SP1,'NKL_terms',30,'Lcovarianceassemble',false);
Xin    = add(Xin,SP1);

SP2    = StochasticProcess('Sdistribution','normal','Vmean',5.0,'Xcovariancefunction',Xcovfun,'Mcoord',time,'Lhomogeneous',true);
SP2    = KL_terms(SP2,'NKL_terms',20,'Lcovarianceassemble',false);
Xin    = add(Xin,SP2);



%% Define connector
Sdirectory = fileparts(which('TutorialCargoCrane'));
Xconn1 = Connector('SpredefinedType','Abaqus',...
    'Smaininputpath',Sdirectory,...
    'Smaininputfile','crane.inp',...
    'Caddfiles',{'Readresults.py'},... 
    'Sworkingdirectory',Sdirectory, ...
    'SpostExecutionCommand','/usr/software/Abaqus/Commands/abq6111 cae noGUI=Readresults.py',...
    'LkeepSimulationFiles',false);

%% Define Injector
Xinjector = Injector('Sscanfilepath',Spath,...
    'Sscanfilename','crane.cossan','Sfile','crane.inp');
%% Define a TableInjector
XtableInjector=TableInjector('Sfile','LOADSP.txt','Stype','abaqus_table',...
    'CinputNames',{'SP1'});


%% Define table extractor
Xte1 = TableExtractor('Sdescription','Spatial displacement: U1 at Node 104 in NSET TIP', ...
             'Srelativepath','./', ... % path where results file is located
             'Sfile','results.txt', ... % name of the result file
             'Nheaderlines', 4, ... % number of header lines
             'CcolumnPosition',{2},... I have no clue...
             'Sdelimiter', ' ',... % delimiter between columns
             'Soutputname','U1_Node104'); % name of time dependent response
 
%% Add injector and extractor to connector 
Xconn1 = Xconn1.add(Xinjector);
Xconn1 = Xconn1.add(XtableInjector);
Xconn1 = Xconn1.add(Xte1);
         
%% Execute deterministic analysis
Xin=Xin.sample('Nsamples',2);
Xout1 = Xconn1.run(Xin);

%% Visualize extracted response
f1=figure;
plot(Xout1.Tvalues.U1_Node104.Mcoord,Xout1.Tvalues.U1_Node104.Vdata)

%% Close figure and validate solution
close(f1);
break
% reference solution (response of tip due to dropped load)
Vreference = [0  1.1296e-04  6.0031e-04  1.2209e-03  1.7666e-03  2.4168e-03 ...
     3.0162e-03  3.4425e-03  3.6957e-03  3.6469e-03  3.2817e-03  2.8180e-03 ...
     2.3059e-03  1.6838e-03  1.1684e-03  9.5108e-04  9.9018e-04  1.2522e-03 ...
     1.6610e-03  2.1058e-03  2.5696e-03  2.9903e-03  3.2392e-03  3.2808e-03 ...
     3.1527e-03  2.8682e-03  2.4562e-03  2.0065e-03  1.6190e-03  1.3821e-03 ...
     1.3346e-03  1.4347e-03  1.6447e-03  1.9530e-03  2.3116e-03  2.6440e-03 ...
     2.8846e-03  2.9929e-03  2.9590e-03  2.7963e-03  2.5300e-03  2.0989e-03 ...
     1.3185e-03  4.8885e-04 -1.6090e-04 -8.0587e-04 -1.2962e-03 -1.5277e-03 ...
    -1.5319e-03 -1.2291e-03 -6.5720e-04 -6.9253e-05  4.6698e-04  1.0100e-03 ...
     1.3619e-03  1.3700e-03  1.1194e-03  6.8090e-04  1.5667e-04 -3.2833e-04 ...
    -7.5148e-04];

assert(all(abs(Xout1.Tvalues.U1_Node104.Mdata-Vreference)<1e-4),...
    'CossanX:Tutorials:TutorialCragoCrane','Reference Solution does not match.')


%% Remove simulation files
delete('crane.com','crane.dat','crane.fil', ...
       'crane.msg','crane.odb','crane.prt', ...
       'crane.sta','results.txt','abaqus.rpy*')


