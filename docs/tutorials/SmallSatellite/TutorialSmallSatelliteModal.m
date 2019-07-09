%% Tutorial Small Satellite - Create the NASTRAN model
%
% This tutorial shows how to perform SFEM analysis using Perturbation
% method. 
%
% Description of deterministic model:
%
% Tutorial satellite model is constructed in NASTRAN (~5000 DOFs). Modal
% analysis is performed on the structure, where the variation in the
% 2nd natural frequency is sought.
%
% Description of probabilistic model:
%
% The uncertainties in the Young's modulus and density are 
% modeled using independent normal RV's.  
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/
%
% Copyright 1990-2011 Cossan Working Group
% $Revision: 1 $  $Date: 2011/02/28 $

%% Create the input

% define the RVs
Evert   = RandomVariable('Sdistribution','normal', 'mean',7e6,'cov',0.15);    
Ehor    = RandomVariable('Sdistribution','normal', 'mean',7e6,'cov',0.15);
Ecyl    = RandomVariable('Sdistribution','normal', 'mean',7e6,'cov',0.15); 
Enozzle = RandomVariable('Sdistribution','normal', 'mean',7e6,'cov',0.15);

Dvert   = RandomVariable('Sdistribution','normal', 'mean',2700e-6,'cov',0.1); 
Dhor    = RandomVariable('Sdistribution','normal', 'mean',2700e-6,'cov',0.1); 
Dcyl    = RandomVariable('Sdistribution','normal', 'mean',2700e-6,'cov',0.1);    
Dnozzle = RandomVariable('Sdistribution','normal', 'mean',2700e-6,'cov',0.1);   

Xrvs = RandomVariableSet('Cmembers',{'Evert','Ehor','Ecyl','Enozzle',...
                                     'Dvert','Dhor','Dcyl','Dnozzle'}); 
Xinp = Input('Sdescription','Xinput object');       
Xinp = add(Xinp,Xrvs);

%% Construct the Model

Sdirectory = fileparts(which('TutorialSmallSatelliteModal'));
Xinj       = Injector('Sscanfilepath',fullfile(Sdirectory,'FEinputFiles'),'Sscanfilename','Modal.cossan',...
                      'Sfile','Modal.inp');
Xcon       = Connector('SpredefinedType','nastran_x86_64',...
                     'SmaininputPath',fullfile(Sdirectory,'FEinputFiles'),...
                     'Smaininputfile','Modal.dat');
Xcon       = add(Xcon,Xinj);
Xeval      = Evaluator('Xconnector',Xcon,'CSmembers',{'Xcon'});
Xmodel     = Model('Xevaluator',Xeval,'Xinput',Xinp);

display(Xmodel);



