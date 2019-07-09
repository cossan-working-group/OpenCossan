function[Lstop,Toptions,Loptchanged] = outputFunction(XOptimizer,Toptions,Toptimvalues,Sflag)

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

switch Sflag
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

%Predefine variables
Loptchanged=false;

Mx=Toptimvalues.x;
% Reset number of iteration
XoptGlobal.Niterations=Toptimvalues.iteration;

VobjFun=Toptimvalues.fval;

%% Validate inputs
NdesignVariables = size(Mx,2);  % Nmber of design variables
NobjectiveFunctions=size(VobjFun,2); %Number of Objective Functions

assert(size(XoptGlobal.XdesignVariable,2)==NdesignVariables, ...
    'openCOSSAN:Optimum:addIteration:wrongNumberDV',...
    'Number of design Variables %i does not match with the dimension of the Optimum object (%i)', ...
    size(XoptGlobal.XdesignVariable,2),NdesignVariables);


%% Update Optimum object
% Update DesignVariables
for n = 1:NdesignVariables
    XoptGlobal.XdesignVariable(n)=XoptGlobal.XdesignVariable(n).addData('Vdata',Mx(:,n));
end

% Update ObjectiveFunctions
for n = 1:NobjectiveFunctions
    XoptGlobal.XobjectiveFunction(n)=XoptGlobal.XobjectiveFunction(n).addData('Vdata',VobjFun(:,n));
end

%% Check Optimizer Termination criteria
[Lstop,XoptGlobal.Sexitflag]=XOptimizer.checkTermination(XoptGlobal);

Toptions.StopFlag=XoptGlobal.Sexitflag;

end

