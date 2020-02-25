function [Xpf,XsimOut,XlineData] = computeFailureProbability(Xobj,Xtarget)
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
global iUpdates
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
Valpha=Xobj.Valpha;

%% Compute reliability index
if isempty(Xobj.reliabilityIndex)
    % Initialise reliability index
    [Xobj,XlineSimOut,reliabilityIndex,Valpha,stateFlag0,NevalPoints]=Xobj.computeReliabilityIndex(Xtarget);
    XpartialSimOut=XlineSimOut;
    if isinf(reliabilityIndex)
        % stop the process if no limit state is met on the given direction
        % Create the Failure Probability object
        Xpf = FailureProbability('CXmembers',{Xtarget},...
            'Smethod','AdaptiveLineSampling',...
            'pf',normcdf(-reliabilityIndex),'variancepf',0,...
            'Nsamples',NevalPoints,...
            'Nlines',1);
        % check termination criteria. TODO: define a new termination
        % criterion for this case
        %         SexitFlag=checkTermination(Xobj,Xpf);
        SexitFlag=['The failure probability happens to be ' num2str(normcdf(-reliabilityIndex)) ' for this realization. ' ...
            'Lines computed ' num2str(Xpf.Nlines) ...
            '; Max Lines : ' num2str(Xobj.Nlines)];
        OpenCossan.cossanDisp(SexitFlag,3);
        % collect the results
        XsimOut=XpartialSimOut;
    else
        SexitFlag=[];          % Exit flag
    end
end

% % Line Sampling Data object
% XlineSamplingData=Xobj.XlineSamplingData;

% if isempty(XlineSamplingData)
%     XlineSamplingData=XlSData0;
% elseif isempty(XlineSamplingData.SperformanceFunctionName)
%     XlineSamplingData=XlSData0.addStatePoints...
%         (XlineSamplingData.CMstatePoints,...
%         'Laddleft',true);
% else
%     % Merge results
%     XlineSamplingData=merge(XlineSamplingData,XlSData0);
% end

% Initialise counter
iDirectionUpdated=0;   % number of directional updates


OpenCossan.cossanDisp('[AdvancedLineSampling:computeFailureProbability] Start AdaptiveLineSampling analysis',3)
%% BEGIN Advanced Line Sampling simulation
while isempty(SexitFlag)
    
    
    Xobj.ibatch = Xobj.ibatch + 1;
    
    % Lap time for each batch
    OpenCossan.setLaptime('Sdescription',[' Batch #' num2str(Xobj.ibatch)]);
    
    % Compute the number of lines for each batch
    if Xobj.ibatch==Xobj.Nbatches || Xobj.Nlinexbatch==0
        Nlines=Xobj.Nlinelastbatch;
    else
        Nlines=Xobj.Nlinexbatch;
    end
    %% Simulation with Adaptive Line Sampling
    %% Prepare Samples
    % Generate random vectors in the Standard Normal Space
    Xs=Xobj.sample('Xinput',Xinput);
    Mssns=transpose(Xs.MsamplesStandardNormalSpace);
    
    
    SstringFormat=Xobj.makeString4TextFile('%1.12e',size(Mssns,1));
    % store values in a text file
    fid = fopen(fullfile(Xobj.StempPath,'mconstellationpoints.txt'), 'a');
    fprintf(fid, SstringFormat, Mssns);
    fclose(fid);
    
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
    if sign(reliabilityIndex)==-1
        LdirectionalUpdate=true;
    else
        LdirectionalUpdate=false;
    end
    VdirectionalUpdate=false(1,Nlines);
    %% PROCESS LINES
    %process lines for computing the probability; this lines shall not
    %include the first line passing through the origin
    for iLine=1:Xobj.Nlines
        
        if iLine==1
            startingDistance=reliabilityIndex;
            lineIndexNext=0;
        else
            startingDistance=distanceLimitState;
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
        [Xobj,Tline,XlineSimOut]=...
            exploitLine(Xobj,Xtarget,...
            'reliabilityIndex',reliabilityIndex,...
            'Valpha',Valpha,...
            'VhyperPlanePoint',VlineHyperPlanePoint,...
            'startingDistance',startingDistance,...
            'lineNumber',iLine,...
            'lineIndex',lineIndex);
        
        % update the direction
        if iUpdates>Xobj.NmaxDirectionalUpdates
            Valpha=Tline.Valpha;
        else
            Valpha=Tline.ValphaNew;
        end
            
        reliabilityIndex=Tline.reliabilityIndex;
        
        % Output the distance of the state boundary on the current line
        distanceLimitState=Tline.distanceLimitState;
        % collect distance
        CdistanceLimitState{iLine}=distanceLimitState;
        % collect state flag
        CstateFlags{iLine}=Tline.stateFlag;
        
        % Collect Outputs and merge results
        if ~isempty(XpartialSimOut)
            XpartialSimOut=XpartialSimOut.merge(XlineSimOut);
        else
            XpartialSimOut=XlineSimOut;
        end
        
        
        LdirectionalUpdate=Tline.LdirectionalUpdate;
        VdirectionalUpdate(iLine)=double(LdirectionalUpdate);
        % If a new important direction is found, update it for the
        % next line
        if LdirectionalUpdate
            % display counter of updates
            iDirectionUpdated=iDirectionUpdated+1;
            OpenCossan.cossanDisp(sprintf('*** Important Direction Updated %i times',iDirectionUpdated),2)
        end
    end %end Loop over lines
    
    
    % store coordinates of the important direction
    fid = fopen(fullfile(Xobj.StempPath,'vlastimportantdirection.txt'), 'a');
    fprintf(fid, SstringFormat, Valpha(:)');
    fclose(fid);
    
    
    % delete global variable
    clear('global','iUpdates');
    
    
    % Extract the values of the performance function
    VgLine=XpartialSimOut.getValues('Sname',Xtarget.XperformanceFunction.Soutputname);
    % count total number of evaluations
    Nevaluations=length(VgLine);
    
    % Compute line (partial) probabilities. Line probabilities are
    % computed based on the line length between the hyperplane and the
    % state boundary.
    % Final estimation of probability is then obtained doing the mean
    % of single line probabilities.
    [pfhat,variancepf]=...
        computeLineProbabilities(Xobj,CdistanceLimitState,CstateFlags,VdirectionalUpdate);
    
    % Negative reliability index means that the failure probability is the
    % one-complement of the avaraged probability. 
    if stateFlag0==2
        pfhat=1-pfhat;
    end
    
    
    %% Export SimulationData
    if ~Xobj.Lintermediateresults
        XsimOut(Xobj.ibatch)=XpartialSimOut; 
    else
        Xobj.exportResults('Xsimulationoutput',XpartialSimOut);
        % Keep in memory only the SimulationData of the last batch
        XsimOut=XpartialSimOut;
    end
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

OpenCossan.setLaptime('Sdescription','End computeFailureProbability@AdaptiveLineSampling');

% Restore Global Random Stream
restoreRandomStream(Xobj);

if nargout>2
    XlineData = LineData('Sdescription','My first Line Data object',...
            'Xals',Xobj,'LdeleteResults',false,...
            'Sperformancefunctionname',Xtarget.XperformanceFunction.Soutputname,...
            'Xinput',Xtarget.Xmodel.Xinput);
end


