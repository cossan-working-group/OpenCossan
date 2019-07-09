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
       % warning('openCOSSAN:GeneticAlgorithm:outputFunction:wrongSflag','Unexpected flag %s',Sflag)
end

%Predefine variables
Mx=Tstate.Population;
% Reset number of iteration
XoptGlobal.Niterations=Tstate.Generation;

VobjFun=Tstate.Score;

if isfield(Tstate,'NonlinEq')
    %Mconstraints=[Tstate.NonlinIneq' Tstate.NonlinEq'];
    Mconstraints=[];
else
    Mconstraints=[];
end

% For adaptive GA it might be necessary to change some options on the fly
Loptchanged=false;

%% Validate inputs
NdesignVariables = size(Mx,2);  % Nmber of design variables
Ncandidates=size(Mx,1);         % Number of candidate solutions
NobjectiveFunctions=size(VobjFun,2); %Number of Objective Functions
NconstraintFunctions=size(Mconstraints,2); %Number of Contraints Functions

assert(size(XoptGlobal.XdesignVariable,2)==NdesignVariables, ...
    'openCOSSAN:Optimum:addIteration:wrongNumberDV',...
    'Number of design Variables %i does not match with the dimension of the Optimum object (%i)', ...
    size(XoptGlobal.XdesignVariable,2),NdesignVariables);

if ~isempty(VobjFun)
    assert(size(VobjFun,1)==Ncandidates,...
        'openCOSSAN:Optimum:addIteration:wrongNumberDV',...
        'Size of Objective Function evaluation (%i) does not match (expected size: %i))', ...
        size(VobjFun,1),Ncandidates);
end


if ~isempty(Mconstraints)
    
    
    assert(size(Mconstraints,1)==Ncandidates,...
        'openCOSSAN:Optimum:addIteration:wrongNumberDV',...
        'Size of Contraints function evaluation (%i) does not match (expected size: %i))', ...
        size(Mconstraints,1),Ncandidates);
end

%% Update Optimum object
% Update DesignVariables
for n = 1:NdesignVariables
    XoptGlobal.XdesignVariable(n)=XoptGlobal.XdesignVariable(n).addData('Vdata',Mx(:,n));
end

% Update ObjectiveFunctions
for n = 1:NobjectiveFunctions
    XoptGlobal.XobjectiveFunction(n)=XoptGlobal.XobjectiveFunction(n).addData('Vdata',VobjFun(:,n));
end

% Update ConstraintFunctions
for n = 1:NconstraintFunctions
    XoptGlobal.Xconstrains(n)=XoptGlobal.Xconstrains(n).addData('Vdata',Mconstraints(:,n));
end

%% Check Optimizer Termination criteria
[~,XoptGlobal.Sexitflag]=XOptimizer.checkTermination(XoptGlobal);

Tstate.StopFlag=XoptGlobal.Sexitflag;

end

