function [Xpf,XsimOut] = computeFailureProbability(Xobj,Xtarget)
%computeFailureProbability method. This method compute the FailureProbability associate to a
% ProbabilisticModel/SystemReliability/MetaModel by means of a
% LineSampling object
%
% See also:
% https://cossan.co.uk/wiki/index.php/computeFailureProbability@Simulations
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

%% Check inputs
[Xobj,Xinput]=checkInputs(Xobj,Xtarget);

%% Initialize variables
% Get name of the performance function
SperformanceFunctionName=Xtarget.XperformanceFunction.Soutputname;

% %standard deviation associated with smooth performance function
% if ~isempty(Xtarget.XperformanceFunction.stdDeviationIndicatorFunction),
%     stdDev = Xtarget.XperformanceFunction.stdDeviationIndicatorFunction;
% else
%     stdDev=[];
% end

% Store the important direction locally (for performance improvment since
% the Valpha is a dependent field of Gradient object)

if isempty(Xobj.Valpha)
    % Recompute the important direction automatically
    OpenCossan.cossanDisp('[LineSampling:pf] Recompute important direction',3)
    Xlsfd=LocalSensitivityFiniteDifference('Xtarget',Xtarget, ...
        'Coutputnames',{Xtarget.XperformanceFunction.Soutputname});
    
    XlocalSensitivity=Xlsfd.computeIndices;
    
    Xobj.Valpha=-XlocalSensitivity.Valpha;
    Xobj.CalphaNames=XlocalSensitivity.Cnames;
end

% Make sure the reliability index is a column vector
Xobj.Valpha=Xobj.Valpha(:);

% Make sure that the order of the input variables in Valpha is the same as
% the order in the input of the probabilistic model
[~,idx]=ismember(Xtarget.Xmodel.Xinput.CnamesRandomVariable, Xobj.CalphaNames);
Xobj.CalphaNames = Xobj.CalphaNames(idx);
Xobj.Valpha=Xobj.Valpha(idx);

SexitFlag=[];           % Exit flag

OpenCossan.cossanDisp('[LineSampling:pf] Start LineSampling analysis',3)

%% BEGIN LineSampling simulation
while isempty(SexitFlag)
    % Reset Variables
   
    Xobj.ibatch = Xobj.ibatch + 1;
    
    % Lap time for each batch
    OpenCossan.setLaptime('Sdescription',[' Batch #' num2str(Xobj.ibatch)]);
    
    % Compute the number of lines for each batch
    if Xobj.ibatch==Xobj.Nbatches || Xobj.Nlinexbatch==0
        Nlines=Xobj.Nlinelastbatch;
    else
        Nlines=Xobj.Nlinexbatch;
    end
    
    %% Simulation with standard Line sampling
    % Standard LineSampling uses a fixed direction and grid of
    % points (Vset) where the performance function is evaluated.
    Vdirection=Xobj.Valpha/norm(Xobj.Valpha);
%     Nvars=length(Vdirection);
    NlinePoints=length(Xobj.Vset);
    
%     % Number of points per line
%     VnumPointLine=length(Xobj.Vset)*ones(1,Nlines);
    
    % Gererate samples
    Xs=Xobj.sample('Nlines',Nlines,'Xinput',Xinput);
    
    % Evaluate the model
    XpartialSimOut= apply(Xtarget,Xs);
    
    % Extract the values of the performance function
    Vg=XpartialSimOut.getValues('Sname',Xtarget.XperformanceFunction.Soutputname);
    Mg=reshape(Vg,NlinePoints,Nlines);
    
    % Compute coordinates of points on the hyperplane
    Msamples=transpose(Xs.MsamplesStandardNormalSpace);
    MlineSample=Msamples(:,1:length(Xobj.Vset):end);
    MorthHyperPlane =transpose(MlineSample-Vdirection*(Vdirection'*MlineSample));
    
    VpfLine=zeros(1,Nlines);
    VnumPointsLine=zeros(1,Nlines);
    VstatePointsNorm=zeros(1,Nlines);
    % Process lines
    for iLine=1:Nlines
        
        % Interpolate for better accuracy
        VdistancePlaneFine  = linspace(min(Xobj.Vset), max(Xobj.Vset), Xobj.Ncfine)';
        VgFine  = interp1(Xobj.Vset,Mg(:,iLine),VdistancePlaneFine,'spline');
        
        [~,indexRoot] = min(abs(VgFine));
        if min(VgFine)>0 % line is all in the survival domain
            
            distanceHyperplane = Inf;
            OpenCossan.cossanDisp(strcat(...
                'Intersection with the limit state function not found on Line: #',...
                num2str(iLine)),2);
            
            % Store coordinates of the approximated limit state points
            VlineStatePoints = MorthHyperPlane(iLine,:)+...
                VdistancePlaneFine(indexRoot)*Vdirection';
            
            %             stateFlag=3;
            OpenCossan.cossanDisp(strcat(...
                'Line: #',num2str(iLine),'is entirely in the survival domain'),3);
            
        elseif max(VgFine)<0 % line is all in the failure domain
            
            distanceHyperplane = -Inf;
            OpenCossan.cossanDisp(strcat(...
                'Line: #',num2str(iLine),' all line in the negative domain. Try to reduce the value of Vset!'),2);
            
            % Store coordinates of the approximated limit state points
            VlineStatePoints = MorthHyperPlane(iLine,:)+...
                VdistancePlaneFine(indexRoot)*Vdirection';

%             stateFlag=4;
            OpenCossan.cossanDisp(strcat(...
                'Line: #',num2str(iLine),'is entirely in the failure domain'),3);
            
        else % limit state met regurarly on the positive half-space
            
            distanceHyperplane = VdistancePlaneFine(indexRoot);
            
            % Store coordinates of the approximated limit state points
            VlineStatePoints = MorthHyperPlane(iLine,:)+...
                distanceHyperplane*Vdirection';
            
%             stateFlag=1;
        end
        
        VnumPointsLine(iLine)=length(Xobj.Vset);
        
        % Compute conditional probability on the current line
        VpfLine(iLine) = normcdf(-distanceHyperplane);
        
        %             % TODO
        %             if ~isempty(stdDev)
        %                 Vpdf        = normpdf(VdistancePlaneFine(:)');  %Gaussian pdf associated with points of vector Vcfine
        %                 VSmoothIF   = normcdf(-VgFine(:)',0,stdDev);   %value of smooth indicator function
        %                 Vdeltac     = diff(VdistancePlaneFine);
        %                 %calculate failure probability associated with line using trapezoid rule for integration
        %                 Xobj.VpfLine(icurrentLine)    = sum(0.5*(Vpdf(1:end-1).*VSmoothIF(1:end-1) +...
        %                     Vpdf(2:end).*VSmoothIF(2:end)).*Vdeltac(:)');
        %             end
        
    end % loop over lines
    
    XlineSamplingOutput=LineSamplingOutput('SperformanceFunctionName',SperformanceFunctionName,...
        'VnumPointLine',VnumPointsLine,...
        'Vnorm',sqrt(sum(Msamples.^2,1)),...
        'VdistanceOrthogonalPlane',repmat(Xobj.Vset(:),Nlines,1),...
        'XsimulationData',XpartialSimOut);
    
    % Increment counters
    Xobj.isamples = Xobj.isamples+Nlines*length(Xobj.Vset); % number of samples
    
    %% Export SimulationData
    if ~Xobj.Lintermediateresults
        XsimOut(Xobj.ibatch)=XlineSamplingOutput;  %#ok<AGROW>
    else
        Xobj.exportResults('XlineSamplingOutput',XlineSamplingOutput);
        % Keep in memory only the SimulationData of the last batch
        XsimOut=XlineSamplingOutput;
    end
    
    %% Compute Probability Failure
    pfhat = mean(VpfLine);
    variancepf=sum((VpfLine-pfhat).^2)/(Nlines*(Nlines-1));
    
    if Xobj.ibatch==1
        % Initialize FailureProbability object
        Xpf=FailureProbability('CXmembers',{Xtarget},'Smethod','LineSampling', ...
            'pf',pfhat,'variancepf',variancepf,...
            'Nsamples',Xobj.isamples,'Nlines',Nlines);
    else
        Xpf=Xpf.addBatch('pf',pfhat,'variancepf',variancepf,...
            'Nsamples',Nlines*length(Xobj.Vset),'Nlines',Nlines);
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
    XdbDriver = OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',{Xpf},...
            'CcossanObjectsNames',{'Xpf'});
    end
end

XsimOut(end).SexitFlag=SexitFlag;
XsimOut(end).SbatchFolder=...
    [OpenCossan.getCossanWorkingPath filesep Xobj.SbatchFolder];

OpenCossan.setLaptime('Sdescription','End computeFailureProbability@LineSampling');

% %% Restore Global Random Stream
% restoreRandomStream(Xobj);
