%% Tutorial 6 Storey Building - Creating the ABAQUS model
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/6-Storey_Building_(SFEM)
%
% Copyright 1990-2011 Cossan Working Group
% $Revision: 1 $  $Date: 2011/02/22 $

%% Create the input

% define the random parameters
% Young's modulus of all mat cards are assigned as RV with CoV=10%
RV1=RandomVariable('Sdistribution','normal', 'mean',7e4,'cov',0.1);         
RV2=RandomVariable('Sdistribution','normal', 'mean',7e4,'cov',0.1);
RV3=RandomVariable('Sdistribution','normal', 'mean',7e4,'cov',0.1);         
RV4=RandomVariable('Sdistribution','normal', 'mean',7e4,'cov',0.1);

Xrvs = RandomVariableSet('Cmembers',{'RV1','RV2','RV3','RV4'}); 
Xinp = Input('Sdescription','Xinput object');       
Xinp = add(Xinp,Xrvs);

%% Define the model

Sdirectory = fullfile(OpenCossan.getCossanRoot,'examples','Tutorials','6StoreyBuilding','FEinputFiles');
Xinj       = Injector('Sscanfilepath',Sdirectory,'Sscanfilename','Abaqus.cossan','Sfile','Abaqus.inp');
Xcon       = Connector('SpredefinedType','abaqus',...
                     'SmaininputPath',Sdirectory,...
                     'Smaininputfile','Abaqus.inp');
Xcon   = add(Xcon,Xinj);
Xeval  = Evaluator('Xconnector',Xcon);
Xmodel = Model('Xevaluator',Xeval,'Xinput',Xinp);

display(Xmodel);
