function Xobj=initialiseImportantDirection(Xobj,Xtarget)
% INITIALISEIMPORTANTDIRECTION This method initialises the important
% direction based on the information provided by the user. If a matrix of
% state points exists, then the important direction is assigned based on
% the most probable point; if a matrix of failure points is passed(and no
% state points exist) the important direction is assigned based on the
% centre of mass of the failure points; if neither a matrix of state nor
% failure points exists, then the i.direction is assigned recomputing the
% gradient in the Standard Normal Space.
% Note that the gradient in SNS does not coincide with the gradient in the
% Physical Space. In fact, in SNS the gradient (in opposite sign) is
% directed towards probable points and not just towards the limit state.
%% Import cossan classes
import opencossan.sensitivity.*

%% Check inputs
opencossan.OpenCossan.cossanDisp('AdaptiveLineSampling: Initialise Important Direction',3)

% here we go
[Xobj,Xinput]=checkInputs(Xobj,Xtarget);

% name of the performance function
% SperformanceFunctionName=Xtarget.XperformanceFunction.Soutputname;

% In case the direction is user-defined, keep track of the rv index to
% remove the intervals.
[~,~,rvIndex]=intersect(Xinput.Names,Xinput.RandomVariableNames,'stable');
%% Calculate the important direction
% Check if an important direction already exists
if ~isempty(Xobj.VdirectionSNS)
    Valpha=Xobj.VdirectionSNS;
    Valpha=Valpha(:)/norm(Valpha);
elseif ~isempty(Xobj.VdirectionPHY)
    % important direction defined in the physical space
    % REMEMBER: THE ORIGIN OF THE SNS IS THE MEDIAN STATE
    VmedianState=Xinput.getStatistics('CSstatistics',{'median'});
    VcandidatePoint=VmedianState(:)+Xobj.VdirectionPHY(rvIndex);
    VcandidatePointStandardnormal=Xinput.map2stdnorm(VcandidatePoint);
    Valpha=VcandidatePointStandardnormal(:)/norm(VcandidatePointStandardnormal);
elseif ~isempty(Xobj.VpointCoordPHY)
    % point in the failure domain defined
    VcandidatePointStandardnormal=Xinput.map2stdnorm(Xobj.VpointCoordPHY(:,rvIndex));
    Valpha=VcandidatePointStandardnormal(:)/norm(VcandidatePointStandardnormal);
elseif ~isempty(Xobj.VimportantTails)
    % important tails defined
    % REMEMBER: THE ORIGIN OF THE SNS IS THE MEDIAN STATE
    [~,Vstds]=Xinput.getMoments;
    VcoordsPHY=Vstds.*Xobj.VimportantTails;
    VmedianState=Xinput.getStatistics('CSstatistics',{'median'});
    % pick the point one st.deviation away from the median
    VcandidatePoint=VmedianState(:)+VcoordsPHY(:);
    VcandidatePointStandardnormal=Xinput.map2stdnorm(VcandidatePoint);
    Valpha=VcandidatePointStandardnormal(:)/norm(VcandidatePointStandardnormal);
else
    Xlsfd=LocalSensitivityFiniteDifference('Xtarget',Xtarget, ...
    'Coutputnames',{Xtarget.XperformanceFunction.Soutputname});
    % Compute the Indeces
    Xinde = Xlsfd.computeIndices;
    Valpha= -Xinde.Valpha;
end

% assign working direction and exit
Xobj.VdirectionSNS=Valpha;

return