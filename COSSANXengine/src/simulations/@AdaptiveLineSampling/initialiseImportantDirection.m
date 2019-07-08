function Xobj=initialiseImportantDirection(Xobj,Xtarget)
% INITIALISEIMPORTANTDIRECTION This method initialises the important
% direction based on the information provided by the user. If a matrix of
% state points exists, then the important direction is assigned based on
% the most probable point; if a matrix of failure points is passed help(and no
% state points exist) the important direction is assigned based on the
% centre of mass of the failure points; if neither a matrix of state nor
% failure points exists, then the i.direction is assigned recomputing the
% gradient in the Standard Normal Space.
% Note that the gradient in SNS does not coincide with the gradient in the
% Physical Space. In fact, in SNS the gradient (in opposite sign) is
% directed towards probable points and not just towards the limit state.

%% Check inputs
OpenCossan.cossanDisp('AdaptiveLineSampling: Initialise Important Direction',3)

% here we go
[Xobj,Xinput]=checkInputs(Xobj,Xtarget);

% name of the performance function
SperformanceFunctionName=Xtarget.XperformanceFunction.Soutputname;

% In case the direction is user-defined, keep track of the rv index to
% remove the intervals.
[~,~,rvIndex]=intersect(Xinput.Cnames,Xinput.CnamesRandomVariable,'stable');
%% Calculate the important direction
% check if an important direction already exists
if isempty(Xobj.Valpha) && ~isempty(Xobj.Vdirection)
    
    % important direction defined in the physical space
    % REMEMBER: THE ORIGIN OF THE SNS IS THE MEDIAN STATE!
    Vmean=Xinput.getMoments;
    VcandidatePoint=Vmean'+Xobj.Vdirection(rvIndex);
    VcandidatePointStandardnormal=Xinput.map2stdnorm(VcandidatePoint);
    Valpha=VcandidatePointStandardnormal(:)/norm(VcandidatePointStandardnormal);
    
elseif isempty(Xobj.Valpha) && ~isempty(Xobj.VimportancePoint)
    
    % coordinate of an importance point defined in the physical space
    VcandidatePointStandardnormal=Xinput.map2stdnorm(Xobj.VimportancePoint(:,rvIndex));
    Valpha=VcandidatePointStandardnormal(:)/norm(VcandidatePointStandardnormal);
    
elseif ~isempty(Xobj.MstatePointsPHY)
    
    % Use state points to intialise the important direction:
    % matrix of limit state points size=(Nrv,Npoints)
    MstatePoints=Xobj.MstatePointsPHY(:,rvIndex);
    indexnn=~isnan(MstatePoints(:,1));
    % names of random variable sets
    Cnames = Xinput.CnamesRandomVariableSet;
    % total number of random variable sets defined
    Nrvsets = length(Cnames);
    % numbe of state points
    NlimitStatePoints=size(MstatePoints,1);
    % initialise matrix containing density values
    MpdfStatePoints=zeros(NlimitStatePoints,Nrvsets);
    istart=1;
    % loop over all random variable sets
    for k=1:Nrvsets % evaluate pdf for every random variable set
        NrvCurrentSet=Xinput.Xrvset.(Cnames{k}).Nrv;
        iend=istart+NrvCurrentSet-1;
        XcurrentRVs=Xinput.Xrvset.(Cnames{k});
        MpdfStatePoints(indexnn,k)=...
            XcurrentRVs.evalpdf('MsamplesPhysicalSpace',MstatePoints(indexnn,istart:iend));
        istart=iend;
    end
    % evluate the pdf of separate sets, which by definition are
    % independent,thus the pdf is the product of masses (or densities)
    VpdfStatePoints=prod(MpdfStatePoints,2);
    
    % identify the limit state point with highest probability content
    [~,maxIndex]=max(VpdfStatePoints);
    VcandidatePoint=MstatePoints(maxIndex,:);
    VcandidatePointStandardnormal=Xinput.map2stdnorm(VcandidatePoint);
    
    % assign important direction accordingly
    Valpha=VcandidatePointStandardnormal(:)/norm(VcandidatePointStandardnormal);
    
elseif ~isempty(Xobj.MfailurePointsPHY)
    
    % Use failure points to initialise the important direction:
    % matrix of failure points size=(Npoints,Nrv)
    MfailurePoints=Xobj.MfailurePointsPHY(:,rvIndex);
    VfailureCentreMass=mean(MfailurePoints,1);
    % transform to standard normal space
    VfailureCentreMassStanardnormal=Xinput.map2stdnorm(VfailureCentreMass);
    Valpha=VfailureCentreMassStanardnormal(:)/norm(VfailureCentreMassStanardnormal);
    
elseif isempty(Xobj.Valpha)
    
    % initialise direction recomputing the gradient of the performance in SNS
    Xlsfd=LocalSensitivityFiniteDifference(...
        'Xtarget',Xtarget,'Coutputnames',{SperformanceFunctionName});
    XlocalSensitivityMeasure=Xlsfd.computeGradientStandardNormalSpace();
    Valpha=-XlocalSensitivityMeasure.Valpha;
else 
    Valpha=Xobj.Valpha;
end

% assign working direction and exit
Xobj.Valpha=Valpha(:)/norm(Valpha);

return