%% Tutorial Beam 3-point bending (FEAP)
% This example considers a beam in three points bending. It will be studied 
% using feap and various toolboxes from COSSAN-X.
% 
% Then simulation analysis is performed to investigate the effects of the
% uncertainties on the mid-span displacement. 
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/Beam_3-point_bending_(overview)
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Pierre~Beaurepaire$ 

% Retrieve the directory where this tutorial is stored
StutorialPath = fileparts(which(mfilename));
assert(~isempty(StutorialPath),'openCOSSAN:Tutorial','The tutorial folder must be contained in the path.')
% Copy the files that required to be writted ans modified in a working directory. 
% The FE input files can be written or created in this directory. The directory is on a network
% share, reachable by every cluster machine, and the user has write
% permission on it.

SexecutionFolder=fullfile(OpenCossan.getCossanWorkingPath,'TutorialWorkingDir');
mkdir(SexecutionFolder);

copyfile([StutorialPath filesep 'BeamFeap' filesep '*'],SexecutionFolder,'f');


%% Prepare input objects

youngs   = RandomVariable('Sdistribution','normal','mean',210e3,'std',10e3);    
force    = RandomVariable('Sdistribution','lognormal','mean',10,'std',1.4); 
height   = RandomVariable('Sdistribution','uniform','lowerbound',4,'upperbound',6);    
width    = Parameter('value',8.1);  
max_disp = Parameter('value',0.015); 
inertia  = Function('Sexpression','<&width&>.*<&height&>.^3/12');

Xrvs = RandomVariableSet('Cmembers',{'youngs','force','height'}); 
Xinp = Input('Sdescription','Xinput object',...
    'CXmembers',{Xrvs width inertia  max_disp},...                   % object list
    'CSmembers',{'Xrvs' 'width' 'inertia'  'max_disp'});    % name of the objects 

% See summary of the Input
display(Xinp)

%% Create the Injector

Sdirectory = fullfile(OpenCossan.getCossanWorkingPath,'TutorialWorkingDir');
Xinjector  = Injector('Stype','scan','SscanFilePath',Sdirectory,...
                     'Sscanfilename','Feap.cossan','Sfile','Feap');

%% Construct the connector    
Xconnector=Connector('SpredefinedType','Feap',...
                    'Smaininputpath',Sdirectory,... 
                    'Smaininputfile','Feap','Soutputfile','FeapOut.txt', ...
                 'CSadditionalfiles',{'FeapElement.txt' 'FeapNode.txt'});

Xconnector = add(Xconnector,Xinjector);   

%% Test the connector 
% The connector can be testet performing a deterministic analysis.
% This methods allows to create the output files of the solver required to
% define the so-called extractor.

Xconnector.deterministicAnalysis

%% Extractor
% Now we have the output file, please redefine the extractor
Xresponse = Response('Sname', 'disp', ...
                     'Sfieldformat', '%12e', ...
                     'Ncolnum',13, ...
                     'Nrownum',1);

Xextractor = Extractor('Srelativepath','./','Sfile','Peapa.dis','Xresponse', Xresponse);
        
           
% Add injector and extractor
Xconnector = add(Xconnector,Xinjector);
Xconnector = add(Xconnector,Xextractor);

%% Preparation of the Evaluator

Xevaluator = Evaluator('Xconnector',Xconnector);

%% Preparation of the Model

Xmodel = Model('Xinput',Xinp,'Xevaluator',Xevaluator);

% See summary of the Model
display(Xmodel)

