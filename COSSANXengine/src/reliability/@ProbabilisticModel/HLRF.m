function [Xdp, Xoptimum]= HLRF(Xobj,varargin)
%HLRF This method computes the so-called design point adopting the gradient of
%the function by means the linar approximations.
%
% See Also: https://cossan.co.uk/wiki/index.php/HLRF@ProbabilisticModel
%
%
% $Copyright~1993-2012,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$

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

% Set Global variable for optimization
global XoptGlobal 

% Set defualt value
toleranceDesignPoint=1e-2;
Nmaxiteration=10;
LfiniteDifferences=true;

Vu=zeros(1,Xobj.Xmodel.Xinput.NrandomVariables);

%% Process inputs
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'mreferencepoints','vinitialsolution'}
            VuUnsorted     = Xobj.Xmodel.Xinput.map2stdnorm(varargin{k+1});
        case {'vinitialsolutionstandardnormalspace'}
            VuUnsorted=varargin{k+1};
        case {'csnamerandomvariables'}
            CnamesRandomVariablesInitialSolution =  varargin{k+1};
        case {'lfinitedifferences'}
            LfiniteDifferences  = varargin{k+1};
        case {'tolerancedesignpoint'}
            toleranceDesignPoint= varargin{k+1};
        case {'valpha'}
            Valpha= varargin{k+1};
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
            error('openCOSSAN:ProbabilisticModel:HLRF',...
                'PropertyName %s is not valid',varargin{k})
    end
end

CnameRandomVariable=Xobj.Xmodel.Xinput.CnamesRandomVariable;
%% Reorder the initial solution
if exist('VuUnsorted','var')
    assert(logical(exist('CnamesRandomVariablesInitialSolution','var')),...
        'openCOSSAN:ProbabilisticModel:HLRF',...
        'It is necessary to provide the PropertyName CSnameRandomVariables in order to define an initial solution point')
    Vu=zeros(size(VuUnsorted));
    for n=1:length(CnameRandomVariable)
        index= ismember(CnameRandomVariable,CnamesRandomVariablesInitialSolution{n});
        Vu(n)=VuUnsorted(index);
    end
    
end

% Prepare optimization problem
XoptimizationProblem=prepareOptimizationProblem(Xobj,Vu);

%% initialize Optimum
if ~exist('Xoptimum','var')
    XoptGlobal=Optimum('XoptimizationProblem',XoptimizationProblem);
else
    %TODO: Check Optimum
    XoptGlobal=Xoptimum;
end



% initialize global variable
iIteration=0;

hobjfun=@(x)evaluate(XoptimizationProblem.XobjectiveFunction,'Xoptimizationproblem',XoptimizationProblem,...
        'MreferencePoints',x,'Lgradient',false);
    
%% Define the Sensitivity objcect    
    

%% Here we go
while 1
    iIteration=iIteration+1;
    Vphysical=Xobj.Xmodel.Xinput.map2physical(Vu);
    
    if LfiniteDifferences
        XlocalSensitivity=LocalSensitivityFiniteDifference('Xtarget',Xobj, ...
            'Coutputname',{Xobj.XperformanceFunction.Soutputname},...
            'Cinputnames',CnameRandomVariable,'VreferencePoint',Vphysical);
    else
        if exist('Valpha','var')
         XlocalSensitivity=LocalSensitivityMonteCarlo('Xtarget',Xobj, ...
            'Coutputname',{Xobj.XperformanceFunction.Soutputname},...
            'Cinputnames',CnameRandomVariable,'VreferencePoint',Vphysical,...
            'Valpha',Valpha);
            
%            [Xgradient, Xout]=Sensitivity.localMonteCarlo('Xtarget',Xobj, ...
%                'Coutputname',{Xobj.XperformanceFunction.Soutputname},...
%                'CnamesRandomVariable',CnameRandomVariable,'VreferencePoint',Vphysical,'Valpha',Valpha);
            
            
        else
          XlocalSensitivity=LocalSensitivityMonteCarlo('Xtarget',Xobj, ...
            'Coutputname',{Xobj.XperformanceFunction.Soutputname},...
            'Cinputnames',CnameRandomVariable,'VreferencePoint',Vphysical);            
        end
    end
    
    % Compute the gradient 
    [Xgradient,Xout]=XlocalSensitivity.computeGradientStandardNormalSpace;
        
    Vg=Xout.getValues('Sname', Xobj.XperformanceFunction.Soutputname);
    
    % Store values of input variables
    MphysicalGradient=Xout.getValues('Cnames', CnameRandomVariable);    
    
    if iIteration == 1
        perfomanceAtOrigin = Vg(1);
    end
    VevaluationPoint=Xobj.Xmodel.Xinput.map2stdnorm(Xgradient.VreferencePoint);
    
    % Collect SimulationData
    if ~exist('XsimOut','var')
        XsimOut=Xout;
    else
        XsimOut=XsimOut.merge(Xout);
    end
    
    %% Check if the points are finite!
    
    assert(all([~isnan(VevaluationPoint) ~isinf(VevaluationPoint)]), ...
        'OpenCossan:ProbabilisticModel:HLRF',...
        'The reference point can not contain NaN or Inf values\nProvided values: %s',...
        sprintf('%e ',VevaluationPoint));
    
    % Evaluate Objective Function
    [~] = hobjfun(Vphysical);  %Objective function evaluation
    
    %% Update Optimum object
    % Add only the values of the constraints
     XoptGlobal=XoptGlobal.addIteration('MdesignVariables',MphysicalGradient,...
                            'VconstraintFunction',Vg,...
                            'Viterations',repmat(iIteration,size(MphysicalGradient,1),1));
    
    Valpha=Xgradient.Valpha;
    
    VB=(VevaluationPoint*Valpha)*Valpha';
    Vu=VB -Vg(1)/norm(Xgradient.Vgradient)* Valpha';
    
    
    if iIteration==1
        bet0  = norm(Vu);
    else
        bet  = norm(Vu);
        convergenceFactor=abs( (bet - bet0) / bet0);
        OpenCossan.cossanDisp(sprintf('* %i Convergence factor %e ',iIteration,convergenceFactor),2)
        if convergenceFactor < toleranceDesignPoint
            Sexitflag   = 'HL-RF converged';
            break
        elseif iIteration == Nmaxiteration
            Sexitflag = 'HL-RF exceeded maximum number of function evaluations';
            break
        end
        
        bet0    = bet;
    end
end

Xoptimum=XoptGlobal;
Xoptimum.Sexitflag=Sexitflag;
%% Construct the outputs

Xdp=DesignPoint('Sdescription','DesignPoint from HLRF algorithm', ...
    'perfomanceAtOrigin',perfomanceAtOrigin,...
    'NFunctionEvaluations',XsimOut.Nsamples,...
    'Vdesignpointstdnormal',Vu, ...
    'XProbabilisticModel',Xobj);


