%**************************************************************************
% In this tutorial it is shown how to use the mode-based meta-model using a
% truss structure, where the solver is a mio-object. The eigenvalues,
% eigenvectors and in the sequence the FRFs are approximated using the
% meta-model and compared to the extract solution computed with the mio.
%
% Prepared by BG
%
%  Copyright 1993-2011, COSSAN Working Group
%  University of Innsbruck, Austria
%
% See Also: 
% https://cossan.co.uk/wiki/index.php/Truss_Bridge_Structure

% Reset the random number generator in order to always obtain the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)

%% Define the full model (truss bridge structure)
Sdirectory = fileparts(which('TutorialTrussBridgeStructure.m'));
% visualize model
run(fullfile(Sdirectory,'plot_model'));

% Define RVs (33 for mass and 131 for stiffness)
mass1=RandomVariable('Sdistribution','normal', 'mean',1e0,'std',0.025*1e0); 
stiffness1=RandomVariable('Sdistribution','normal', 'mean',1e3,'std',0.025*1e3);

Xrvs1 = RandomVariableSet('Xrv',mass1,'Nrviid',33);
Xrvs2 = RandomVariableSet('Xrv',stiffness1,'Nrviid',131);

% Define Xinput
Xin = Input('Sdescription','Input truss',...
    'CXmembers',{Xrvs1,Xrvs2},'CSmembers',{'Xrvs1','Xrvs2'});


% Construct Mio object (computes eigenvalues, eigenvectors, mass and stiffness matrix)
Sdirectory = fileparts(which('TutorialTrussBridgeStructure.m'));
Xm=Mio('Sdescription', 'Performance function', ...
                'Spath',Sdirectory, ...
                'Sfile','gen_truss', ...
                'Cinputnames',Xin.CnamesRandomVariable, ...
                'Coutputnames',{'mass','stiff','MPhi','Vlambda'}, ...
                'Liostructure',true,...
				'Lfunction',true); % This flag specify if the .m file is a script or a function. 
            

% Construct the Evaluator
Xeval = Evaluator('Xmio',Xm,'Sdescription','Evaluator xmio');
% create the Xmodel
Xmdl=Model('Xevaluator',Xeval,'Xinput',Xin);

%% Define the mode-based metamodel - method 1 
load(fullfile(Sdirectory,'mass_matrix_nominal'));
Nsamples_calibration = 400; % number of calibration samples
Nsamples_validation = 20; % number of validation samples
Vmodes = 1:20; % index of modes to be approximated

% constructor
Xmm = ModeBased('Sdescription','metamodel-tutorial', ...
                'XFullmodel',Xmdl, ... % full model
                'Cnamesmodalprop',{'Vlambda','MPhi'}, ... % names of eigenvalues and eigenvectors (outputs of full model)
                'Mmass0',mass_mat, ... % nominal mass matrix
                'Vmodes',Vmodes);  

% calibration by passing the number of samples
Xmm = calibrate(Xmm,'Nsamples',Nsamples_calibration,'Vmodes',Vmodes,'Vmkmodes',3*ones(length(Vmodes),1),'Mmass0',mass_mat);

% validation by passing the number of samples
[Xmm, Xoutput_metamodel] = validate(Xmm,'Nsamples',Nsamples_validation);

% comparison of FRFs computed with full model and approximated model
run(fullfile(Sdirectory,'plot_comparison')); 

% apply meta-model
Xin = sample(Xin,'Nsamples',100); 
Xout = apply(Xmm,Xin);
%% close figures and validate solution
close(f) % comparison of FRFs
assert(all(all(abs(Xout(1).Vlambda(1:10)'-[1.6839, 2.9032, 18.0768, 19.3487, ...
        23.9998, 26.7626, 64.5307, 76.7520, 92.0892, 117.1737])<1e-4)),'CossanX:Tutorials:TutorialTrussBridgeStructure', ...
       'Reference solution of approximated eigenvalues does not match.')

%% Define the mode-based metamodel - method 2 
% user-defined points for calibration and validation
XtrainingInput = sample(Xin,'Nsamples',Nsamples_calibration);
XvalidationInput = sample(Xin,'Nsamples',Nsamples_validation);

% define meta-model with passing XtrainingInput; calls also method calibrate
Xmm = ModeBased('Sdescription','metamodel-tutorial',...
                'XFullmodel',Xmdl,... % full model 
                'Cnamesmodalprop',{'Vlambda','MPhi'},... % names of eigenvalues and eigenvectors (outputs of full model)
                'XcalibrationInput',XtrainingInput,... % Input object with calibration points
                'Vmodes',Vmodes,... % index of modes to be approximated
                'Vmkmodes',3*ones(length(Vmodes),1),... % number of modes to be used for the approximation of each mode
                'Mmass0',mass_mat);
 
% validate at user-defined validation points (calibration already performed since calibration points have been passed to the constructor)           
[Xmm, Xoutput_metamodel] = validate(Xmm,'XvalidationInput',XvalidationInput);           

% comparison of FRFs computed with full model and approximated model
run(fullfile(Sdirectory,'plot_comparison'));

% apply meta-model
Xin = sample(Xin,'Nsamples',100); 
Xout = apply(Xmm,Xin);

%% close figures and validate solution

close(f) % comparison of FRFs
assert(all(all(abs(Xout(1).Vlambda(1:10)'-[1.6723, 2.8514, 17.9880, 18.8450, ...
        23.9768, 27.8111, 63.8223, 77.2441, 92.9696, 116.3853])<1e-4)),'CossanX:Tutorials:TutorialTrussBridgeStructure', ...
       'Reference solution of approximated eigenvalues does not match.')

%% Define the mode-based metamodel - method 3 

% validation and calibration input and output already available

% define metamodel with passing Input and Output of calibration points
Xmm = ModeBased('Sdescription','metamodel-tutorial',...
                'XFullmodel',Xmdl,... % full model
                'Cnamesmodalprop',{'Vlambda','MPhi'},... % names of eigenvalues and eigenvectors (outputs of full model)
                'SfilenamesCalibrationSet','Xcalibration_set1',... % name of file where calibration points are stored 
                'SnamesCalibrationInput','Xin1',... % name of Input object stored in the file as specified above
                'SnamesCalibrationOutput','Xmodes1',... % name of Modes object with the eigenvalues and eigenvectors corresponding to the Input object
                'Vmodes',Vmodes,... % index of modes to be approximated
                'Vmkmodes',3*ones(length(Vmodes),1),... % number of modes to be used for the approximation of each mode
                'Mmass0',mass_mat); % nominal mass matrix
            
% validate with previously calculated validation samples
% (calibration is already done since the calibration points have been passed to the constructor)
load(fullfile(Sdirectory,'validation_IO'),'XvalidationInput','XvalidationOutput');
[Xmm, Xoutput_metamodel] = validate(Xmm,'XvalidationInput',XvalidationInput,'XvalidationOutput',XvalidationOutput);   

% comparison of FRFs computed with full model and approximated model
run(fullfile(Sdirectory,'plot_comparison'));

% apply meta-model
Xin = sample(Xin,'Nsamples',100); 
Xout = apply(Xmm,Xin);

%% close figures and validate solution

close(f1) % figure with model
close(f) % comparison of FRFs
assert(all(all(abs(Xout(1).Vlambda(1:10)'-[1.6726, 2.8973, 17.9788, 18.9118, ...
        23.6797, 26.9788, 65.1409, 75.3075, 90.7483, 117.1788])<1e-4)),'CossanX:Tutorials:TutorialTrussBridgeStructure', ...
       'Reference solution of approximated eigenvalues does not match.')
