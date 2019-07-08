%% Tutorial Small Satellite - Static Analysis Model
%
% This tutorial shows how to prepare a connector to perform a simple static
% analysis of the Small Satellite FE model. 
%
% The FE model is constructed in NASTRAN (~5000 DOFs).%
% The uncertainties in the Young's modulus and density are 
% modeled using independent normal RV's.  
%
% See also http://cossan.co.uk/wiki/index.php/Small_Satellite

% Copyright 2006-2018 Cossan Working Group
% $Revision: 1 $  $Date: 2011/02/22 $
% $Revision: 2 $  $Date: 2018/08/28 $

%% Define input of the model 

% define the RVs
% vert: vertical Panels, hor: horizontal panels (i.e. upper and lower)
% cyl: cylinder, nozzle: nozzle
%
Evert   = RandomVariable('Sdistribution','normal', 'mean',7e6,'cov',0.15);    
Ehor    = RandomVariable('Sdistribution','normal', 'mean',7e6,'cov',0.15);
Ecyl    = RandomVariable('Sdistribution','normal', 'mean',7e6,'cov',0.15); 
Enozzle = RandomVariable('Sdistribution','normal', 'mean',7e6,'cov',0.15);

Dvert   = RandomVariable('Sdistribution','normal', 'mean',2700e-6,'cov',0.1); 
Dhor    = RandomVariable('Sdistribution','normal', 'mean',2700e-6,'cov',0.1); 
Dcyl    = RandomVariable('Sdistribution','normal', 'mean',2700e-6,'cov',0.1);    
Dnozzle = RandomVariable('Sdistribution','normal', 'mean',2700e-6,'cov',0.1);   

tvert   = RandomVariable('Sdistribution','normal', 'mean',0.15,'cov',0.05); 
thor    = RandomVariable('Sdistribution','normal', 'mean',0.15,'cov',0.05); 
tcyl    = RandomVariable('Sdistribution','normal', 'mean',0.15,'cov',0.05);       
tnozzle = RandomVariable('Sdistribution','normal', 'mean',0.15,'cov',0.05);  

Xrvs = RandomVariableSet('Cmembers',{'Evert','Ehor','Ecyl','Enozzle',...
                                     'Dvert','Dhor','Dcyl','Dnozzle',...
                                     'tvert','thor','tcyl','tnozzle'}); 
                                 
Xinp = Input('Sdescription','Xinput object','XrandomVariableSet',Xrvs);       

%% Construct the Model
Sdirectory = fileparts(which('TutorialSmallSatelliteStatic'));
Xinj       = Injector('Sscanfilepath',fullfile(Sdirectory,'FEinputFiles'),'Sscanfilename','Static.cossan','Sfile','Static.inp');
Xcon       = Connector('SpredefinedType','nastran',...
                     'SmaininputPath',fullfile(Sdirectory,'FEinputFiles'),...
                     'Smaininputfile','Static.inp');
Xcon       = add(Xcon,Xinj);
Xeval      = Evaluator('Xconnector',Xcon,'CSmembers',{'Xcon'});
Xmodel     = Model('Xevaluator',Xeval,'Xinput',Xinp);

display(Xmodel);

%% Check if the solver is available
Ltes=Xcon.test; 


