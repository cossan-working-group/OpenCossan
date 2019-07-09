function [Xpf,XlineSamplingOutput] = computeFailureProbability(Xobj,Xtarget)
%computeFailureProbability method. This method compute the FailureProbability associate to a
% ProbabilisticModel/SystemReliability/MetaModel by means of a
% LineSampling object
%
% See also:
% https://cossan.co.uk/wiki/index.php/computeFailureProbability@LineSampling
%
% Author: Edoardo Patelli and Marco de Angelis
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

import opencossan.simulations.LineSamplingOutput
import opencossan.reliability.FailureProbability
import opencossan.sensitivity.*

%% Check inputs
[Xobj,Xinput]=checkInputs(Xobj,Xtarget);

%% Initialize variables
% Get name of the performance function
SperformanceFunctionName=Xtarget.PerformanceFunctionVariable;

% %standard deviation associated with smooth performance function
% if ~isempty(Xtarget.XperformanceFunction.stdDeviationIndicatorFunction),
%     stdDev = Xtarget.XperformanceFunction.stdDeviationIndicatorFunction;
% else
%     stdDev=[];
% end

% Store the important direction locally (for performance improvment since
% the Valpha is a dependent field of Gradient object)
import opencossan.OpenCossan
% If the important direction does not exist, compute the gradient in SNS to
% create one
if isempty(Xobj.Valpha)
    
    OpenCossan.cossanDisp('[LineSampling:pf] Recompute important direction',3)
    
    Xlsfd=LocalSensitivityFiniteDifference('Xtarget',Xtarget, ...
        'Coutputnames',{Xtarget.XperformanceFunction.Soutputname});
    
    XlocalSensitivity=Xlsfd.computeIndices;
    
    % The performance function decreases towards failure
    Xobj.Valpha=-XlocalSensitivity.Valpha;
    Xobj.CalphaNames=XlocalSensitivity.Cnames;
end

% Make sure the important direction is a column vector
Xobj.Valpha=Xobj.Valpha(:)/norm(Xobj.Valpha);

SexitFlag=[];           % Exit flag

opencossan.OpenCossan.cossanDisp('[LineSampling:pf] Start LineSampling analysis',3)

%% BEGIN LineSampling simulation
while isempty(SexitFlag)
    % Reset Variables
    
    Xobj.ibatch = Xobj.ibatch + 1;
    
    % Lap time for each batch
    opencossan.OpenCossan.getTimer().lap('description',[' Batch #' num2str(Xobj.ibatch)]);
    
    % Compute the number of lines for each batch
    if Xobj.ibatch==Xobj.Nbatches || Xobj.Nlinexbatch==0
        Nlines=Xobj.Nlinelastbatch;
    else
        Nlines=Xobj.Nlinexbatch;
    end
    
    %% Simulation with standard Line sampling
    % Standard LineSampling uses a fixed direction and a fixed grid of
    % points (Vset) where the performance function is evaluated.
    NlinePoints=length(Xobj.Vset);
    
    % Gererate all samples at once
    Xs=Xobj.sample('Nlines',Nlines,'Xinput',Xinput);
    
    Xanalysis=Xinput;
    Xanalysis.Samples=Xs;
    % Evaluate the model
    XpartialSimOut= apply(Xtarget,Xanalysis);
    
    % Extract the values of the performance function
    Vg=XpartialSimOut.getValues('Sname',Xtarget.PerformanceFunctionVariable);
    Mg=reshape(Vg,NlinePoints,Nlines);
    
    % Compute coordinates of points on the hyperplane
    Msamples=transpose(Xs.MsamplesStandardNormalSpace);
    
    VpfLine=zeros(1,Nlines);
    VdistanceLimitState=zeros(1,Nlines);
    VnumPointsLine=zeros(1,Nlines);
    
    VdistancePlaneFine  = linspace(min(Xobj.Vset), max(Xobj.Vset), Xobj.Ncfine)';
    
    % Process lines
    for iLine=1:Nlines
        
        % Interpolate for better accuracy
        VgFine  = interp1(Xobj.Vset,Mg(:,iLine),VdistancePlaneFine,'spline');
        
        [~,indexRoot] = min(abs(VgFine));
        if min(VgFine)>0 % line is all in the survival domain
            distanceLimitState = Inf;
            opencossan.OpenCossan.cossanDisp(strcat(...
                'Intersection with the limit state function not found on Line: #',...
                num2str(iLine)),2);
            
            opencossan.OpenCossan.cossanDisp(strcat(...
                'Line: #',num2str(iLine),'is entirely in the survival domain'),3);
        elseif max(VgFine)<0 % line is all in the failure domain
            distanceLimitState = -Inf;
            opencossan.OpenCossan.cossanDisp(strcat(...
                'Intersection with the limit state function not found on Line: #',...
                num2str(iLine)),2);
            
            opencossan.OpenCossan.cossanDisp(strcat(...
                'Line: #',num2str(iLine),'is entirely in the failure domain'),3);
        else % limit state met regurarly on the positive half-space
            distanceLimitState = VdistancePlaneFine(indexRoot);
            
        end
        
        VnumPointsLine(iLine)=length(Xobj.Vset);
        
        % Compute conditional probability on the current line
        VpfLine(iLine) = normcdf(-distanceLimitState);
        VdistanceLimitState(iLine)=distanceLimitState;
        
    end % loop over lines
    
    XlineSamplingOutput=LineSamplingOutput('SperformanceFunctionName',SperformanceFunctionName,...
        'VnumPointLine',VnumPointsLine,...
        'Vnorm',sqrt(sum(Msamples.^2,1)),...
        'VdistanceOrthogonalPlane',repmat(Xobj.Vset(:),Nlines,1),...
        'VinitialDirectionSNS',Xobj.Valpha,...
        'VlimitStateDistance',VdistanceLimitState,...
        'XsimulationData',XpartialSimOut,...
        'Xinput',Xinput);
    
    % Increment counters
    Xobj.isamples = Xobj.isamples+Nlines*length(Xobj.Vset); % number of samples
    
    %% Export SimulationData
    if ~Xobj.Lintermediateresults
        XsimOut(Xobj.ibatch)=XpartialSimOut;  %#ok<AGROW>
    else
        Xobj.exportResults('XlineSamplingOutput',XlineSamplingOutput);
        % Keep in memory only the SimulationData of the last batch
        XsimOut=XpartialSimOut;
    end
    
    %% Compute Failure Probability
    pfhat = mean(VpfLine);
    variancepf=sum((VpfLine-pfhat).^2)/(Nlines*(Nlines-1));
    
    if Xobj.ibatch==1
        % Initialize FailureProbability object
        Xpf=FailureProbability('CXmembers',{Xtarget},...
            'Smethod','LineSampling', ...
            'Nlines',Nlines,...
            'pf',pfhat,'variancepf',variancepf,...
            'Nsamples',Xobj.isamples);
    else
        Xpf=Xpf.addBatch('pf',pfhat,'variancepf',variancepf,...
            'Nsamples',Nlines*length(Xobj.Vset));
    end
    
    % check termination criteria
    SexitFlag=checkTermination(Xobj,Xpf);
end

% Add termination criteria to the FailureProbability
Xpf.SexitFlag=SexitFlag;

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = opencossan.OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',{Xpf},...
            'CcossanObjectsNames',{'Xpf'});
    end
end

XsimOut(end).SexitFlag=SexitFlag;
XsimOut(end).SbatchFolder=...
    [opencossan.OpenCossan.getWorkingPath filesep Xobj.SbatchFolder];

opencossan.OpenCossan.getTimer().lap('description','End computeFailureProbability@LineSampling');

