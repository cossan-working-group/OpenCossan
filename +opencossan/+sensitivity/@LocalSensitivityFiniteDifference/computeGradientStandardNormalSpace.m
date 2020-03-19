function varargout = computeGradientStandardNormalSpace(Xobj,varargin)
%COMPUTEGRADIENTSTANDARDNORMALSPACE This method computes the gradient of
%the funtion in the standard normal space. Hence, the perturbation of the
%input factor is defined in the standard normal space.
%
% $Copyright~1993-2017,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
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

%% Check inputs
opencossan.OpenCossan.validateCossanInputs(varargin{:})
% OpenCossan.resetRandomNumberGenerator(357357)
%% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xtarget','xmodel'}
            Xobj=Xobj.addModel(varargin{k+1}(1));
        case {'cxtarget','cxmodel'}
            Xobj=Xobj.addModel(varargin{k+1}{1});
        otherwise
            error('openCOSSAN:LocalSensitivityFiniteDifference:computeGradientStandardNormalSpace:WrontInputArgument',...
                'The PropertyName %s is not allowed',varargin{k});
    end
end

%% Check the input
assert(Xobj.Input.NumberOfDesignVariables == 0,...
    'OpenCOSSAN:computeGradientStandardNormalSpace:NoDV',...
    strcat('The method computeGradientStandardNormalSpace can only be used with a pure probabilistic model\n',...
    'No design variable permitted.',...
    '\n DesignVariable: %s'),Xobj.Input.DesignVariableNames)

% Initialize variables
NfunctionEvaluation = 0;
Nrv = Xobj.Input.NumberOfRandomInputs;  % Number of RV dedined in the model
Ninputs = length(Xobj.InputNames);       % Number of required inputs

% Set the analysis name when not deployed
if ~isdeployed
    opencossan.OpenCossan.setAnalysisName(class(Xobj));
end
% set the analyis ID 
opencossan.OpenCossan.setAnalysisId(1); %TODO: set id should get the next available ID from the database
% insert entry in Analysis DB
if ~isempty(opencossan.OpenCossan.getDatabaseDriver)
    insertRecord(opencossan.OpenCossan.getDatabaseDriver,'StableType','Analysis',...
        'Nid',opencossan.OpenCossan.getAnalysisID);
end

%% Define the pertubation
% TODO

% Evaluate the gradient
%[Mgradients, ~, NfunctionEvaluation, varargout{2}]=Xobj.doFiniteDifferences;

%% Generate Samples object from the Reference Point
if isempty(Xobj.Samples0)
    % Construct Reference Point
    % Check mandatory fields
    assert(width(Xobj.VreferencePoint) == Nrv, ...
        'openCOSSAN:sensitivity:coreFiniteDifferences', ...
        strcat('The length of reference point (%i) must be equal to' , ...
        ' the sum of the number of random variables (%i)'), ...
        width(Xobj.VreferencePoint), Nrv)
    
    Xobj.Samples0 = Xobj.Input.completeSamples(Xobj.VreferencePoint);
else
    Xobj.VreferencePoint = Xobj.Input.map2stdnorm(Xobj.Samples0);
end

if isempty(Xobj.Fx0)
    Xout0=Xobj.Target.apply(Xobj.Samples0);
    if ~isempty(opencossan.OpenCossan.getDatabaseDriver)
        insertRecord(opencossan.OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
            'Nid',getNextPrimaryID(opencossan.OpenCossan.getDatabaseDriver,'Simulation'),...
            'XsimulationData',Xout0,'Nbatchnumber',0) 
    end  
    NfunctionEvaluation = NfunctionEvaluation + Xout0.NumberOfSamples;
    Vreference = Xout0.Samples.(Xobj.OutputNames);
else
    Cvariables=Xobj.Xsamples0.Cvariables;
    Cvariables(end+1)=Xobj.Coutputname;
    Mfx0=[Xobj.Xsamples0.MsamplesPhysicalSpace Xobj.fx0];
    Xout0=SimulationData('Cnames',Cvariables,'Mvalues',Mfx0);
    Vreference=Xobj.fx0;
end

%% Compute finite difference for each component
% Define the perturbation points in the STANDARD NORMAL SPACE
samplesInStdNorm = repmat(Xobj.Input.map2stdnorm(Xobj.VreferencePoint), Ninputs, 1);
samplesInStdNorm = array2table(samplesInStdNorm{:,:} + Xobj.perturbation * eye(Nrv));
samplesInStdNorm.Properties.VariableNames = Xobj.Input.RandomInputNames;

samplesInPhysical = Xobj.Input.map2physical(samplesInStdNorm);
samplesInPhysical = Xobj.Input.completeSamples(samplesInPhysical);

% Evaluate the model
fxInPhysical = Xobj.Target.apply(samplesInPhysical);
if ~isempty(opencossan.OpenCossan.getDatabaseDriver)
    insertRecord(opencossan.OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
        'Nid',getNextPrimaryID(opencossan.OpenCossan.getDatabaseDriver,'Simulation'),...
        'XsimulationData',fxInPhysical,'Nbatchnumber',0) 
end  
NfunctionEvaluation = NfunctionEvaluation + fxInPhysical.NumberOfSamples;

%% Compute gradient (in StandardNormalSpace)
gradient = zeros(Ninputs,length(Xobj.OutputNames));

for iout = 1:length(Xobj.OutputNames)
    gradient(:, iout) = (fxInPhysical.Samples.(Xobj.OutputNames(iout)) - Vreference(iout)) ./ Xobj.perturbation;
end

simData = Xout0 + fxInPhysical; % Export SimulationData
%% Export results
varargout{2} = simData;

for n=1:length(Xobj.OutputNames)
        varargout{1}(n) = opencossan.sensitivity.Gradient('Sdescription',...
            strjoin(['Finite Difference Gradient estimation of' Xobj.OutputNames(n) 'computed in standard normal space']), ...
            'Cnames',Xobj.InputNames, ...
            'LstandardNormalSpace',true, ...
            'NfunctionEvaluation',NfunctionEvaluation,...
            'Vgradient',gradient(:,n),'Vreferencepoint',Xobj.VreferencePoint,...
            'SfunctionName',Xobj.OutputNames(n));   
end

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = opencossan.OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(opencossan.OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',varargout(1),...
            'CcossanObjectsNames',{'Xgradient'});
    end
end
