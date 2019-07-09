function [Lstop,Sexitflag] = outputFunction(XOptimizer,Tstate)
%OUTPUTFUNCTION  This function is a private functionused to store the
%output at each iteration and check the termination criteria
%
%  INPUT ARGUMENTS:
%   * Tstate — Structure containing information about the current generation. The State Structure describes the fields of state.
%
%  OUTPUT ARGUMENT: The output argument stop is a flag that is true or
%  false. The flag tells the optimization function whether the optimization
%  should quit or continue. The following examples show typical ways to use
%  the stop flag.
%   Lstop — Flag indicates that status of the optimization
%   Sexitflag - exit flag
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

%% Validate inputs
NdesignVariables = size(Tstate.Mx,2);  % Nmber of design variables
Ncandidates=size(Tstate.Mx,1);         % Number of candidate solutions
NobjectiveFunctions=size(Tstate.MobjFun,2); %Number of Objective Functions
NconstraintFunctions=size(Tstate.Mconstraints,2); %Number of Contraints Functions

assert(size(XoptGlobal.XdesignVariable,2)==NdesignVariables, ...
    'openCOSSAN:Optimum:addIteration:wrongNumberDV',...
    'Number of design Variables %i does not match with the dimension of the Optimum object (%i)', ...
    size(XoptGlobal.XdesignVariable,2),NdesignVariables);

assert(size(Tstate.MobjFun,1)==Ncandidates,...
    'openCOSSAN:StochasticRanking:outputFunction:wrongNumberObjFunSamples',...
    'Size of Objective Function evaluation (%i) does not match (expected size: %i))', ...
    size(Tstate.MobjFun,1),Ncandidates);

assert(NobjectiveFunctions==size(XoptGlobal.XobjectiveFunction,2),...
    'openCOSSAN:StochasticRanking:outputFunction:wrongNumberObjFun',...
    'Size of Objective Function evaluation (%i) does not match (expected size: %i))', ...
    NobjectiveFunctions,size(XoptGlobal.XobjectiveFunction,2));

if ~isempty(Tstate.Mconstraints)
    assert(size(Tstate.Mconstraints,1)==Ncandidates,...
        'openCOSSAN:StochasticRanking:outputFunction:wrongNumberContraintsSamples',...
        'Size of Contraints function evaluation (%i) does not match (expected size: %i))', ...
        size(Tstate.Mconstraints,1),Ncandidates);
    assert(NconstraintFunctions==size(XoptGlobal.Xconstrains,2),...
        'openCOSSAN:StochasticRanking:outputFunction:wrongNumberContraintsFunction',...
        'Size of Contraints function evaluation (%i) does not match (expected size: %i))', ...
        NconstraintFunctions,size(XoptGlobal.Xconstrains,2));
end

%% Update Optimum object
XoptGlobal.Niterations=Tstate.Niteration;

%% Output
OpenCossan.cossanDisp(['[Status] Iteration #' num2str(XoptGlobal.Niterations)],2)

% Update DesignVariables
for n = 1:NdesignVariables
    XoptGlobal.XdesignVariable(n)=XoptGlobal.XdesignVariable(n).addData('Vdata',Tstate.Mx(:,n));
end

% Update ObjectiveFunctions
for n = 1:NobjectiveFunctions
    XoptGlobal.XobjectiveFunction(n)=XoptGlobal.XobjectiveFunction(n).addData('Vdata',Tstate.MobjFun(:,n));
end

% Update ConstraintFunctions
for n = 1:NconstraintFunctions
    XoptGlobal.Xconstrains(n)=XoptGlobal.Xconstrains(n).addData('Vdata',Tstate.Mconstraints(:,n));
end

%% check object specific termination criteria
% Check tolerance Objective Function
if ~isempty(XOptimizer.toleranceObjectiveFunction) && XoptGlobal.Niterations>0
    if Tstate.deltaObjFun<XOptimizer.toleranceObjectiveFunction  %in case convergence criterion has been achieved
        Lstop=true;
        Sexitflag    = ['deltaObjectiveFunction termination criteria archived (' num2str(Tstate.deltaObjFun) ')'];
        return
    end
end

%check tolerance Design Variable
if ~isempty(XOptimizer.toleranceDesignVariables) && XoptGlobal.Niterations>0
    if Tstate.deltaDV<XOptimizer.toleranceDesignVariables  %in case convergence criterion has been achieved
        Sexitflag    = ['Termination criteria for the Design Variable archived (' num2str(deltaDV) ')'];
        Lstop=true;
        return
    end
end

[Lstop,Sexitflag]=XOptimizer.checkTermination(XoptGlobal);


end

