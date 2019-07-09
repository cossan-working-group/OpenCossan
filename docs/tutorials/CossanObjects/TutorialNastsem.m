% Tutorial for the Nastsem Object
% This tutorial shows how to create and use a Nastsem object

% $Revision: 1 $  $Date: 2011/02/22 $
clear
close all
clc;

%% Create the input

% define the RVs
RV1 = opencossan.common.inputs.random.NormalRandomVariable('mean',7e7,'std',7e6);    
RV2 = opencossan.common.inputs.random.NormalRandomVariable('mean',7e7,'std',7e6); 
RV3 = opencossan.common.inputs.random.NormalRandomVariable('mean',7e7,'std',7e6);       

Xrvs = opencossan.common.inputs.random.RandomVariableSet('names',{'RV1','RV2','RV3'},'members',[RV1;RV2;RV3]); 
Xinp = opencossan.common.inputs.Input('description','Xinput object','members',Xrvs,'membersnames','Xrvs');       


%% Construct the Injector

Sdirectory = fullfile(opencossan.OpenCossan.getRoot,'examples','Tutorials','TurbineBlade','FEinputFiles');
Xinj       = opencossan.workers.ascii.Injector('Sscanfilepath',Sdirectory,...
                      'Sscanfilename','Nastran.cossan','Sfile','Nastran.inp');

%% Define Connector

Xcon = Connector('Spredefinedtype','nastran_x86_64',...
                     'SmaininputPath',Sdirectory,...
                     'Smaininputfile','Nastran.inp');
Xcon = add(Xcon,Xinj);
%Xjmi   = JobManagerInterface('Stype','gridengine');
Xeval  = Evaluator('Xconnector',Xcon,'CSmembers',{'Xcon'});

%% Define Model

Xmodel = Model('Xevaluator',Xeval,'Xinput',Xinp);

%% using Regular implementation (NASTRAN)
                   
Xsfem = Nastsem('Xmodel',Xmodel,'CyoungsmodulusRVs',{'RV1','RV2','RV3'},...
                'Smethod','Perturbation','Vfixednodes',[1777 616 1779 4120 4276 4286]);                                           
Xout  = Xsfem.performAnalysis;

Xout  = getResponse(Xout,'Sresponse','specific','MresponseDOFs',[150 3]);
display(Xout);

%% Validate the results
referenceMean = 0.89798;
referenceCoV  = 0.098122;

assert(abs(Xout.Vresponsemean-referenceMean)<1e-3,'CossanX:Tutorials:TutorialNastsem', ...
      'Reference mean value does not match.')

assert(abs(Xout.Vresponsecov-referenceCoV)<1e-2,'CossanX:Tutorials:TutorialNastsem', ...
      'Reference CoV value does not match.')


