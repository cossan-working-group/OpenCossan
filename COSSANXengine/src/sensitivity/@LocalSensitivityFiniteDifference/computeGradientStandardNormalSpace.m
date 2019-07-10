function varargout=computeGradientStandardNormalSpace(Xobj)
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


%% Check the input
assert(Xobj.Xinput.NdesignVariables==0,...
    'OpenCOSSAN:computeGradientStandardNormalSpace:NoDV',...
    strcat('The method computeGradientStandardNormalSpace can only be used with a pure probabilistic model\n',...
    'No design variable permitted.',...
    '\n DesignVariable: %s'),Xobj.Xinput.CnamesDesignVariable)

% Initialize variables
NfunctionEvaluation=0;
Nrv=Xobj.Xinput.NrandomVariables;  % Number of RV dedined in the model
Ninputs=length(Xobj.Cinputnames);       % Number of required inputs

% Set the analysis name when not deployed
if ~isdeployed
    OpenCossan.setAnalysisName(class(Xobj));
end
% set the analyis ID 
OpenCossan.setAnalysisID;
% insert entry in Analysis DB
if ~isempty(OpenCossan.getDatabaseDriver)
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Analysis',...
        'Nid',OpenCossan.getAnalysisID);
end

%% Define the pertubation
% TODO

% Evaluate the gradient
%[Mgradients, ~, NfunctionEvaluation, varargout{2}]=Xobj.doFiniteDifferences;

%% Generate Samples object from the Reference Point
if isempty(Xobj.Xsamples0)
    % Construct Reference Point
    % Check mandatory fields
    assert(length(Xobj.VreferencePoint)==Nrv, ...
        'openCOSSAN:sensitivity:coreFiniteDifferences', ...
        strcat('The length of reference point (%i) must be equal to' , ...
        ' the sum of the number of random variables (%i)'), ...
        length(Xobj.VreferencePoint),Nrv)
    
    Xobj.Xsamples0=Samples('MsamplesPhysicalSpace',Xobj.VreferencePoint,'Xinput',Xobj.Xinput);    
else
    Xobj.VreferencePoint=Xobj.Xsamples0.MsamplesStandardNormalSpace;
end

if isempty(Xobj.fx0)
    Xout0=Xobj.Xtarget.apply(Xobj.Xsamples0);
    if ~isempty(OpenCossan.getDatabaseDriver)
        insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
            'XsimulationData',Xout0,'Nbatchnumber',0) 
    end  
    NfunctionEvaluation=NfunctionEvaluation+Xout0.Nsamples;
    Vreference=Xout0.getValues('Cnames',Xobj.Coutputnames);
else
    Cvariables=Xobj.Xsamples0.Cvariables;
    Cvariables(end+1)=Xobj.Coutputname;
    Mfx0=[Xobj.Xsamples0.MsamplesPhysicalSpace Xobj.fx0];
    Xout0=SimulationData('Cnames',Cvariables,'Mvalues',Mfx0);
    Vreference=Xobj.fx0;
end

%% Compute finite difference for each component
% Define the perturbation points in the STANDARD NORMAL SPACE
MsamplesSNS=repmat(Xobj.Xsamples0.MsamplesStandardNormalSpace,Ninputs,1);

Mperturbation=Xobj.perturbation*eye(Nrv);

MsamplesSNS=MsamplesSNS+Mperturbation;

% Define a Samples object with the perturbated values
Xsmli=Samples('MsamplesStandardNormalSpace',MsamplesSNS,'Xinput',Xobj.Xinput);

% Evaluate the model
Xdeltai     = Xobj.Xtarget.apply(Xsmli);
if ~isempty(OpenCossan.getDatabaseDriver)
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
        'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
        'XsimulationData',Xdeltai,'Nbatchnumber',0) 
end  
NfunctionEvaluation     = NfunctionEvaluation+Xdeltai.Nsamples;

%% Compute gradient (in StandardNormalSpace)
MgradientsSNS=zeros(Ninputs,length(Xobj.Coutputnames));

for iout=1:length(Xobj.Coutputnames)
    MgradientsSNS(:,iout) = (Xdeltai.getValues('Cnames',Xobj.Coutputnames(iout)) - Vreference(iout) )./Xobj.perturbation;
end

%% Compute the variance of the responce in standard normal space
Mindices=zeros(Ninputs,length(Xobj.Coutputnames));

for iout=1:length(Xobj.Coutputnames)
    Mindices(:,iout) = (Xdeltai.getValues('Cnames',Xobj.Coutputnames(iout)) - ...
        Vreference(iout) )/Xobj.perturbation;    
end
XsimData=Xout0.merge(Xdeltai); % Export SimulationData
%% Export results
varargout{2}=XsimData;

for n=1:length(Xobj.Coutputnames)
        varargout{1}(n)=Gradient('Sdescription',...
            ['Finite Difference Gradient estimation of ' Xobj.Coutputnames{n} ' computed in standard normal space'], ...
            'Cnames',Xobj.Cinputnames, ...
            'LstandardNormalSpace',true, ...
            'NfunctionEvaluation',NfunctionEvaluation,...
            'Vgradient',MgradientsSNS(:,n),'Vreferencepoint',Xobj.VreferencePoint,...
            'SfunctionName',Xobj.Coutputnames{n});   
end

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',varargout(1),...
            'CcossanObjectsNames',{'Xgradient'});
    end
end
