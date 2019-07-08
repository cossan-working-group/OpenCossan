%% Tutorial Beam 3-point bending (ABAQUS)
% The displacements are blocked in all the direction at one of the extremity of the beam 
% (however, rotation is possible). The other extremity can move freely in 
% the horizontal direction.
% 
% The beam is assumed to have a rectangular cross section. The length L of 
% the beam is 100mm, a force is applied at 25mm from an extremity.
% The quantity of interest is the displacement (in the  vertical direction)
% at the middle of the beam.
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/Beam_3-point_bending_(overview)
%
% $Copyright~1993-2017,~COSSAN~Working~Group,$
% $Author:~Pierre~Beaurepaire$ 
% $Author:~Edoardo~Patelli$ 

% Retrieve the directory where this tutorial is stored
StutorialPath = fileparts(which(mfilename));
assert(~isempty(StutorialPath),'OpenCossan:Tutorial','The tutorial folder must be contained in the path.')
% Copy the tutorial files in a working directory. The FE input files can be
% written or created in this directory. The directory is on a network
% share, reachable by every cluster machine, and the user has write
% permission on it.
copyfile([StutorialPath '/*'],...
    fullfile(OpenCossan.getCossanWorkingPath,'TutorialWorkingDir'),'f');
%% Create the input

youngs   = RandomVariable('Sdistribution','normal','mean',210e3,'std',10e3);    
shear    = Function('Sexpression','<&youngs&>/2.6');
force    = RandomVariable('Sdistribution','lognormal','mean',10,'std',1.4); 
height   = RandomVariable('Sdistribution','uniform','lowerbound',4,'upperbound',6);    
width    = Parameter('value',8.1);  
max_disp = Parameter('value',0.015); 
inertia2 = Function('Sexpression','<&height&>.^3*<&width&>/12');
inertia1 = Function('Sexpression','<&height&>.*<&width&>.^3/12');
torsion  = Function('Sexpression','<&height&>.*<&width&>.*(<&height&>.^2+<&width&>.^2)/12');
area     = Function('Sexpression','<&width&>.*<&height&>');

Xrvs = RandomVariableSet('Cmembers',{'youngs','force','height'}); 
Xinp = Input('Sdescription','Xinput object',...
    'CXmembers',{Xrvs width inertia1 inertia2 torsion shear area max_disp},...                   % object list
    'CSmembers',{'Xrvs' 'width' 'inertia1' 'inertia2' 'torsion' 'shear' 'area' 'max_disp'});    % name of the objects 


% See summary of the Input
display(Xinp)

%% Create the Injector
% The Injector is created by scanning the .cossan file containing the
% identifiers. A file without identifiers, Abaqus.inp, is created in the
% tutorial working directory.
Sdirectory = fullfile(OpenCossan.getCossanWorkingPath,'TutorialWorkingDir');
Xinjector  = Injector('Stype','scan','SscanFilePath',Sdirectory,...
                     'Sscanfilename','Abaqus.cossan','Sfile','Abaqus.inp');

%% Extractor
% The extractor object is created with one Response. The string specified 
% in Clookoutfor is searched in the ASCII output file Abaqus.dat, then 25
% lines are skipped and the number starting at column 29 is extracted and
% assigned to the output named "disp".
Xresponse = Response('Sname', 'disp', ...
                     'Sfieldformat', '%11e', ...
                     'Clookoutfor',{'   THE FOLLOWING TABLE'}, ...
                     'Ncolnum',29, ...
                     'Nrownum',25 );

Xextractor = Extractor('Srelativepath','./','Sfile','Abaqus.dat','Xresponse', Xresponse);

%% Construct the connector
% A connector using a predefined set of options for Abaqus is created. The
% working directory, that is the directory where the FE solver is executed,
% is set to /tmp. This is done because it is much faster to execute the FE
% solver on a local folder than on a network shared folder.
Xconnector = Connector('SpredefinedType','abaqus',...
               'Smaininputpath',Sdirectory,...
               'Smaininputfile','Abaqus.inp',...
               'CXmembers', {Xinjector Xextractor});

%% Preparation of the Evaluator

Xevaluator = Evaluator('Xconnector',Xconnector);

%% Preparation of the Model

Xmodel = Model('Xinput',Xinp,'Xevaluator',Xevaluator);

% See summary of the Model
display(Xmodel)

Xmodel.deterministicAnalysis
