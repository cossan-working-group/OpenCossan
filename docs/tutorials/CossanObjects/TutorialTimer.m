%% Tutorial for the Timer object
% The Timer object is use to monitor the computational time of different
% algorithm.
%
% It is mainly used by the Simulation and Optimization methods for the
% time based termination criteria.
%
% The timer object is stored in the OpenCossan object and accessible
% directly by means of different static method of OpenCossan.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Timer
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@OpenCossan
%
% Author: Edoardo Patelli
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================
close all
clear
clc;
%% The Timer object is used to
% The timer object is used to monitor all the analysis in OpenCossan.
% It is accessible via the object Analysis. 
%
% NOTE: The timer object is an handle object! 

%% Reset Timer
% The timer can be reset via the static method "reset" of OpenCossan
opencossan.OpenCossan.reset
% The static method getTimer allows to access the Timer
opencossan.OpenCossan.getTimer
... opencossan.OpenCossan.setLaptime

%% Get the Timer object
% A timer object can be retrieved via the Analysis object
Xanalysis=opencossan.OpenCossan.getAnalysis;
% The timer is self is 
Xanalysis.Xtimer

% Reset timer
Xanalysis.Xtimer.reset
display(Xanalysis.Xtimer)

% Get total time of the analyis
Xanalysis.Xtimer.totalTime
pause(1)
% The total time does not change because the Timer is not running
Xanalysis.Xtimer.totalTime


% start the total time of the analyis
Xanalysis.Xtimer.starttime
Xanalysis.Xtimer.totalTime
pause(1)
Xanalysis.Xtimer.totalTime

% It is possible to assign labels to the Timer
Xanalysis.Xtimer.starttime('Sdescription','MyLabel 1')
pause(1)
Xanalysis.Xtimer.starttime('Sdescription','MyLabel 2')
display(Xanalysis.Xtimer)

%% Get the lap time 
% returns the time elapsed from previous counter and start a new counter

counterID=laptime(Xanalysis.Xtimer,'Sdescription','MyLabel 3');
display(Xanalysis.Xtimer)

%% Get enlapsed time between two counters

Xanalysis.Xtimer.deltatime(counterID-1,counterID)
display(Xanalysis.Xtimer)

counterID2=laptime(Xanalysis.Xtimer,'Sdescription','MyLabel 4');
Xanalysis.Xtimer.deltatime(counterID,counterID2)
display(Xanalysis.Xtimer)

            % The method returns as optional output argument the number of
            % the new counter started
            
%% Plot time
SfigureName='PlotTimer';
Sformat='pdf';
Xanalysis.Xtimer.plot('SfigureName',SfigureName,'Stitle','Tutorial Timer','SexportFormat',Sformat)
% The figure is export in the Cossan working directory

assert (logical(exist(fullfile(OpenCossan.getCossanWorkingPath,[SfigureName '.' Sformat]),'file')),...
    'OpenCossan:Tutorial:TutorialTimer:nofigurecreated','Figure Not created')

% remove created file
delete(fullfile(OpenCossan.getCossanWorkingPath,[SfigureName '.' Sformat]))

