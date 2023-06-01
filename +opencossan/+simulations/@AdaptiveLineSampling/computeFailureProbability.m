function [Xpf,XlineSamplingOutput] = computeFailureProbability(Xobj,Xtarget)
% COMPUTEFAILUREPROBABILITY method. This method compute the
% FailureProbability associate to a ProbabilisticModel/SystemReliability/MetaModel
% by means of the AdvancedLineSampling object
%
% See also:
% https://cossan.co.uk/wiki/index.php/computeFailureProbability@AdaptiveLineSampling
%
% Author: Marco de Angelis and Edoardo Patelli
% Institute for Risk and Uncertainty, University of Liverpool, UK
%%
import opencossan.reliability.FailureProbability
import opencossan.simulations.LineSamplingOutput
import opencossan.common.*
%%
% global iUpdates
%% Check inputs
[Xobj,Xinput]=checkInputs(Xobj,Xtarget);
%% Create temporary path
[~,~]=system(['mkdir ',Xobj.StempPath]);
%% Initialise variables
% % Get name of the performance function
% SperformanceFunctionName=Xtarget.XperformanceFunction.Soutputname;

% Initialise the important direction
Xobj=Xobj.initialiseImportantDirection(Xtarget);

% make sure the important direction is a (column) unit vector
Valpha=Xobj.VdirectionSNS;
Valpha0=Valpha(:)/norm(Valpha);

% Initialisations: 
% vector with number of points per line
VnumPointsLine=zeros(1,Xobj.Nlines+1);
% vector with limit state distance
VdistanceLimitState=zeros(1,Xobj.Nlines+1);
% vector with limit state norms
VlimitStateNorm=zeros(1,Xobj.Nlines+1);
% vector with direction number
VdirectionNumber=zeros(1,Xobj.Nlines+1);
% vector with update flag
Lupdate=false(1,Xobj.Nlines+1);
% line counter
VlineNumber=zeros(1,Xobj.Nlines+1);
% vector with line index
VlineIndex=zeros(1,Xobj.Nlines+1);

% VdirectionalUpdate=false(1,Xobj.Nlines+1);

directionNumber=0;
Xsamples=Samples;

%% Compute reliability index
if isempty(Xobj.reliabilityIndex)
    % Process line through the origin
    LprocessZeroLine=true;
    % Initialise reliability index
    [Xobj,XlineSimOut,mostProbablePointNorm0,Tline0,stateFlag0,NevalPoints,XsamplesTmp]=...
        Xobj.computeReliabilityIndex(Xtarget);
    Xsamples=Xsamples.add('Xsamples',XsamplesTmp);
    Valpha=Tline0.ValphaNew;
    VdistanceLimitState(1)=Tline0.distanceLimitState;
    VlimitStateNorm(1)=mostProbablePointNorm0;
    if Tline0.LdirectionalUpdate
        Lupdate(1)=true;
        VdirectionNumber(1)=0;
    end
    
    XpartialSimData=XlineSimOut;
    if isinf(mostProbablePointNorm0)
        % stop the process if no limit state is met on the given direction
        % Create the Failure Probability object
        Xpf = FailureProbability('CXmembers',{Xtarget},...
            'Smethod','AdaptiveLineSampling',...
            'pf',normcdf(-mostProbablePointNorm0),'variancepf',0,...
            'Nsamples',NevalPoints,...
            'Nlines',1);
        % check termination criteria. TODO: define a new termination
        % criterion for this case
        %         SexitFlag=checkTermination(Xobj,Xpf);
        SexitFlag=['The failure probability happens to be ' num2str(normcdf(-mostProbablePointNorm0)) ' for this realization. ' ...
            'Lines computed ' num2str(Xpf.Nlines) ...
            '; Max Lines : ' num2str(Xobj.Nlines)];
        OpenCossan.cossanDisp(SexitFlag,3);
        % collect the results
        XsimOut=XpartialSimData;
    else
        SexitFlag=[];          % Exit flag
    end
    VnumPointsLine(1)=XpartialSimData.Nsamples;
    VlineNumber(1)=1;
    VlineIndex(1)=0;
end

% Initialise counter
% iDirectionUpdated=0;   % number of directional updates


OpenCossan.cossanDisp('[AdvancedLineSampling:computeFailureProbability] Start AdaptiveLineSampling analysis',3)
%% BEGIN Advanced Line Sampling simulation
while isempty(SexitFlag)
    
    
    Xobj.ibatch = Xobj.ibatch + 1;
    
    % Lap time for each batch
    OpenCossan.setLaptime('description',[' Batch #' num2str(Xobj.ibatch)]);
    
    % Compute the number of lines for each batch
    if Xobj.ibatch==Xobj.Nbatches || Xobj.Nlinexbatch==0
        Nlines=Xobj.Nlinelastbatch;
    else
        Nlines=Xobj.Nlinexbatch;
    end
    %% Simulation with Adaptive Line Sampling
    %% Prepare Samples
    % Generate Nline random vectors in the Standard Normal Space
    Xs=Xobj.sample('Xinput',Xinput);
    Mssns=transpose(Xs.MsamplesStandardNormalSpace);
    
    SstringFormat=Xobj.makeString4TextFile('%1.12e',size(Mssns,1));
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % write constellation points coordinates on a text file
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    fid = fopen(fullfile(Xobj.StempPath,'MconstellationPoints.txt'), 'a');
    fprintf(fid, SstringFormat, Mssns);
    fclose(fid);
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    OpenCossan.cossanDisp([num2str(Nlines) ' lines initialized '],3)
    
    % it is necessary to check if a line has already been processed
    CindexProcessedLines=cell(1,Nlines);
    % initialise cell to collect the distances from the limit state to
    % compute the line probabilities
    CdistanceLimitState =cell(1,Nlines);
    % initialise cell to collect the state flags from the line search
    % analysis to compute the line probabilities
    CstateFlags =cell(1,Nlines);
    
    % initialise condition on the update of direction
    if sign(mostProbablePointNorm0)==-1
        LdirectionalUpdate=true;
    else
        LdirectionalUpdate=false;
    end
    
    VdistancesFromOrthPlane=zeros(1,Nlines*Xobj.NmaxPoints);
    VnormPointsSNS=zeros(1,Nlines*Xobj.NmaxPoints);
    %% PROCESS LINES
    %process lines for computing the probability; this lines shall not
    %include the first line passing through the origin
    VdistancesFromOrthPlane(1:sum(VnumPointsLine))=Tline0.Vdistances;
    VnormPointsSNS(1:sum(VnumPointsLine))=sqrt(sum((Tline0.Vdistances'*Valpha').^2,2))';
    istart=sum(VnumPointsLine)+1;
    mostProbablePointNorm=mostProbablePointNorm0;
    for iLine=1:Xobj.Nlines
        
        if iLine==1
            startingDistance=mostProbablePointNorm;
            lineIndexNext=0;
        else
            startingDistance=Tline.distanceLimitState;
        end
        
        % select a point (or index) and project it onto the hyperplane
        % get the index of the next line to be processed
        [VlineHyperPlanePoint,lineIndex,lineIndexNext,CindexProcessedLines]=...
            projectPoints(Xobj,...
            'MsampleSNS',Mssns,...
            'Valpha',Valpha,...
            'LdirectionalUpdate',LdirectionalUpdate,...
            'iLine',iLine,...
            'CindexProcessedLines',CindexProcessedLines,...
            'lineIndexNext',lineIndexNext);
        
        OpenCossan.cossanDisp(strcat('* Starting analysis on line: ',...
            num2str(iLine),'/',num2str(Nlines)),3)
        
        % Call the model to retrieve all the information on the current
        % line. This method computes a new value of the important
        % direction if any update is found. The new value of the
        % id is then updated in the object.
        [Xobj,Tline,XlineSimOut,XsamplesTemp]=...
            exploitLine(Xobj,Xtarget,...
            'reliabilityIndex',mostProbablePointNorm,...
            'Valpha',Valpha,...
            'VhyperPlanePoint',VlineHyperPlanePoint,...
            'startingDistance',startingDistance,...
            'lineNumber',iLine,...
            'lineIndex',lineIndex);
        
        Xsamples=Xsamples.add('Xsamples',XsamplesTemp);
        
        VnumPointsLine(iLine+1)=XlineSimOut.Nsamples;
        iend=istart+XlineSimOut.Nsamples-1;
        VdistancesFromOrthPlane(istart:iend)=Tline.Vdistances;
        VnormPointsSNS(istart:iend)=sqrt(sum((repmat(VlineHyperPlanePoint,XlineSimOut.Nsamples,1)+...
            Tline.Vdistances'*Valpha').^2,2))';
        
        % Output the distance of the state boundary on the current line
        VdistanceLimitState(iLine+1)=Tline.distanceLimitState;
        % Output the norm of the state boundary on the current line
        VlimitStateNorm(iLine+1)=norm(Tline.VstatePoint);
        % Store the direction number
        VdirectionNumber(iLine+1)=directionNumber;
        % Store logical for direction update
        Lupdate(iLine+1)=Tline.LdirectionalUpdate;
        % Store the line number
        VlineNumber(iLine+1)=iLine+1;
        % Store the line index
        VlineIndex(iLine+1)=Tline.lineIndex;
        
        % collect distance
        CdistanceLimitState{iLine}=Tline.distanceLimitState;
        % collect state flag
        CstateFlags{iLine}=Tline.stateFlag;
        
        % Collect Outputs and merge results
        if ~isempty(XpartialSimData)
            XpartialSimData=XpartialSimData.merge(XlineSimOut);
        else
            XpartialSimData=XlineSimOut;
        end
        
%         LdirectionalUpdate=Tline.LdirectionalUpdate;
%         VdirectionalUpdate(iLine+1)=double(LdirectionalUpdate);
        
%         % If a new important direction is found, update it for the
%         % next line
%         if LdirectionalUpdate
%             % display counter of updates
%             iDirectionUpdated=iDirectionUpdated+1;
%             OpenCossan.cossanDisp(sprintf('*** Important Direction Updated %i times',iDirectionUpdated),2)
%         end
        
        % update the direction
        if Tline.LdirectionalUpdate
            directionNumber=directionNumber+1;
%             iDirectionUpdated=iDirectionUpdated+1;
            OpenCossan.cossanDisp(sprintf('*** Important Direction Updated %i times',directionNumber),2)
            if directionNumber>Xobj.NmaxDirectionalUpdates
                % do not update if number of directional updates is > than
                % maximum allowed
%                 Valpha=Tline.Valpha;
            else
                % update direction and most probable point norm
                mostProbablePointNorm=Tline.mostProbablePointNormNew;
                Valpha=Tline.ValphaNew;
            end
        end
        
        istart=iend+1;
    end %end Loop over lines
    
    if ~LprocessZeroLine % remove first entries if the zero line was not processed
        % number of sample per line
        VnumPointsLine(1)=[]; 
        % distance of the state boundary on the current line
        VdistanceLimitState(1)=[];
        % norm of the state boundary on the current line
        VlimitStateNorm(1)=[];
        % direction number
        VdirectionNumber(1)=[];
        % logical for direction update
        Lupdate(1)=[];
        % line number
        VlineNumber(1)=[];
        % line index
        VlineIndex(1)=[];
    end
    
    VdistancesFromOrthPlane=VdistancesFromOrthPlane(1:XpartialSimData.Nsamples);
    VnormPointsSNS=VnormPointsSNS(1:XpartialSimData.Nsamples);
    
%     XlineSamplingOutput=LineSamplingOutput;
%     XlineSamplingOutput=XlineSamplingOutput.mergeSimulationData(XpartialSimData);
    
    % Create the LineSamplingOutput object for postprocessing
    XlineSamplingOutput=LineSamplingOutput('LadaptiveLineSampling',true,...
        'SperformanceFunctionName',Xtarget.SperformanceFunctionVariable,....
        'VnumPointLine',VnumPointsLine,...
        'Vnorm',VnormPointsSNS,...
        'VdistanceOrthogonalPlane',VdistancesFromOrthPlane,...
        'VdirectionNumber',VdirectionNumber,...
        'VlimitStateDistance',VdistanceLimitState,...
        'VlimitStateNorm',VlimitStateNorm,...
        'Lupdate',Lupdate,'VlineIndex',VlineIndex,...
        'VlineNumber',VlineNumber,...
        'VinitialDirectionSNS',Valpha0,...
        'VlastDirectionSNS',Valpha,...
        'SmainPath',Xobj.StempPath,...
        'initialMostProbablePointNorm',mostProbablePointNorm0,...
        'lastMostProbablePointNorm',mostProbablePointNorm,...
        'Xsimulationdata',XpartialSimData,...
        'Xinput',Xinput,...
        'Table',XpartialSimData.TableValues); 
    
%     %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%     % write coordinates of the important direction on text
%     %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%     fid = fopen(fullfile(Xobj.StempPath,'vlastimportantdirection.txt'), 'a');
%     fprintf(fid, SstringFormat, Valpha(:)');
%     fclose(fid);
%     %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    % delete global variable
%     clear('global','iUpdates');
    
    % Extract the values of the performance function
%     VgLine=XpartialSimData.getValues('Sname',Xtarget.XperformanceFunction.Soutputname);
    % count total number of evaluations
    Nevaluations=XpartialSimData.Nsamples;
    
    % Compute line (partial) probabilities. Line probabilities are
    % computed based on the line length between the hyperplane and the
    % state boundary.
    % Final estimation of probability is then obtained doing the mean
    % of single line probabilities.
    [pfhat,variancepf]=...
        computeLineProbabilities(Xobj,CdistanceLimitState,CstateFlags,Lupdate);
    
    % Negative reliability index means that the failure probability is the
    % one-complement of the avaraged probability. 
    if stateFlag0==2
        pfhat=1-pfhat;
    end
    %% Export SimulationData
    if ~Xobj.Lintermediateresults
        XsimOut(Xobj.ibatch)=XpartialSimData; %#ok<AGROW>
    else
        Xobj.exportResults('XlineSamplingOutput',XlineSamplingOutput);
        % Keep in memory only the SimulationData of the last batch
        XsimOut=XpartialSimData;
    end
    
    % Move results to the simulation folder
    SworkingPath=OpenCossan.getCossanWorkingPath;
    XlineSamplingOutput.SmainPath=[SworkingPath,filesep,Xobj.SbatchFolder,filesep,Xobj.SfolderName];
    movefile(Xobj.StempPath,XlineSamplingOutput.SmainPath);
    
    %% Compute the Probability of Failure
    % Create the Failure Probability object
    Xpf = FailureProbability('CXmembers',{Xtarget},...
        'Smethod','AdaptiveLineSampling',...
        'pf',pfhat,'variancepf',variancepf,...
        'Nsamples',Nevaluations,...
        'Nlines',Xobj.Nlines);
    
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
XsimOut(end).SbatchFolder=[OpenCossan.getCossanWorkingPath filesep Xobj.SbatchFolder];

OpenCossan.setLaptime('description','End computeFailureProbability@AdaptiveLineSampling');

% Restore Global Random Stream
restoreRandomStream(Xobj);