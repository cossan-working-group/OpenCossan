%% Tutorial 6 Storey Building - Creating the FEAP model
%
% This tutorial create  the Feap Model for the 6 storey building
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/6-Storey_Building_(SFEM)
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 

%% Create the input

% define the random parameters
% Young's modulus of all mat cards are assigned as RV with CoV=10%
Floors=RandomVariable('Sdistribution','normal', 'mean',30e9,'cov',0.1);         
Columns=RandomVariable('Sdistribution','normal', 'mean',30e9,'cov',0.1);
Stairs=RandomVariable('Sdistribution','normal', 'mean',30e9,'cov',0.1);         
Walls=RandomVariable('Sdistribution','normal', 'mean',30e9,'cov',0.1);
Ceil=RandomVariable('Sdistribution','normal', 'mean',30e9,'cov',0.1);
Soil=RandomVariable('Sdistribution','normal', 'mean',50e6,'cov',0.1);
Xrvs = RandomVariableSet('Cmembers',{'Floors','Columns','Stairs','Walls','Ceil','Soil'},...
    'CXmembers',{Floors,Columns,Stairs,Walls,Ceil,Soil}); 
Xinp = Input('Sdescription','Input for the Feap Model','CSmembers',{'Xrvs'},'CXmembers',{Xrvs});       

%display input
display(Xinp)

%% Define the model
ScurrentFile=mfilename('fullpath');
Sdirectory = fullfile(fileparts(ScurrentFile),'FEinputFiles');
% The injector is creating automatically scannning the input files containing
% identifiers
Xinj       = Injector('Sscanfilepath',Sdirectory,'Sscanfilename','Feap.cossan','Sfile','Feap.inp');
% Create Connector
Xcon       = Connector('Stype','feap',...
                     'SmaininputPath',Sdirectory,...
                     'Smaininputfile','Feap.inp',...
                     'Lkeepsimfiles',false);
Xcon   = add(Xcon,Xinj);
Xeval  = Evaluator('Xconnector',Xcon);
Xmodel = Model('Xevaluator',Xeval,'Xinput',Xinp);

display(Xmodel);

%% Run deterministic Analysis
% the determinisitc analysis of the model is used to generate the output files
% of the solver.
Xout=Xmodel.deterministicAnalysis;

