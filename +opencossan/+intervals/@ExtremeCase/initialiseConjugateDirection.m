function Xobj=initialiseConjugateDirection(Xobj,Xtarget)
% INITIALISEIMPORTANTDIRECTION This method initialises the conjugate
% direction based on the information provided by the user. 

%% Check inputs
OpenCossan.cossanDisp('ExtremeCase: Initialise Conjugate Direction',3)

% extract input object
Xinput=Xtarget.Xmodel.Xinput;

% name of the performance function
SperformanceFunctionName=Xtarget.XperformanceFunction.Soutputname;

if XextremeCase.LuseGradientToInitialise
    % compute the gradient (Physical Space) at the median state
    % construct the Local Sensitivity by Finite Difference
    Xlsfd=LocalSensitivityFiniteDifference(...
        'Xtarget',XprobabilisticModel,'Coutputnames',{SperformanceFunctionName});
    % compute the Gradient
    Xgradient = Xlsfd.computeGradient;
    VgradientDescend= -Xgradient.Valpha;
    VconjugateDirection=VgradientDescend;
    %                 % compute the Gradient in SNS
    %                 Xindices = Xlsfd.computeIndices;
    % update important direction based on the conjugate direction
    XadaptiveLineSampling.Vdirection= VgradientDescend;
elseif XextremeCase.LuseMCtoInitialize
    % run a Monte Carlo simulation. If no fail points are
    % identified use Monte Carlo information to approximate
    % the gradient
    
    % TODO
elseif XextremeCase.LuseExistingDirection
    % use the existing direction to initialise the conjugate
    % direction
    VinitialDirection=Xobj.VexistingDirection;
end





% check if an important direction already exists
if isempty(Xobj.Valpha) && ~isempty(Xobj.Vdirection) % important direction is defined in the physical space
    
    VmedianState=Xinput.getStatistics('CSstatistics',{'median'});
    VcandidatePoint=VmedianState(:)+Xobj.Vdirection;
    VcandidatePointStandardnormal=Xinput.map2stdnorm(VcandidatePoint);
    Valpha=VcandidatePointStandardnormal(:)/norm(VcandidatePointStandardnormal);
    
elseif ~isempty(Xobj.MstatePoints) % use state points to intialise the important direction
    
    % matrix of limit state points size=(Nrv,Npoints)
    MstatePoints=Xobj.MstatePoints;
    % names of random variable sets
    Cnames = Xinput.CnamesRandomVariableSet;
    % total number of random variable sets defined
    Nrvsets = length(Cnames);
    
    NlimitStatePoints=size(MstatePoints,2);
    MpdfStatePoints=zeros(NlimitStatePoints,Nrvsets);
    istart=1;
    % loop over all random variable sets
    for k=1:Nrvsets % evaluate pdf for every random variable set
        NrvCurrentSet=Xinput.Xrvset.(Cnames{k}).Nrv;
        iend=istart+NrvCurrentSet-1;
        XcurrentRVs=Xinput.Xrvset.(Cnames{k});
        MpdfStatePoints(:,k)=...
            XcurrentRVs.evalpdf('MsamplesPhysicalSpace',MstatePoints(istart:iend,:)');
        istart=iend;
    end
    % evluate the pdf of separate sets, which by definition are
    % independent,thus the pdf is the product of masses (or densities)
    VpdfStatePoints=prod(MpdfStatePoints,2);
    
    % identify the limit state point with highest probability content
    [~,maxIndex]=max(VpdfStatePoints);
    VcandidatePoint=MstatePoints(:,maxIndex);
    VcandidatePointStandardnormal=Xinput.map2stdnorm(VcandidatePoint);
    
    % assign important direction accordingly
    Valpha=VcandidatePointStandardnormal(:)/norm(VcandidatePointStandardnormal);
    
elseif ~isempty(Xobj.MfailurePoints) % use failure points to initialise the important direction
    
    MfailurePoints=Xobj.MfailurePoints;
    VfailureCentreMass=mean(MfailurePoints,1);
    VfailureCentreMassStanardnormal=Xinput.map2stdnorm(VfailureCentreMass);
    Valpha=VfailureCentreMassStanardnormal(:)/norm(VfailureCentreMassStanardnormal);
    
else % initialise direction recomputing the gradient of the performance in SNS
    
    Xlsfd=LocalSensitivityFiniteDifference(...
        'Xtarget',Xtarget,'Coutputnames',{SperformanceFunctionName});
    XlocalSensitivityMeasure=Xlsfd.computeIndices();
    Valpha=-XlocalSensitivityMeasure.Valpha;
    
end

Xobj.Valpha=Valpha;


return