function [Xobj,XlsData]=computeReliabilityIndex(Xobj,Xtarget)

%% Check inputs
OpenCossan.cossanDisp('AdvancedLineSampling: Check inputs',3)

[Xobj,Xinput]=checkInputs(Xobj,Xtarget);

assert(isa(Xinput,'Input'),...
    'openCOSSAN:LineSampling',...
    'Please provide a valid Input object');

OpenCossan.cossanDisp('AdvancedLineSampling: Compute reliability index',3)

assert(~isempty(Xobj.Valpha),'openCOSSAN:AdvancedLineSampling',...
    'Please provide the object %s with an important direction',...
    class(Xobj))

% Retrieve properties from the object
Nvars=length(Xobj.Valpha);

% Process the zero-line, i.e. the line passing through the origin
[~,~,XlsData]=...
    exploitLine(Xobj,Xtarget,...
    'VlineHyperPlanePoint',zeros(Nvars,1));

% Assign distance from origin to the limit state boundary
distanceLimiState=XlsData.Tlines.Line_0.distanceLimitState;

% Assign reliability index
if XlsData.Tlines.Line_0.stateFlag==0 
    reliabilityIndex=abs(distanceLimiState);
    OpenCossan.cossanDisp('Reliability Index found efficiently',3)
elseif XlsData.Tlines.Line_0.stateFlag==1 
    reliabilityIndex=abs(distanceLimiState);
elseif XlsData.Tlines.Line_0.stateFlag==2 
    reliabilityIndex=abs(distanceLimiState);
    OpenCossan.cossanDisp('Intersection met on the negative half-space',3)
elseif XlsData.Tlines.Line_0.stateFlag==3
    reliabilityIndex=[];
    OpenCossan.cossanDisp('Reliability Index not found!',3)
elseif XlsData.Tlines.Line_0.stateFlag==4
    reliabilityIndex=[];
    OpenCossan.cossanDisp('Reliability Index not found!',3)
end

Xobj.reliabilityIndex=reliabilityIndex;

return