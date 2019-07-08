function [Xobj,XsimOut,reliabilityIndex,Valpha,stateFlag0,NevalPoints]=computeReliabilityIndex(Xobj,Xtarget)

%% Check inputs
OpenCossan.cossanDisp('AdaptiveLineSampling: Check inputs',3)

% Xobj=checkInputs(Xobj,Xtarget);

OpenCossan.cossanDisp('AdaptiveLineSampling: Compute reliability index',3)

% Process the zero-line, i.e. the line passing through the origin
[~,Tline,XsimOut]=...
    exploitLine(Xobj,Xtarget,...
    'reliabilityIndex',0,...
    'VhyperPlanePoint',zeros(length(Xobj.Valpha),1));

% Update direction
Valpha=Tline.ValphaNew;

stateFlag0=Tline.stateFlag;

% Recall that in this case the line through the origin of the SNS is
% considered, so: distanceLimiState = normStatePoint = reliabilityIndex

% Assign reliability index
if stateFlag0==0 
    reliabilityIndex=abs(Tline.distanceLimitState);
    OpenCossan.cossanDisp('Reliability Index found efficiently',3)
elseif stateFlag0==1 
    reliabilityIndex=abs(Tline.distanceLimitState);
elseif stateFlag0==2 
    reliabilityIndex=-abs(Tline.distanceLimitState);
elseif stateFlag0==3 % whole line in the safe domain pf=0
    reliabilityIndex=Inf;
    OpenCossan.cossanDisp('Reliability Index not found! The whole line is in safe domain',3)
elseif stateFlag0==4 % whole line in the falure domain pf=1
    reliabilityIndex=-Inf;
    OpenCossan.cossanDisp('Reliability Index not found! The whole line is in failure domain',3)
else
    reliabilityIndex=Inf;
    OpenCossan.cossanDisp('Reliability Index not found!',3)
end

NevalPoints=length(Tline.Vg);

return