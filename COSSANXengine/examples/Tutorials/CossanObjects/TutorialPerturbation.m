% Tutorial for the Perturbation Object
% This tutorial shows how to create and use a Perturbation object
%
% Copyright 1990-2011 Cossan Working Group
% $Revision: 1 $  $Date: 2011/02/22 $

%% Create the input

% define the RVs
RV1 = RandomVariable('Sdistribution','normal', 'mean',7e7,'std',7e6);    
RV2 = RandomVariable('Sdistribution','normal', 'mean',7e7,'std',7e6); 
RV3 = RandomVariable('Sdistribution','normal', 'mean',7e7,'std',7e6);       

Xrvs = RandomVariableSet('Cmembers',{'RV1','RV2','RV3'}); 
Xinp = Input('Sdescription','Xinput object');       
Xinp = add(Xinp,Xrvs);

%% Construct the Injector

Sdirectory = fullfile(OpenCossan.getCossanRoot,'examples','Tutorials','TurbineBlade','FEinputFiles');
Xinj       = Injector('Sscanfilepath',Sdirectory,...
                      'Sscanfilename','Nastran.cossan','Sfile','Nastran.inp');

%% Define Connector

Xcon = Connector('SpredefinedType','nastran_x86_64',...
                     'SmaininputPath',Sdirectory,...
                     'Smaininputfile','Nastran.inp');
Xcon = add(Xcon,Xinj);

%% Define Model

Xeval  = Evaluator('Xconnector',Xcon);
Xmodel = Model('Xevaluator',Xeval,'Xinput',Xinp);

%% using Regular implementation (NASTRAN)
                   
Xsfem = Perturbation('Xmodel',Xmodel,'CyoungsmodulusRVs',{'RV1','RV2','RV3'});                                           
Xout  = Xsfem.performAnalysis;

Xout  = getResponse(Xout,'Sresponse','specific','MresponseDOFs',[150 3]);
display(Xout);

%% Validate the results

referenceMean = 0.89798;
referenceCoV  = 0.098122;

assert(abs(Xout.Vresponsemean-referenceMean)<1e-3,'CossanX:Tutorials:TutorialPerturbation', ...
      'Reference mean value does not match.')

assert(abs(Xout.Vresponsecov-referenceCoV)<1e-3,'CossanX:Tutorials:TutorialPerturbation', ...
      'Reference CoV value does not match.')


