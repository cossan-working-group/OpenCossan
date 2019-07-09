function Lstop = outputFunctionOptimiser(XOptimizer,Vx,ToptimValues,State)
%OUTPUTFUNCTIONOPTIMISET This function is used to intercept the Matlab
%optimization loop at each iteration and check the termination criteria and
%store results on the Optimum object
%
%  INPUT ARGUMENTS: This function requires 3 inputs
%   * Vx: (vector) point computed by the algorithm at the current
%   iteration of candidate solution
%   * ToptimValues:  Structure containing data from the current iteration
%   * State: The current state of the algorithm ('init', 'interrupt',
%   'iter', or 'done')
%
%  OUTPUT ARGUMENT: The output argument stop is a flag that is true or
%  false. The flag tells the optimization function whether the optimization
%  should quit or continue. The following examples show typical ways to use
%  the stop flag.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/addIteration@Optimum
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

switch State
    case 'init'
        % Initialize Optimum
        %XOptimizer.initialLaptime=OpenCossan.setLaptime('description','Start optimization process');
        %XOptimizer.Niterations=0;
    case 'iter'
        %OpenCossan.setLaptime('description',['Iteration #' num2str(ToptimValues.iteration)]);
        %XOptimizer.Niterations=0;
        % Concatenate current point and objective function
    case 'done'        
        OpenCossan.setLaptime('description','End optimization');
        XoptGlobal.totalTime=OpenCossan.getDeltaTime(XOptimizer.initialLaptime);
    otherwise
end

% Store iteration number
XoptGlobal.Niterations=ToptimValues.iteration;

VobjFun=ToptimValues.fval;

if isa(XOptimizer,'opencossan.optimization.MiniMax')
    MdobjFunGradient=[];
elseif isa(XOptimizer,'opencossan.optimization.Simplex')
    MdobjFunGradient=[];
else
    MdobjFunGradient=ToptimValues.gradient;
end
Mconstraints=[];
MdconstraintGradients=[];


%% Validate inputs
NdesignVariables = length(Vx);  % Nmber of design variables
NobjectiveFunctions=length(VobjFun); %Number of Objective Functions
NconstraintFunctions=size(Mconstraints,2); %Number of Contraints Functions

assert(size(XoptGlobal.XdesignVariable,2)==NdesignVariables, ...
    'openCOSSAN:Optimum:addIteration:wrongNumberDV',...
    'Number of design Variables %i does not match with the dimension of the Optimum object (%i)', ...
    size(XoptGlobal.XdesignVariable,2),NdesignVariables);

if ~isempty(VobjFun)
    assert(size(XoptGlobal.XobjectiveFunction,2)==NobjectiveFunctions,...
        'openCOSSAN:Optimum:addIteration:wrongNumberObjFun',...
        'Size of Objective Function evaluation (%i) does not match (expected size: %i))', ...
        NobjectiveFunctions,size(XoptGlobal.XobjectiveFunction,2));
end
if ~isempty(MdobjFunGradient)
    assert(all(size(MdobjFunGradient)==[NdesignVariables,NobjectiveFunctions]),...
        'openCOSSAN:Optimum:addIteration:wrongSizeGradientObjectiveFunction',...
        'VobjectiveFunctionGradient requires (%i %i) values. Current values: %i %i', ...
        size(MdobjFunGradient),NdesignVariables,NobjectiveFunctions);
end

if ~isempty(Mconstraints)
    assert(size(XoptGlobal.Xconstrains,2)==NconstraintFunctions,...
        'openCOSSAN:Optimum:addIteration:wrongNumberDV',...
        'Size of Contraints function evaluation (%i) does not match (expected size: %i))', ...
        NconstraintFunctions,size(XoptGlobal.Xconstrains,2));
end

if ~isempty(MdconstraintGradients)
    assert(all(size(MdconstraintGradients)==[NdesignVariables,NconstraintFunctions]),...
        'openCOSSAN:Optimum:addIteration:wrongSizeGradientObjectiveFunction',...
        'VobjectiveFunctionGradient requires (%i %i) values. Current values: %i %i', ...
        size(MdconstraintGradients),NdesignVariables,NconstraintFunctions);
end

%% Update Optimum object
% Update DesignVariables
for n = 1:NdesignVariables
    XoptGlobal.XdesignVariable(n)=XoptGlobal.XdesignVariable(n).addData('Mcoord',ToptimValues.iteration,'Vdata',Vx(:,n));
end

% Update ObjectiveFunctions
for n = 1:NobjectiveFunctions
    XoptGlobal.XobjectiveFunction(n)=XoptGlobal.XobjectiveFunction(n).addData('Mcoord',ToptimValues.iteration,'Vdata',VobjFun(:,n));
end

% Update ObjectiveFunctionGradients
if ~isempty(MdobjFunGradient)
    for n = 1:NobjectiveFunctions
        XoptGlobal.XobjectiveFunctionGradient(n)=XoptGlobal.XobjectiveFunctionGradient(n).addData('Mcoord',ToptimValues.iteration,'Vdata',MdobjFunGradient(:,n));
    end
end

% Update ConstraintFunctions
for n = 1:NconstraintFunctions
    XoptGlobal.Xconstrains(n)=XoptGlobal.Xconstrains(n).addData('Mcoord',ToptimValues.iteration,'Vdata',Mconstraints(:,n));
end

% Update ContraintFunctionGradients
if ~isempty(MdconstraintGradients)
    for n = 1:NconstraintFunctions
        XoptGlobal.XconstrainsGradient(n)=XoptGlobal.XconstrainsGradient(n).addData('Mcoord',ToptimValues.iteration,'Vdata',MdconstraintGradients(:,n));
    end
end


%% Check Optimizer Termination criteria
[Lstop,XoptGlobal.Sexitflag]=XOptimizer.checkTermination(XoptGlobal);

end

