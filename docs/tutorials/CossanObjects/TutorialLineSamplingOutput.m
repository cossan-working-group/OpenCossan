%% Tutorial for the LineSamplingOutput Object
%
% This tutorial shows how to use and construct a LineSamplingOutput object. 
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@LineSamplingOutput
%
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 
clear
close all
clc;

%% Run TutorialLineSampling
% The tutorial of line sampling is used to generate a LineSamplingOutput object
run('TutorialLineSampling')

assert(logical(exist('XlsData','var')), ...
    'openCOSSAN:Tutorials:TutorialLineSamplingOutput','The object XlsData is not available')

%% Display summary
display(XlsData)

%% Plot lines
% The LineSamplingOutput can be used to display the evolution of the performance
% function along the lines,

h1=XlsData.plotLines;
h2=XlsData.plotLines('Ldistance',false);

%% Close figures
close(h1);
close(h2);


%% Create LineSamplinOutput object manually
% It is possible to create LineSamplingOutput invoking the constructor
%´
Xlso1 = LineSamplingOutput('Sperformancefunctionname','Xrv3','Vnumpointline',[2 3]);

display(Xlso1)

Xlso2 = LineSamplingOutput('Sperformancefunctionname','Xrv3','Mnumpointline',[2 3 4 5; 1 2 3 6]);


%% Merge Method
% merging two linesamplingoutput objects

XlsOUT=merge(Xlso1,Xlso2);

display(XlsOUT)
