function Lstop = outputFunctionOptimiser(XOptimizer,Vx,ToptimValues,State)
%OUTPUTFUNCTIONOPTIMISET This function is used to intercept the Matlab
%optimization loop at each iteration, check the termination criteria and
%store the results in the Optimum object
%
%  INPUT ARGUMENTS: This function requires 3 inputs
%   * Vx: (vector) point computed by the algorithm at the current
%   iteration of the candidate solution
%   * ToptimValues:  Structure containing the data from the current iteration
%   * State: The current state of the algorithm ('init', 'interrupt',
%   'iter', or 'done')
%
%  OUTPUT ARGUMENT: The output argument is a logical value that tells the
%  optimization function whether the optimization should quit or continue.
%
%  The following examples show typical ways to use
%  the stop flag.
%
% See Also: http://cossan.co.uk/wiki/addIteration@Optimum
% See Also Matlab documentation "optimization-options-reference"
%
% Author: Edoardo Patelli
% Cossan Working Group
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of OpenCossan.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% OpenCossan is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% OpenCossan is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

% Process inputs
global XoptGlobal

switch State
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


% % Disable check of varargin
% Lchecks=OpenCossan.getChecks;
% OpenCossan.setChecks(false);

% %Store iteration number
% XoptGlobal.Niterations=ToptimValues.iteration;
%
% varargIteration=[{'iteration'},{ToptimValues.iteration},...
%                  {'designvariable'},{Vx},...
%                  {'objectivefunction'},{ToptimValues.fval'}];
%
% % if isa(XOptimizer,'MiniMax') || isa(XOptimizer,'Simplex')
% %     MdobjFunGradient=[];
% % else
% %%     Store gradient
% %    varargIteration{end+1}='objectivefunctiongradient';
% %    varargIteration{end+1}=ToptimValues.gradient;
% % end

% %Do not validate the entry since it will be done by the Optimum object
% XoptGlobal=addIteration(XoptGlobal,varargIteration{:});


% Because we are always ahead...
XoptGlobal.Niterations=ToptimValues.iteration+1;

%% Check Optimizer Termination criteria

% Check Optimiser specific termination criteria
switch class(XoptGlobal.XOptimizer)
    case {'StochasticRanking'}
        OpenCossan.cossanDisp(['Iteration #' num2str(ToptimValues.iteration)],3)
        % Check tolerance Objective Function
        if ~isempty(XOptimizer.toleranceObjectiveFunction) && XoptGlobal.Niterations>0
            if ToptimValues.deltaObjFun<XOptimizer.toleranceObjectiveFunction  %in case convergence criterion has been achieved
                Lstop=true;
                XoptGlobal.Sexitflag = ['deltaObjectiveFunction termination criteria archived (' ... 
                    num2str(ToptimValues.deltaObjFun) ')'];
                return
            end
        end
        
        %check tolerance Design Variable
        if ~isempty(XOptimizer.toleranceDesignVariables) && XoptGlobal.Niterations>0
            if ToptimValues.deltaDV<XOptimizer.toleranceDesignVariables  %in case convergence criterion has been achieved
                XoptGlobal.Sexitflag = ['Termination criteria for the Design Variable archived (' ...
                    num2str(ToptimValues.deltaDV) ')'];
                Lstop=true;
                return
            end
        end
    otherwise
end

% Check global termination criteria
[Lstop,XoptGlobal.Sexitflag]=XOptimizer.checkTermination(XoptGlobal);

% % Restore condition of OpenCossan
% OpenCossan.setChecks(Lchecks);
end

