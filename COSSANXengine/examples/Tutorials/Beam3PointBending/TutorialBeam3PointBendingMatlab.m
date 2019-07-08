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

youngs   = RandomVariable('Sdistribution','normal','mean',210e3,'std',10e3);    
force    = RandomVariable('Sdistribution','lognormal','mean',10,'std',1.4); 
height   = RandomVariable('Sdistribution','uniform','lowerbound',4,'upperbound',6);    
width    = Parameter('value',8.1);  
max_disp = Parameter('value',0.015); 
inertia  = Function('Sexpression','<&width&>.*<&height&>.^3/12');

Xrvs = RandomVariableSet('Cmembers',{'youngs','force','height'}); 

Xinp = Input('Sdescription','Xinput object',...
    'CXmembers',{Xrvs width inertia max_disp},...                   % object list
    'CSmembers',{'Xrvs' 'width' 'inertia' 'max_disp'});    % name of the objects 

% See summary of the Input
display(Xinp)

%% Preparation of the Evaluator

Xmio = Mio('Sfile','displacement.m','Cinputnames',{'youngs','force','height','width','inertia'}, ...
           'Coutputnames',{'disp'},'Spath',StutorialPath);
       
Xevaluator = Evaluator('CXmembers',{Xmio},'CSmembers',{'Xmio'});

%% Preparation of the Model

Xmodel=Model('Xinput',Xinp,'Xevaluator',Xevaluator);

% See summary of the Model
display(Xmodel)
