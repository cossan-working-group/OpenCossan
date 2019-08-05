function [Tstate,Toptions,Loptchanged] = outputFunction(XOptimizer,Toptions,Tstate,Sflag)
%OUTPUTFUNCTIONOPTIMISET This function is used to intercept the Matlab
%optimization loop at each iteration and check the termination criteria and
%store results on the Optimum object
%
%  INPUT ARGUMENTS: 
%   * Toptions — Options structure
%   * Tstate — Structure containing information about the current generation. The State Structure describes the fields of state.
%   * Sflag: The current state of the algorithm ('init', 'interrupt',
%   'iter', or 'done')
%
%  OUTPUT ARGUMENTS: 
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

% Process inputs
global XoptGlobal

switch Sflag
    case 'init'
        opencossan.OpenCossan.cossanDisp('Start optimization process',3)
    case {'iter','interrupt'}
        opencossan.OpenCossan.cossanDisp(['Iteration #' num2str(Tstate.Generation)],3)
    case 'done'        
        opencossan.OpenCossan.getTimer().lap('Description','End optimization');
        XoptGlobal.totalTime=opencossan.OpenCossan.getTimer().delta(XOptimizer.InitialLapTime);
    otherwise
        warning('OpenCossan:GeneticAlgorithm:outputFunction:wrongSflag',...
            'Unexpected flag %s',Sflag)
end

% Store iteration number
% XoptGlobal.Niterations=Tstate.Generation;


if isfield(Tstate,'NonlinEq')
    %Mconstraints=[Tstate.NonlinIneq' Tstate.NonlinEq'];
    Mconstraints=[];
else
    Mconstraints=[];
end

% For adaptive GA it might be necessary to change some options on the fly
Loptchanged=false;

varargIteration=[{'iteration'},{repmat(Tstate.Generation,size(Tstate.Population,1),1)},...
                 {'designvariable'},{Tstate.Population},...
                 {'objectivefunction'},{Tstate.Score}];


if XoptGlobal.XOptimizationProblem.NumberOfConstraints > 0
   % Store constraint
   varargIteration{end+1}='constraintfunction'; 
   varargIteration{end+1}=Mconstraints; 
end

% Do not validate the entry since it will be done by the Optimum object
% XoptGlobal=addIteration(XoptGlobal,varargIteration{:});

%% Check Optimizer Termination criteria
[Tstate.Lstop,XoptGlobal.Sexitflag]=XOptimizer.checkTermination(XoptGlobal);

end

