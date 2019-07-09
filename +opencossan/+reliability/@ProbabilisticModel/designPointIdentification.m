function [Xdp,Xopt] = designPointIdentification(Xpm,varargin)
% Design Point Search of a Limit State Function.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/DesignPointIdentification@ProbabilisticModel
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


%%  Initialize variables
Mu0         = [];       % define empty variable to store initial solution

%% Process inputs
opencossan.OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xoptim','xoptimizer','cxoptimizer'}
            if iscell(varargin{k+1})
                Xoptim  = varargin{k+1}{1};
            else
                Xoptim  = varargin{k+1};
            end
            mc=metaclass(Xoptim);
            assert(strcmp(mc.SuperClasses{1}.Name,'opencossan.optimization.Optimizer'),...
                'openCOSSAN:reliability:ProbabilisticModel:designPointIdentification', ...
                ['An optimizer object is required, object provided of type ' mc.SuperClasses{1}.Name ])
        case {'mreferencepoints','vinitialsolution'}
            VuUnsorted     = Xpm.Xmodel.Xinput.map2stdnorm(varargin{k+1});
        case {'csnamerandomvariables'}
            CnamesRandomVariablesInitialSolution =  varargin{k+1};
        case {'vinitialsolutionstandardnormalspace'}
            VuUnsorted     = varargin{k+1};
        case {'lfinitedifferences'}
            LfiniteDifferences  = varargin{k+1}; %#ok<NASGU> Used by HLRF
        case {'tolerancedesignpoint'}
            toleranceDesignPoint= varargin{k+1}; %#ok<NASGU> Used by HLRF
        case {'valpha'}
            Valpha= varargin{k+1}; %#ok<NASGU> Used by HLRF
        case {'nmaxiterations','nmaxiteration'}
            Nmaxiteration= varargin{k+1}; %#ok<NASGU> Used by HLRF
        otherwise
            error('openCOSSAN:ProbabilisticModel:designPointIdentification',...
                'PropertyName %s is not valid', varargin{k})
    end
end

if ~exist('Xoptim','var')
    % Use the HLRF approach
    [Xdp,Xopt] = HLRF(Xpm,varargin{:});    
else    
    Cmembers=Xpm.Xinput.CnamesRandomVariable;
    NPopulationSize=1;
    
    %% Reorder the initial solution
    if exist('VuUnsorted','var')
        assert(logical(exist('CnamesRandomVariablesInitialSolution','var')),...
            'openCOSSAN:ProbabilisticModel:designPointIdentification',...
            'It is necessare to provide the PropertyName CSnameRandomVariables in order to define the initial solution')
        Mu0=zeros(size(VuUnsorted));
        for n=1:length(Cmembers)
            index= ismember(Cmembers,CnamesRandomVariablesInitialSolution{n});
            Mu0(n)=VuUnsorted(index);
        end
    end
    
    %% Compute performance function at the origin
    XoutAtOrigin = Xpm.apply(Xpm.Xinput.getDefaultValuesStructure);
    
    %% Assign default value for initial guess of design point
    if isempty(Mu0),
        if isa(Xoptim,'GeneticAlgorithms'),
            Mu0 = randn(Xoptim.NPopulationSize,length(Cmembers));   %create random population in standard normal space
        else
            Mu0 = zeros(1,length(Cmembers));    %create solution at origin of standard normal space
        end
    elseif isa(Xoptim,'GeneticAlgorithms'),     %in case Mu0 was defined and Optimizer is GeneticAlgorithms, check size of initial solution
        if ~all(size(Mu0)==[Xoptim.NPopulationSize length(Cmembers)]),
            error('openCOSSAN:ProbabilisticModel:designPointIdentification',...
                'the size of the matrix containing the initial population is incorrect');
        end
    end
    
    if isa(Xoptim,'GeneticAlgorithms') %TODO: what about SA? 
        if  strcmp(Xoptim.SMutationFcn,'mutationgaussian')
            Xoptim.SMutationFcn='mutationadaptfeasible';            
        end
        NPopulationSize=Xoptim.NPopulationSize;
    end
    
    % Prepare optimization problem
    Xop=prepareOptimizationProblem(Xpm,Mu0);
    
    %% Solve optimization problem
    Xopt  = Xoptim.apply('XoptimizationProblem',Xop);
    
    
    %% Create DesignPoint object
    Mdata = cell2mat({Xopt.XdesignVariable.Vdata}');    
    
    Xdp=opencossan.reliability.DesignPoint('Sdescription','DesignPoint from designPointIdentification@ProbabilisticModel', ...
        'perfomanceAtOrigin',XoutAtOrigin.getValues('Sname',Xpm.SperformanceFunctionVariable),...
        'NFunctionEvaluations',Xopt.NevaluationsObjectiveFunctions,...
        'Vdesignpointstdnormal',Mdata(1:NPopulationSize:end,end)', ...
        'XProbabilisticModel',Xpm);
    
end

OpenCossan.cossanDisp('[openCOSSAN:ProbabilisticModel:designPointIdentification] Design point identified',3)

return
