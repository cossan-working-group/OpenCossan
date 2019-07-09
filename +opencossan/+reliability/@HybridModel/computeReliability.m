function [Xdp, Vvalues, Cnames] = computeReliability(Xobj,varargin)
% RELIABILITYANALYSIS  compute the reliability index of structures
% exhibiting both stochastic and bounded uncertainties by using probability
% and convex set mixed model
%  
% See also: HybridModel
%   
% Bibliography reference: Structural reliability assessment based on
% probability and convex set mixed model, Luo et al., 2009
% =====================================================================


%% Process inputs
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'mreferencepoints','vinitialsolution'}
            VuUnsorted     = Xobj.Xmodel.Xinput.map2stdnorm(varargin{k+1});
        case {'vinitialsolutiontransformedspace'}
            VuUnsorted=varargin{k+1};
        case {'mboundedvalues','vinitialsolutionboundedvariables'}
            VvUnsorted     = Xobj.Xmodel.Xinput.map2deltaSpace(varargin{k+1});
        case {'vinitialsolutionboundedvariablesdeltaspace'}
            VvUnsorted=varargin{k+1};
        case {'csnamerandomvariables'}
            CnamesRandomVariablesInitialSolution =  varargin{k+1};
        case {'csnameintervals'}
            CnamesIntervalsInitialSolution =  varargin{k+1};
        case {'xoptim','xoptimizer','cxoptimizer'}
            if iscell(varargin{k+1})
                Xoptimizer  = varargin{k+1}{1};
            else
                Xoptimizer  = varargin{k+1};
            end
            mc=metaclass(Xoptimizer);
            assert(strcmp(mc.SuperClasses{1}.Name,'opencossan.optimization.Optimizer'),...
                'openCOSSAN:reliability:HybridModel:computeReliability', ...
                ['An optimizer object is required, object provided of type ' mc.SuperClasses{1}.Name ])
        otherwise
            error('openCOSSAN:ProbabilisticModel:HLRF',...
                'PropertyName %s is not valid',varargin{k})
    end
end

if ~exist('Xoptimizer','var')
    Xoptimizer = opencossan.optimization.StochasticRanking('Nmu',5,'Nlambda',50,'Vsigma',2*ones(5,1));

end

%%  Initialize variables
Cboundedsetname=Xobj.Xinput.CnamesBoundedSet;
CnameRandomVariable=Xobj.Xinput.CnamesRandomVariable;
CnameIntervals=Xobj.Xinput.CnamesIntervalVariable;
XoutAtOrigin = Xobj.Xevaluator.apply(Xobj.Xinput.getDefaultValuesTable);
%% Initial solutions
if exist('VuUnsorted','var')
    assert(logical(exist('CnamesRandomVariablesInitialSolution','var')),...
        'openCOSSAN:HybridModel:reliabilityAnalysis',...
        'It is necessary to provide the PropertyName CSnameRandomVariables in order to define an initial solution point')
    VinitialValues_RVs=zeros(size(VuUnsorted));
    for n=1:length(CnameRandomVariable)
        index= ismember(CnameRandomVariable,CnamesRandomVariablesInitialSolution{n});
        VinitialValues_RVs(n)=VuUnsorted(index);
    end 
    if isa(Xoptimizer,'opencossan.optimization.GeneticAlgorithms'),     %in case Mu0 was defined and Optimizer is GeneticAlgorithms, check size of initial solution
        if ~all(size(VinitialValues_RVs)==[Xoptimizer.NPopulationSize length(CnamesRandomVariables)]),
            error('openCOSSAN:HybridModel:computeReliability',...
                'the size of the matrix containing the initial population is incorrect');
        end
    end
else
    if isa(Xoptimizer,'opencossan.optimization.GeneticAlgorithms'),
        VinitialValues_RVs=zeros(Xoptimizer.NPopulationSize, length(CnameRandomVariable));
    else
        VinitialValues_RVs=zeros(1,length(CnameRandomVariable));
    end
end

if exist('VvUnsorted','var')
    assert(logical(exist('CnamesBoundedVariablesInitialSolution','var')),...
        'openCOSSAN:HybridModel:reliabilityIndexIdentification',...
        'It is necessary to provide the PropertyName CSnameIntervals in order to define an initial solution point')
    VinitialValues_BVs=zeros(size(VvUnsorted));
    for n=1:length(CnameIntervals)
        index= ismember(CnameIntervals,CnamesIntervalsInitialSolution{n});
        VinitialValues_BVs(n)=VvUnsorted(index);
    end 
    if isa(Xoptimizer,'opencossan.optimization.GeneticAlgorithms'),     %in case Mu0 was defined and Optimizer is GeneticAlgorithms, check size of initial solution
        if ~all(size(VinitialValues_BVs)==[Xoptimizer.NPopulationSize length(CnameIntervals)]),
            error('openCOSSAN:HybridModel:computeReliability',...
                'the size of the matrix containing the initial population is incorrect');
        end
    end
else
    if isa(Xoptimizer,'opencossan.optimization.GeneticAlgorithms'),
        for ics=1:length(Cboundedsetname)
        Vsample_BV=sample(Xobj.Xinput.Xbset.(Cboundedsetname{ics}),'Nsample',Xoptimizer.NPopulationSize);
        VinitialValues_BVs=(Vsample_BV.MsamplesHyperSphere);
        end
    else 
        % Define a first random solution for interval variables
        ibv=0;
        for ics=1:length(Cboundedsetname)
            Vsample_BV=sample(Xobj.Xinput.Xbset.(Cboundedsetname{ics}),'Nsample',1);
            VinitialValues_BVs(1,ibv+1:ibv+length(Vsample_BV.MsamplesHyperSphere))=Vsample_BV.MsamplesHyperSphere;
            ibv=ibv+length(Vsample_BV.MsamplesHyperSphere);
        end
    end
end

XoptimizationProblem=Xobj.prepareOptimizationProblem('Mv0',VinitialValues_BVs,'Mu0',VinitialValues_RVs);

%% Compute Optimization problem with the Optimizer chosen
[Xopt, XsimOut]=XoptimizationProblem.optimize('Xoptimizer',Xoptimizer);

%% Construct the outputs
CnamesDP=strcat(Xobj.Xinput.CnamesRandomVariable,'_DV');
CnamesBV_DV=strcat(Xobj.Xinput.CnamesIntervalVariable,'_DV');
[~,No]=intersect( Xopt.CdesignVariableNames,CnamesDP,'stable');
[~,Nointervals]=intersect( Xopt.CdesignVariableNames,CnamesBV_DV,'stable');
OptDesignVariables=Xopt.getOptimalDesign;
OD_bounded=opencossan.common.utilities.sphere2cart(OptDesignVariables(Nointervals));
% VoptTransfSpace=[OptDesignVariables(No),OD_bounded];

Vvalues=Xobj.Xinput.map2physical('Msns',OptDesignVariables(No),'MHS',OD_bounded);
Cnames=Xobj.Xinput.Cnames;
Xdp=opencossan.reliability.DesignPoint('Sdescription','DesignPoint from HybridModel reliabilityAnalysis', ...
    'NFunctionEvaluations',XsimOut.Nsamples,...
    'VDesignPointPhysical',Vvalues(No), ...
    'perfomanceatorigin',XoutAtOrigin.getValues('Sname',Xobj.PerformanceFunctionVariable),...
    'XHybridModel',Xobj);
