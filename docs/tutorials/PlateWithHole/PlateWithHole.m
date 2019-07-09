 
% Retrieve the directory where this tutorial is stored
StutorialPath = fileparts(which('PlateWithHole.m'));

% Copy the files that required to be writted ans modified in a working directory. 
% The FE input files can be written or created in this directory. The directory is on a network
% share, reachable by every cluster machine, and the user has write
% permission on it.



SexecutionFolder=fullfile(OpenCossan.getCossanWorkingPath,'TutorialWorkingDir');
mkdir(SexecutionFolder);

copyfile([StutorialPath filesep 'BeamFeap' filesep '*'],SexecutionFolder,'f');

 
 OpenCossan.resetRandomNumberGenerator(31415)

Xin = Input; 

rv1  =RandomVariable('Sdistribution','uniform','par1',-2.5,'par2',-.9);
rv2  =RandomVariable('Sdistribution','uniform','par1',-2.5,'par2',-.9);
Xrvs = RandomVariableSet('Cmembers',{'rv1','rv2'});
Xin = Xin.add(Xrvs);


crackLength1 = Function('Sexpression','10^<&rv1&>');
Xin = Xin.add(crackLength1);

crackLength2 = Function('Sexpression','10^<&rv2&>');
Xin = Xin.add(crackLength2);

% crackLength1 = DesignVariable('value',1e-2,'VlevelValues',10.^[-3:.1:-.9]);
% Xin = Xin.add(crackLength1);
% 
% crackLength2 = DesignVariable('value',1e-2,'VlevelValues',10.^[-3:.1:-.9]);
% Xin = Xin.add(crackLength2);


distanceNearestKP1 = Function('Sexpression','min(<&crackLength1&>/3,1e-3)');
Xin = Xin.add(distanceNearestKP1);

distanceNearestKP2 = Function('Sexpression','min(<&crackLength2&>/3,1e-3)');
Xin = Xin.add(distanceNearestKP2);

maximumStress = Parameter('value',100e6);
minimumStress = Parameter('value',20e6);

Xin = Xin.add(maximumStress);
Xin = Xin.add(minimumStress);



%%   Injector
Xi  = Injector(...
    'Sscanfilename','PlateWithHole.cossan',...
    'Sfile','PlateWithHole'...
    );

XrespKi1 = Response('Sname', 'Ki1', ...
             'Sfieldformat', '%17e%', ...
             'Clookoutfor',{'***  KI'}, ...
             'Ncolnum',12, ...
             'Nrownum',0 ...
             );
          
XrespKi2 = Response('Sname', 'Ki2', ...
             'Sfieldformat', '%17e', ...
             'Clookoutfor',{'***  KI'}, ...
             'Ncolnum',12, ...
             'Nrownum',0 ...
             );        
         
         

Xe1=Extractor('Sdescription','Extractor for plate.f06', ...
             'Srelativepath','./', ...
             'Sfile','PlateWithHole.out',...
             'Xresponse',XrespKi1 );
%                       

Xe2=Extractor('Sdescription','Extractor for plate.f06', ...
             'Srelativepath','./', ...
             'Sfile','PlateWithHole.out',...
             'Xresponse',XrespKi2);
%%

Xc = Connector(...
    'Stype','ansys' ,...
    'Ssolverbinary','/usr/site/ansys/12.0SP1/i386/v120/ansys/bin/ansys120' ,...
    'Sexecmd','%Ssolverbinary %Smaininputfile ',...
    'Sworkingdirectory','/tmp/',...
    'Smaininputpath','./',...
    'Smaininputfile','PlateWithHole','Lkeepsimulationfiles',false);
 Xc.Sexeflags = '-p aa_t_i -o PlateWithHole.out';
 
Xc = Xc.add(Xi);
Xc = Xc.add(Xe1);
Xc = Xc.add(Xe2);



Xmio = Mio('Spath',[ pwd '/'], ...
    'Sfile','stressIntensityFactors', ...
    'Coutputnames',{'deltaK1','deltaK2'},...
    'Cinputnames',[Xin.Cnames  Xc.Coutputnames'],...
    'Liostructure',true,...     % This flag specify the type of I/O
    'Liomatrix',false, ...  % This flag specify the type of I/O
    'Lfunction',true); % the .m file is a script or a function.


%%
Xe = Evaluator('CXmembers',{Xc,Xmio});
Xmdl=Model('Xinput',Xin,'Xevaluator',Xe);


% Xdoe = DesignOfExperiments('SdesignType','FullFactorial');
Xin = sample(Xin,'Nsamples',220);
Xout = Xe.apply(Xin);

save results4 Xout Xin

%% training of the response surface



load results3

crackLength1 = RandomVariable('Sdistribution','uniform','par1',10^-2.1,'par2',10^-.9);
crackLength2 = RandomVariable('Sdistribution','uniform','par1',10^-2.1,'par2',10^-.9);
Xrvs = RandomVariableSet('Cmembers',{'crackLength1','crackLength2'});



XcalibrationInput = Input; 

XcalibrationInput = XcalibrationInput.add(Xrvs);

MX = Xout.getValues('Cnames',{'crackLength1','crackLength2'});
% MX(isnan( Xout.getValues('Cnames',{'Ki1'})),:) =[];
Xs = Samples('msamplesphysicalspace', MX, ...
    'Xrvset',Xrvs);
XcalibrationInput = XcalibrationInput.add(Xs);

%%

Xnn     = NeuralNetwork(...
    'Vnnodes',[2 15 4],...
    'XcalibrationInput',XcalibrationInput,...
'Coutputnames',{'Ki1','Ki2','deltaK1','deltaK2'},...  %response to be extracted from full model
'Xcalibrationoutput',Xout,...  %Output for training ResponseSurface
'Stype','HyperbolicTangent');   %type of response surface
Xnn.plotregression('stype','calibration','Soutputname','Ki1')

%% Definition of inputs

Xin  = Input();

% Initial length of the cracks
Xrv_a= RandomVariable('Sdistribution','lognormal','mean',1e-2,'cov',.5);

% Coefficient C in Paris equation
Xrv_C= RandomVariable('Sdistribution','lognormal','mean',2.e-22,'cov',.1);

% Fracture toughness
Kic=RandomVariable('Sdistribution','lognormal','mean',3e7,'cov',.1);

Xrvs    = RandomVariableSet( ...
    'Cmembers',{'crackLength1','crackLength2','C','Kic'}...
    ,'Xrv',[Xrv_a,Xrv_a,Xrv_C,Kic]);
Xin     = add(Xin,Xrvs);

% Coefficient m in Paris equation
m=Parameter('value',2.1);
Xin = add(Xin,m);

% Maximum applied stress
smax=Parameter('value',100e6);
Xin = add(Xin,smax);

% Minimum applied stress
smin=Parameter('value',20e6);
Xin = add(Xin,smin);




%% Data related to FatigueFracture object

% Definition of the CrackGrowth object. It takes as an inpout the outputs
% of the evaluator which determines the stress intensity factor, The
% outputs of this objects are the variations of the crack length over one
% cycle


Sscript1 = [...
    'Cdummy=num2cell(zeros(length(Tinput),1));'...
'Toutput=struct(''da1dn'',Cdummy,''da2dn'',Cdummy);'...
'for i=1:length(Tinput),'...
'   Toutput(i).da1dn = Tinput.C*(Tinput(i).deltaK1)^ Tinput(i).m;'...
'   Toutput(i).da2dn = Tinput.C*(Tinput(i).deltaK2)^ Tinput(i).m;'...
'end' ];


Xcg = CrackGrowth('Lfunction',false,'Liostructure',true,'Liomatrix',false,...
    'Cinputnames',{'deltaK1','deltaK2','m','C'},... % Define the inputs
    'Sscript',Sscript1,...
    'Coutputnames',{'da1dn','da2dn'});

% Definition of the CrackGrowth object. It takes as an inpout the outputs
% of the evaluator which determines the stress intensity factor, The
% outputs of this is <0 if fracture does not occur, and >0 if fracture has
% occured
Xf = Fracture('Liomatrix',false,...
    'Cinputnames',{'Ki1','Ki2','Kic'},... % Define the inputs...
    'Sscript','for j=1:length(Tinput), Toutput(j).fract= min([Tinput(j).Ki1-Tinput(j).Kic,Tinput(j).Ki2-Tinput(j).Kic]); end', ...
    'Coutputnames',{'fract'},...
    'Liostructure',true,...
    'Lfunction',false); 


Xff = FatigueFracture('Xsolver',Xnn,'Ccrack',{'crackLength1','crackLength2'}, 'Xcrackgrowth',Xcg ,'Xfracture',Xf,'Cinputnames',Xin.Cnames); 
  
Xin = Xin.sample('Nsample',50);


[Xo,Xfof]=Xff.apply(Xin)