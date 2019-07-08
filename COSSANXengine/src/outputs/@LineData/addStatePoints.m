function Xobj=addStatePoints(Xobj,Cpoints,varargin)

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:});

Lleft=false;
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'laddleft'
            Lleft=true;
        otherwise
            error('openCOSSAN:LineSamplingData:addStatePoints',...
                'Field name not allowed');
    end
end %for k

if Lleft
    Xobj.CMstatePoints=[Cpoints,Xobj.CMstatePoints];
else
    Xobj.CMstatePoints=[Xobj.CMstatePoints,Cpoints];
end