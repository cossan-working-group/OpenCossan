%% Tutorial 6 Storey Building - Creating the ANSYS model
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/6-Storey_Building_(SFEM)
%
% Copyright 1990-2011 Cossan Working Group
% $Revision: 1 $  $Date: 2011/02/22 $

%% Create the input
% define the random parameters
% Young's modulus of all mat cards are assigned as Random Variable with CoV=10%
RV1=RandomVariable('Sdistribution','normal', 'mean',7e4,'cov',0.1);         
RV2=RandomVariable('Sdistribution','normal', 'mean',7e4,'cov',0.1);
RV3=RandomVariable('Sdistribution','normal', 'mean',7e4,'cov',0.1);         
RV4=RandomVariable('Sdistribution','normal', 'mean',7e4,'cov',0.1);

Xrvs = RandomVariableSet('Cmembers',{'RV1','RV2','RV3','RV4'}); 
Xinp = Input('Sdescription','Xinput object');       
Xinp = add(Xinp,Xrvs);

%% Define the model
% 
Sdirectory = fullfile(OpenCossan.getCossanRoot,'examples','Tutorials','6StoreyBuilding','FEinputFiles');
Xinj       = Injector('Sscanfilepath',Sdirectory,'Sscanfilename','Ansys.cossan','Sfile','Ansys.inp');
Xcon       = Connector('SpredefinedType','ansys',...
                     'SmaininputPath',Sdirectory,...
                     'Smaininputfile','Ansys.inp',...
                     'Sworkingdirectory','/tmp/',...
                     'Lkeepsimfiles',true);
Xcon   = add(Xcon,Xinj);
Xjmi   = JobManagerInterface('Stype','gridengine');
Xeval  = Evaluator('Xconnector',Xcon,'CSmembers',{'Xcon'},'XJobManagerInterface',Xjmi,...
                   'LremoteInjectExtract',false,'CSqueues',{'fedora.q'},'Nconcurrent',1);
Xmodel = Model('Xevaluator',Xeval,'Xinput',Xinp);

display(Xmodel);



