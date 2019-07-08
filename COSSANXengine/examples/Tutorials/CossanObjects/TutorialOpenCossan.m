%% Tutorial for the OpenCossan object
% The OpenCossan object is use to store all the settings required by the COSSANengine toolbox. 
% 
% See Also: https://cossan.co.uk/wiki/index.php/@CossanX
%
% $Copyright~2006-2018,~COSSAN~Working~Group$
% $Author: Edoardo-Patelli$ 

%% ATTENTION
% the command OpenCossan does not call the display of the object OpenCossan but the
% constructor. This means that calling CossanX without argument the OpenCossan
% object is reinitialized

% Please refer to the Reference Manual to see all the possible input arguments
% of the constructor OpenCossan. 

%% OpenCossan object 
% The object OpenCossan is a handle object stored in a global variable named
% OPENCOSSAN. It is usually initialised automatically at the Matlab start
% up. In order to verify that openCOSSAN has been initialised correctly declare the
% global variable OPENCOSSAN and the display it:

global OPENCOSSAN
assert(~isempty(OPENCOSSAN),'OpenCossan:TutorialOpenCossan',...
    'COSSANengine toolbox not initialised')

display(OPENCOSSAN)

% Now the field name and the property of the object are accessible. For instance
% the field name are:
Sfieldnames=fieldnames(OPENCOSSAN) %#ok<SNASGU>
% The constrains object requires the fields Linequality to define the type
% of constraints.

% We can now see the content of each field, for instance
SmatlabPath=OPENCOSSAN.SmatlabPath %#ok<SNASGU>


%% Using static Method
% The OpenCossan object provides a number of different static methods can be used
% directly without accessing to the global variable. 

% the installation path of the COSSANenginge toolbox can be retrieve using the
% following method OpenCossan.getCossanRoot 

display(OpenCossan.getCossanRoot)

%% Change verbosity level
% store old verbosity level
NoldLevel=OpenCossan.getVerbosityLevel;
OpenCossan.setVerbosityLevel(1);
% The verbosity level is set to 1, minimal output are shown in the
% console. For instance we can see the output of the object OpenCossan
display(OPENCOSSAN)
% Reset verbisity level to 3 (very verbose)
% Change verbosity level
OpenCossan.setVerbosityLevel(3)
display(OPENCOSSAN)

% Restore original Analysis Name
OpenCossan.setVerbosityLevel(NoldLevel);


%% Change Analysis Name
% store old analysis name
Sanalysis=OpenCossan.getAnalysisName;
OpenCossan.setAnalysisName('New Analysis Name');
% Show analysis name
disp(OpenCossan.getAnalysisName)
% Restore original Analysis Name
OpenCossan.setAnalysisName(Sanalysis);

%% Change Working Path
% the working path (i.e. the path where all the outputs are stored) using the
% method OpenCossan.getCossanWorkingPath  

% store old working path
SoldPath=OpenCossan.getCossanWorkingPath;
OpenCossan.setWorkingPath([filesep 'tmp']);
% Show working path
disp(OpenCossan.getCossanWorkingPath)
% Restore original Path
OpenCossan.setWorkingPath(SoldPath);


%% Random Number Generator
% OpenCossan used as default random number generator the Mersenne Twister
% algorithm (mt19937ar). 
% It is possible to re-initialise the random number generator using the static
% method OpenCossan.resetRandomNumberGenerator

OpenCossan.resetRandomNumberGenerator(13314)
% Now we sample using the Matlab function rand
Vsamples1=rand(4,1)
% if we reset the random number generator and then we sample again we obtain the
% same sample values
OpenCossan.resetRandomNumberGenerator(13314)

Vsamples2=rand(4,1)

assert(all(Vsamples1==Vsamples2),'Tutorial:OpenCossan',...
    'RandomNumber Generator not reinitialized')

% To change the random number generator it is necessary first to create a new
% stream (see Matlab documentation for randstream)

%% Set the RandomNumberGenerator
newStream = RandStream('swb2712','Seed',2515);
RandStream.setGlobalStream(newStream);
           
%% Create matlab start up file
% OpenCossan provides a static method to create the matlab startup file the
% automatically initialise the OpenCossan Toolbox at matlab start up.
% The static method OpenCossan.createStartupFile will generate the file for you.
% A backup copy of old startup file is create automatically.


%% Remove OpenCossan toolbox
% The OpenCossan toolbox can be removed from the Matlab path using the static
% method OpenCossan.removePath

