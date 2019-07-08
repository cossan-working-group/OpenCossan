%% Tutorial for the LineSamplingOutput Object
%
% This tutorial shows how to use and construct a LineSamplingOutput object. 
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@LineSamplingOutput
%
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 


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
% It is possible to create LineSamplingOutput by invoking the constructor

Xlso1 = LineSamplingOutput('SperformanceFunctionName','Xrv3','VnumPointLine',[1 3 5]);
display(Xlso1)

Xlso2 = LineSamplingOutput('SperformanceFunctionName','Xrv3','VnumPointLine',[2 4 6]);
display(Xlso2)

%% Merge Method
% merging two linesamplingoutput objects

XlsOUT=merge(Xlso1,Xlso2);
display(XlsOUT)
