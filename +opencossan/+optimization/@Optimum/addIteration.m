function [Xobj] = addIteration(Xobj,varargin)
%ADDITERATION This function add a new iteration to the Optimum object
%   This function is used to store a new iteration of the Optimization
%   Process in the Optimum object.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/addIteration@Optimum
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
OpenCossan.validateCossanInputs(varargin{:})

%Predefine variables
Mx=[];
MobjFun=[];
MdobjFunGradient=[];
Mconstraints=[];
MdconstraintGradients=[];
iteration=Xobj.Niterations;
    
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'iteration','niteration'}
            iteration=varargin{k+1};
        case 'mdesignvariables'
            Mx=varargin{k+1};
        case 'mobjectivefunction'
            MobjFun=varargin{k+1};
        case 'mobjectivefunctiongradient'
            MdobjFunGradient=varargin{k+1};
        case 'mconstraintfunction'
            Mconstraints=varargin{k+1};
        case 'mconstraintfunctiongradient'
            MdconstraintGradients=varargin{k+1};
        otherwise
            error('openCOSSAN:Optimum:addIteration:wrongInputArgument',...
                'PropertyName %s not valid', varargin{k});
    end
end

% assert(logical(exist('Mx','var')),'openCOSSAN:Optimum:addIteration:noDesignVariables',...
%     'It is not possible to add a new iteration without providing a new set of candidate solutions');

%% Validate inputs
NdesignVariables = size(Mx,2);  % Nmber of design variables
Ncandidates=size(Mx,1);         % Number of candidate solutions
NobjectiveFunctions=size(MobjFun,2); %Number of Objective Functions
NconstraintFunctions=size(Mconstraints,2); %Number of Contraints Functions

%% Update Optimum object
if ~isempty(Mx)
    assert(size(Xobj.XdesignVariable,2)==NdesignVariables, ...
        'openCOSSAN:Optimum:addIteration:wrongNumberDV',...
        'Number of design Variables %i does not match with the dimension of the Optimum object (%i)', ...
        size(Xobj.XdesignVariable,2),NdesignVariables);
        OpenCossan.cossanDisp(['[openCOSSAN:Optimum:addIteration] * Iteration #' num2str(Xobj.Niterations)],3)
end

if ~isempty(MobjFun)
    assert(size(MobjFun,1)==Ncandidates,...
        'openCOSSAN:Optimum:addIteration:wrongNumberDV',...
        'Size of Objective Function evaluation (%i) does not match (expected size: %i))', ...
        size(MobjFun,1),Ncandidates);
end
if ~isempty(MdobjFunGradient)
    assert(all(size(MdobjFunGradient)==[size(Xobj.XdesignVariable,2),NobjectiveFunctions]),...
        'openCOSSAN:Optimum:addIteration:wrongSizeGradientObjectiveFunction',...
        'VobjectiveFunctionGradient requires (%i %i) values. Current values: %i %i', ...
        size(MdobjFunGradient,1),size(MdobjFunGradient,2),size(Xobj.XdesignVariable,2),NobjectiveFunctions);
end

if ~isempty(Mconstraints)
    assert(NconstraintFunctions==size(Xobj.Xconstrains,2),...
        'openCOSSAN:Optimum:addIteration:wrongNumberContraints',...
        'Size of Contraints function evaluation (%i) does not match (expected size: %i))', ...
        NconstraintFunctions,size(Xobj.Xconstrains,2));
end

if ~isempty(MdconstraintGradients)
    assert(all(size(MdconstraintGradients)==[size(Xobj.XdesignVariable,2),NconstraintFunctions]),...
        'openCOSSAN:Optimum:addIteration:wrongSizeGradientObjectiveFunction',...
        'VobjectiveFunctionGradient requires (%i %i) values. Current values: %i %i', ...
        size(MdconstraintGradients,1),size(MdconstraintGradients,2),size(Xobj.XdesignVariable,2),NconstraintFunctions);
end



% Update DesignVariables
for n = 1:NdesignVariables
    Xobj.XdesignVariable(n)=Xobj.XdesignVariable(n).addData('Mcoord',iteration,'Vdata',Mx(:,n));
end

% Update ObjectiveFunctions
for n = 1:NobjectiveFunctions
    Xobj.XobjectiveFunction(n)=Xobj.XobjectiveFunction(n).addData('Mcoord',iteration,'Vdata',MobjFun(:,n));
end

% Update ObjectiveFunctionGradients
if ~isempty(MdobjFunGradient)
    for n = 1:NobjectiveFunctions
        Xobj.XobjectiveFunctionGradient(n)=Xobj.XobjectiveFunctionGradient(n).addData('Mcoord',iteration,'Vdata',MdobjFunGradient(:,n));
    end
end

% Update ConstraintFunctions
for n = 1:NconstraintFunctions
    Xobj.Xconstrains(n)=Xobj.Xconstrains(n).addData('Mcoord',iteration,'Vdata',Mconstraints(:,n));
end

% Update ContraintFunctionGradients
if ~isempty(MdconstraintGradients)
    for n = 1:NconstraintFunctions
        Xobj.XconstrainsGradient(n)=Xobj.XconstrainsGradient(n).addData('Mcoord',iteration,'Vdata',MdconstraintGradients(:,n));
    end
end


%% Add checks



end

