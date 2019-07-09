%% Tutorial for the OpenCossan object
% The OpenCossan object is use to store all the settings required by the
% OpenCossan toolbox. 
% 
% See Also: https://cossan.co.uk/wiki/index.php/@OpenCossan
%
% $Copyright~1993-2017,~COSSAN~Working~Group$
% $https://cossan.co.uk/wiki/index.php/@CossanX$
% $Author: Edoardo-Patelli$ 
clear
close all
clc;
%% ATTENTION
% the command OpenCossan does not call the display of the object OpenCossan
% but the constructor. This means that calling OpenCossan without argument
% the OpenCossan object is reinitialized

% Please refer to the Reference Manual to see all the possible input arguments
% of the constructor OpenCossan. 

%% OpenCossan object 
% The object OpenCossan is a handle object stored in a global variable named
% OpenCossan. It is usually initialised automatically at the Matlab
% start-up. In order to verify that OpenCossan has been initialised
% correctly declare the  global variable OPENCOSSAN and the display it:

global OPENCOSSAN
assert(~isempty(OPENCOSSAN),'OpenCossan:TutorialOpenCossan','OpenCossan toolbox not initialised') 

display(OPENCOSSAN)

% Now the field name and the property of the object are accessible. For instance
% the field name are:
Sfieldnames=fieldnames(OPENCOSSAN)  %#ok<NOPTS>
% The constrains object requires the fields Linequality to define the type
% of constraints.

% We can now see the content of each field, for instance
SmatlabPath=OPENCOSSAN.MatlabPath %#ok<NOPTS>


%% Using static Method
% The OpenCossan object provides a number of different static methods can be used
% directly without accessing to the global variable. 

% The installation path of the OpenCossan toolbox can be retrieve using the
% following method opencossan.OpenCossan.getCossanRoot 

display(opencossan.OpenCossan.getCossanRoot)

%% Change verbosity level
% store old verbosity level
NoldLevel=opencossan.OpenCossan.getVerbosityLevel;
opencossan.OpenCossan.setVerbosityLevel(1);
% The verbosity level is set to 1, minimal output are shown in the
% console. For instance we can see the output of the object OpenCossan
display(OPENCOSSAN)

% If the verbosity level is set to 0, no output are shown in the
% console.
opencossan.OpenCossan.setVerbosityLevel(0);
display(OPENCOSSAN)

% Reset verbisity level to 3 (very verbose)
% Change verbosity level
opencossan.OpenCossan.setVerbosityLevel(3)
display(OPENCOSSAN)

% Restore original Analysis Name
OpenCossan.setVerbosityLevel(NoldLevel);


           
%% Create matlab start up file
% CossanX provides a static method to create the matlab startup file the
% automatically initialise the Cossan Engine Toolbox at matlab start up.
% The static method OpenCossan.createStartupFile will generate the file for you.
% A backup copy of old startup file is create automatically.


%% Remove CossanX toolbox
% The CossanX toolbox can be removed from the Matlab path using the static
% method OpenCossan.removePath

