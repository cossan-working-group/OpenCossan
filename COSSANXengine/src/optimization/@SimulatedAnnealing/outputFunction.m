function[Lstop,Toptions,Loptchanged] = outputFunction(XOptimizer,Toptions,ToptimValues,Sflag)
%OUTPUTFUNCTIONOPTIMISET This function is used to intercept the Matlab
%optimization loop at each iteration and check the termination criteria and
%store results on the Optimum object
%
%  INPUT ARGUMENTS: 
%   * Toptions — Options structure
%   * Toptimvalues — Structure containing information about the current generation. 
%   * Sflag: The current state of the algorithm ('init', 'interrupt',
%   'iter', or 'done')
%
%  OUTPUT ARGUMENT: The output argument stop is a flag that is true or
%  false. The flag tells the optimization function whether the optimization
%  should quit or continue. The following examples show typical ways to use
%  the stop flag.
%   Tstate — Structure containing information about the current generation.
%   The State Structure describes the fields of state. To stop the
%   iterations, set state.StopFlag to a nonempty string.  
%   Toptions — Options structure modified by the output function. This argument is optional.
%   Loptchanged — Flag indicating changes to options
%
% See Also: https://cossan.co.uk/wiki/addIteration@Optimum
% See Also Matlab documentation "optimization-options-reference"
%
% Author: Edoardo Patelli
% Website: http://www.cossan.co.uk

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
% Process inputs
global XoptGlobal

switch Sflag
    case 'init'
        % Initialize Optimum
        disp('Start optimization process')
        XOptimizer.initialLaptime=OpenCossan.setLaptime('Sdescription','Start optimization process');
    case {'iter' 'interrupt'}
        OpenCossan.setLaptime('Sdescription',['Iteration #' num2str(ToptimValues.iteration)]);
        % Concatenate current point and objective function
    case 'done'        
        OpenCossan.setLaptime('Sdescription','End optimization');
        XoptGlobal.totalTime=OpenCossan.getDeltaTime(XOptimizer.initialLaptime);

    otherwise
        disp('State flag not recognised')
        disp(State)
end

%Predefine variables
Loptchanged=false;

% Because we are always ahead... 
XoptGlobal.Niterations=ToptimValues.iteration+1;

%% Check Optimizer Termination criteria
[Lstop,XoptGlobal.Sexitflag]=XOptimizer.checkTermination(XoptGlobal);

end

