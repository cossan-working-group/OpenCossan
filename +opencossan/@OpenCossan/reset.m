function reset
%RESET This static method  allows to clean up the workspace without
% reinitilizing OpenCossan.
%
% The method removes all the variables, close all the open files and
% figures and restart the timer object. The RandomStream is not
% reinitialised. Use resetRandomNumberGenerator to reset the random number
% generator.

%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2018 COSSAN WORKING GROUP

OpenCossan is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License or,
(at your option) any later version.

OpenCossan is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

opencossan.OpenCossan.cossanDisp('Clearing workspace,figures, and files...');
evalin('base','clear variables')

%% Close Figures  if is not deployed
if ~isdeployed
    close('all');
end
fclose('all');

%% Reset Timer
opencossan.OpenCossan.getTimer().reset();
opencossan.OpenCossan.getTimer().start('Description','Timer started from OpenCossan');
