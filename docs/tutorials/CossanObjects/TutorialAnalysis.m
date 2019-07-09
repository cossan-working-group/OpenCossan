% TutorialAnalysis This tutorial shows how to use the Analysis object.
% The Analysis object is use to store all the information required by the
% current analysis. It is an handle object and once created it is added
% automatically to the OpenCossan object.
%
% See also: TutorialAnalysis, OPENCOSSAN,TIMER
%
% For more information, see <a href="https://cossan.co.uk">COSSAN website</a>
% Copyright COSSAN WORKING GROUP 2006-2018

clear;
close all
clc;
% Import the package for a direct access to the Analysis object
import opencossan.common.Analysis

% An empty analysis object is created automatically by the OpenCossan
% object at the first initialisation.
opencossan.OpenCossan.setAnalysis;
% The object can be retrieved using the static method getAnalysis of
% OpenCossan.
XanalysisObj=opencossan.OpenCossan.getAnalysis;
% Show a summary of the object
disp(XanalysisObj)

%% CREATE A NEW ANALYSIS OBJECT
% The information can be retrieve directly from the object or using the
% static method of OpenCossan.getProjectName
disp(opencossan.OpenCossan.getProjectName)

% You can not istantite the object directly. You need to use the method
% getAnalysis of OpenCossan 
% For instance the following call will trigger an error. 
try 
    Analysis('ProjectName','MyProject')
catch ME
    disp(ME.message)
end
%% Get the ANALYSIS object 
MyAnalysis=opencossan.OpenCossan.getAnalysis;
disp(MyAnalysis)
%
% Now it is possible to change the property of the ANALYSIS object.
% Since the Analysis object is an handle object the changes in MyAnalysis
% are reflected immediatly to the object stored by OpenCossan
%
%  A handle is a reference to an object. If you copy an object's handle
%  variable, MATLAB copies only the handle. Both the original and copy
%  refer to the same object.
%
% See also: handle class


MyAnalysis.ProjectName='My First Project';

% Now the ProjectName from OpenCossan is
disp(opencossan.OpenCossan.getProjectName)

% The analysis name can be change using the setAnalysisName method of
% OpenCossan
opencossan.OpenCossan.setProjectName('My Second Project')
% Now the ProjectName from OpenCossan is
disp(opencossan.OpenCossan.getProjectName)

assert(strcmp(opencossan.OpenCossan.getProjectName,'My Second Project'),...
    'TutorialAnalysis:WrongSetProjectName','Wrong Project Name')

% Check handle object
MyAnalysis2=opencossan.OpenCossan.getAnalysis;
disp(MyAnalysis2)
% MyAnalysis and MyAnalysis2 are links to the same object. Hence,
% everychage in one object is shown on the others.
MyAnalysis2.ProjectName='Name Project Assigned to MyAnalysis2';
% The MyAnalysis has now the same ProjectName of MyAnalysis2
disp(MyAnalysis.ProjectName)

assert(strcmp(MyAnalysis2.ProjectName,MyAnalysis.ProjectName),...
    'TutorialAnalysis:WrongAnalysisCopy','Error with handle Analysis object')

%% Change Working Path
% the working path (i.e. the path where all the outputs are stored) using the
% method OpenCossan.getWorkingPath

% store old working path
disp(opencossan.OpenCossan.getWorkingPath)
% or
disp(MyAnalysis.WorkingPath)

%% Random Number Generator
% OpenCossan used as default random number generator the Mersenne Twister
% algorithm (mt19937ar).
% It is possible to re-initialise the random number generator using the static
% method OpenCossan.resetRandomNumberGenerator
Seed=54656;
opencossan.OpenCossan.resetRandomNumberGenerator(Seed)
% Now we sample using the Matlab function rand
Vsamples1=rand(4,1)
% if we reset the random number generator and then we sample again we obtain the
% same sample values
opencossan.OpenCossan.resetRandomNumberGenerator(Seed)
Vsamples2=rand(4,1)

assert(all(Vsamples1==Vsamples2),...
    'TutorialAnalysis:WrongAnalysisCopy',...
    'RandomNumber Generator not reinitialized')

% To change the random number generator it is necessary first to create a new
% stream (see Matlab documentation for randstream)

%% Set the RandomNumberGenerator
newStream = RandStream('swb2712','Seed',2515);
RandStream.setGlobalStream(newStream);
GlobalStream=RandStream.getGlobalStream;

assert(GlobalStream.Seed==2515,... 
    'TutorialAnalysis:GlobalStreamError',...
    'Error initialising Global Stream')

% The random stream can be passed to the Analysis object and it will be
% used as GlobalStream
newStream = RandStream('swb2712','Seed',2555);
MyAnalysis.RandomStream=newStream;
GlobalStreamCossan=RandStream.getGlobalStream;

assert(GlobalStreamCossan.Seed==2555,... 
    'TutorialAnalysis:Analysis:GlobalStreamError',...
    'Error initialising Global Stream in Analysis')