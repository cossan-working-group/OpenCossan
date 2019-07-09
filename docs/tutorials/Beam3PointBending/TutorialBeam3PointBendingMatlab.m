%% Tutorial Simpy Supported Beam - Matlab
% The displacements are blocked in all the direction at one of the extremity of the beam 
% (however, rotation is possible). The other extremity can move freely in 
% the horizontal direction.
% 
% The beam is assumed to have a rectangular cross section. The length L of 
% the beam is 100mm, a force is applied at 25mm from an extremity.
% The quantity of interest is the displacement (in the  vertical direction)
% at the middle of the beam.
%
% The model is analysed using a Matlab script
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/Beam_3-point_bending_(overview)
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Pierre~Beaurepaire$ 

StutorialPath = fileparts(which('displacement.m'));
%% Create the input

youngs   = common.inputs.RandomVariable('Sdistribution','normal','mean',210e3,'std',10e3);    
force    = common.inputs.RandomVariable('Sdistribution','lognormal','mean',10,'std',1.4); 
height   = common.inputs.RandomVariable('Sdistribution','uniform','lowerbound',4,'upperbound',6);    
width    = common.inputs.Parameter('value',8.1);  
max_disp = common.inputs.Parameter('value',0.015); 
inertia  = common.inputs.Function('Sexpression','<&width&>.*<&height&>.^3/12');

Xrvs = common.inputs.RandomVariableSet('CXrandomVariables',{youngs force height},'Cmembers',{'youngs','force','height'}); 
Xinp = common.inputs.Input('Sdescription','Xinput object');       
Xinp = add(Xinp,'Xmember',Xrvs,'Sname','Xrvs');
Xinp = add(Xinp,'Xmember',width,'Sname','width');
Xinp = add(Xinp,'Xmember',inertia,'Sname','inertia');
Xinp = add(Xinp,'Xmember',max_disp,'Sname','max_disp');

% See summary of the Input
display(Xinp)

%% Preparation of the Evaluator

Xmio = workers.Mio('Sfile','displacement.m','Cinputnames',{'youngs','force','height','width','inertia'}, ...
           'Coutputnames',{'disp'},'Spath',StutorialPath,'Sformat','structure');
       
Xevaluator = workers.Evaluator('CXmembers',{Xmio},'CSmembers',{'Xmio'});

%% Preparation of the Model

Xmodel = common.Model('Xinput',Xinp,'Xevaluator',Xevaluator);

% See summary of the Model
display(Xmodel)
