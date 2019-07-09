%% Tutorial Small Satellite - Static Analysis Model
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/Small_Satellite

% Copyright 1990-2011 Cossan Working Group
% $Revision: 1 $  $Date: 2011/02/22 $

%% Create the input

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
Xinp = Input('Sdescription','Xinput object');       
Xinp = add(Xinp,Xrvs);

%% Construct the Model

Sdirectory = fileparts(which('TutorialSmallSatelliteStatic'));
Xinj       = Injector('Sscanfilepath',fullfile(Sdirectory,'FEinputFiles'),'Sscanfilename','Static.cossan','Sfile','Static.inp');
Xcon       = Connector('SpredefinedType','nastran_x86_64',...
                     'SmaininputPath',fullfile(Sdirectory,'FEinputFiles'),...
                     'Smaininputfile','Static.dat');
Xcon       = add(Xcon,Xinj);
Xeval      = Evaluator('Xconnector',Xcon,'CSmembers',{'Xcon'});
Xmodel     = Model('Xevaluator',Xeval,'Xinput',Xinp);

display(Xmodel);




