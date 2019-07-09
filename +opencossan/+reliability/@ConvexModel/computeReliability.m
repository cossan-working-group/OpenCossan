function [beta, VvariableValues]= computeReliability(Xobj,varargin)
    % This method computes the reliability index beta adopting the gradient of
    % the function by means the linar approximations (HLRF).
    %
    %
    % Author: Silvia Tolo
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
    
global XoptGlobal

% Set defualt value
toleranceDesignPoint=1e-20;
Nmaxiteration=100;
VinitialSolution=[];
Vphysical=[];
Lgrad = false;

%% Process inputs
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'mreferencepoints','vinitialsolution'}
            VuUnsorted     = Xobj.Xinput.map2hypersphere(varargin{k+1});
        case {'vinitialsolutionhypersphere'}
            VuUnsorted=varargin{k+1};
        case {'csnameboundedvariables'}
            CnamesIntervalVariablesInitialSolution =  varargin{k+1};
        case {'tolerancedesignpoint'}
            toleranceDesignPoint= varargin{k+1};
        case {'lgrad'}
            Lgrad=varargin{k+1};
        case {'xoptim','xoptimizer','cxoptimizer'}
            if iscell(varargin{k+1})
                Xoptimizer  = varargin{k+1}{1};
            else
                Xoptimizer  = varargin{k+1};
            end
            mc=metaclass(Xoptimizer);
            assert(strcmp(mc.SuperClasses{1}.Name,'opencossan.optimization.Optimizer'),...
                'openCOSSAN:reliability:ConvexModel:computeReliability', ...
                ['An optimizer object is required, object provided of type ' mc.SuperClasses{1}.Name ])
        case {'nmaxiteration'}
            Nmaxiteration= varargin{k+1};
        case {'xoptimum'},   %extract OptimizationProblem
            if isa(varargin{k+1},'Optimum'),    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('openCOSSAN:HLRF',...
                    'the variable %s must be an Optimum object',inputname(k));
            end
        otherwise
            error('openCOSSAN:reliability:ConvexModel:computeReliability',...
                'PropertyName %s is not valid',varargin{k})
    end
end

if ~exist('Xoptimizer','var') && Lgrad==0
    Xoptimizer = Cobyla('initialTrustRegion',1,'finalTrustRegion',0.01);  
end    
CSnameIntervalVariable=Xobj.Xinput.CnamesIntervalVariable;
%% Reorder the initial solution
if exist('VuUnsorted','var')
    assert(logical(exist('CnamesIntervalVariablesInitialSolution','var')),...
        'openCOSSAN:reliability: ConvexModel:computeReliability',...
        'It is necessary to provide the PropertyName CSnameIntervalVariable in order to define an initial solution point')
    VinitialSolution=zeros(size(VuUnsorted));    
    for n=1:length(CSnameIntervalVariable)
        index= ismember(CSnameIntervalVariable,CnamesIntervalVariablesInitialSolution{n});
        VinitialSolution(n)=VuUnsorted(index);
    end
    if isa(Xoptimizer,'GeneticAlgorithms'),     %in case Mu0 was defined and Optimizer is GeneticAlgorithms, check size of initial solution
        if ~all(size(VinitialSolution)==[Xoptimizer.NPopulationSize length(CSnameIntervalVariable)]),
            error('openCOSSAN:ConvexModel:computeReliability',...
                'the size of the matrix containing the initial population is incorrect');
        end
    end
else
    if isa(Xoptimizer,'GeneticAlgorithms'),
        Cbsetname=Xobj.Xinput.CnamesBoundedSet;
        ibs=0;
        for ics=1:length(Cbsetname)
            Vsample=sample(Xobj.Xinput.Xbset.(Cbsetname{ics}),'nsample',Xoptimizer.NPopulationSize);
            VinitialSolution(1,ibs+1:ibs+length(Vsample.MsamplesPhysicalSpace))=Vsample.MsamplesHyperSphere;
            Vphysical(1,ibs+1:ibs+length(Vsample.MsamplesPhysicalSpace))=Vsample.MsamplesPhysicalSpace;
            ibs=ibs+length(Vsample.MsamplesPhysicalSpace);
        end
    else
        % Define a first random solution
        Cbsetname=Xobj.Xinput.CnamesBoundedSet;
        VinitialSolution= zeros(1,length(Xobj.Xinput.CnamesIntervalVariable));
        ibs=0;
        for ics=1:length(Cbsetname)
            Vsample=sample(Xobj.Xinput.Xbset.(Cbsetname{ics}),'nsample',1);
            VinitialSolution(1,ibs+1:ibs+length(Vsample.MsamplesHyperSphere))=Vsample.MsamplesHyperSphere;
            Vphysical(1,ibs+1:ibs+length(Vsample.MsamplesPhysicalSpace))=Vsample.MsamplesPhysicalSpace;
            ibs=ibs+length(Vsample.MsamplesPhysicalSpace);
        end
    end
end

% Prepare optimization problem
XoptimizationProblem=prepareOptimizationProblem(Xobj,VinitialSolution);
%
%% initialize Optimum
if ~exist('Xoptimum','var')
    XoptGlobal=XoptimizationProblem.initializeOptimum('Lgradientobjectivefunction',false,'Lgradientconstraints',true);
else
    %TODO: Check Optimum
    XoptGlobal=Xoptimum;
end

if Lgrad
    % initialize global variable
    iIteration=0;
    
    hobjfun=@(x)evaluate(XoptimizationProblem.XobjectiveFunction,'Xoptimizationproblem',XoptimizationProblem,...
        'MreferencePoints',x,'Lgradient',false);
    
    %% Here we go
    while 1
        iIteration=iIteration+1;
        [Xgradient, Xout]=computeGradientDeltaSpace('Xtarget',Xobj, ...
            'Coutputname',{Xobj.PerformanceFunctionVariable},...
            'CnamesBoundedVariable',CSnameIntervalVariable,'VreferencePoint',Vphysical);
        % Collect SimulationData
        if ~exist('XsimOut','var')
            XsimOut=Xout;
        else
            XsimOut=XsimOut.merge(Xout);
        end
        
        Vg=Xout.getValues('Sname', Xobj.PerformanceFunctionVariable);
        
        VevaluationPoint=Xgradient.VreferencePoint;
        
        %% Check if the points are finite!
        assert(all([~isnan(VevaluationPoint) ~isinf(VevaluationPoint)]), ...
            'openCOSSAN:ConvexModel:computeReliability',...
            'The reference point can not contain NaN or Inf values\nProvided values: %s',...
            sprintf('%e ',VevaluationPoint));
        
        % Evaluate Objective Function
        [~] = hobjfun(Vphysical);  %Objective function evaluation
        
        %% Update Optimum object
        
        XoptGlobal.Xconstrains=addData(XoptGlobal.Xconstrains,...
            'Vdata',Vg(1),'Mcoord',length(XoptGlobal.Xconstrains.Mcoord)+1);
        
        XoptGlobal.XconstrainsGradient= ...
            addData(XoptGlobal.XconstrainsGradient,...
            'Vdata',Xgradient.Valpha,'Mcoord',XoptGlobal.NevaluationsConstraints);
        
        
        Valpha=Xgradient.Valpha;
        VB=(VevaluationPoint*Valpha)*Valpha';
        VinitialSolution=VB -Vg(1)/norm(Xgradient.Vgradient)* Valpha';
        Vphysical=Xobj.Xinput.map2physical(VinitialSolution);
        
        
        if iIteration==1
            bet0  = norm(VinitialSolution);
        else
            beta  = norm(VinitialSolution);
            convergenceFactor=abs( (beta - bet0) / bet0);
            OpenCossan.cossanDisp(sprintf('* %i Convergence factor %e ',iIteration,convergenceFactor),2)
            if convergenceFactor < toleranceDesignPoint,
                Sexitflag   = 'HL-RF converged';
                break
            elseif iIteration == Nmaxiteration
                Sexitflag = 'HL-RF exceeded maximum number of function evaluations';
                break
            end
            
            bet0    = beta;
        end
    end
    
    Xoptimum=XoptGlobal;
    Xoptimum.Sexitflag=Sexitflag;
    
    %% Construct the outputs
else
    Xopt            = XoptimizationProblem.optimize('Xoptimizer',Xoptimizer);
    VoptValues_DV   = Xopt.getOptimalDesign;
    beta            = Xopt.getOptimalObjective;
    Vphysical       = Xobj.Xinput.map2physical('MsamplesHyperSphere',VoptValues_DV);   
end

%% Prepare output
VvariableValues=cell(2,length(Xobj.Xinput.CnamesIntervalVariable));
for i=1:length(Xobj.Xinput.CnamesIntervalVariable)
    VvariableValues{1,i}=Xobj.Xinput.CnamesIntervalVariable{i};
    VvariableValues{2,i}=Vphysical(i);
end
if (beta>1)
    warning('openCOSSAN:ConvexModel:ComputeReliability',...
        'The system is in an absolute reliable state');
else
    warning('openCOSSAN:ConvexModel:ComputeReliability',...
        'The system has a possibility of failure');
end
