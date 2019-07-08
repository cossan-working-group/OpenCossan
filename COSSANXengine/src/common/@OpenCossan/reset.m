function reset
%RESET This static method allows to clean up the workspace without
% reinitilizing OpenCossan.
% The method removes all the variables, close all the open files and
% figures, restart the timer object but not the RandomStream. 
% Use resetRandomNumberGenerator to reset the RandomStream.
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

global OPENCOSSAN
% Remove variable
evalin('base','clear variables')

%% Close Figures  if is not deployed
if ~isdeployed
    if OPENCOSSAN.NverboseLevel>1
        fprintf('Closing Figure(s): ')
    end
    Lstatus=close('all');
    
    if OPENCOSSAN.NverboseLevel>1
        if Lstatus
            fprintf('DONE! \n')
        else
            fprintf('FAILED! \n')
        end
    end
end

%% Close Files
if OPENCOSSAN.NverboseLevel>1
    fprintf('Closing File(s)  : ')
end

Lstatus=fclose('all');

if OPENCOSSAN.NverboseLevel>1
    if Lstatus==-1
        fprintf('FAILED! \n')
    else
        fprintf('DONE! \n')
    end
end

%% Reset Timer
OPENCOSSAN.Xanalysis.Xtimer.reset;
OPENCOSSAN.Xanalysis.Xtimer.starttime('Sdescription','Start timer from the OpenCossan');
