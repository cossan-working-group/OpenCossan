function [Xobj Xmodes] = validate(Xobj,varargin)

%VALIDATE Summary of this function goes here
%   Detailed explanation goes here

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'nsamples'}
            Nsamples = varargin{k+1};  
        case{'xvalidationinput'}
            Xobj.XvalidationInput = varargin{k+1};
        case{'xvalidationoutput'}
            Xobj.XvalidationOutput = varargin{k+1};    
        otherwise
            error('openCOSSAN:metamodel:calibrate',...
                ['Field name (' varargin{k} ') not allowed']);
    end
end

if exist('Nsamples','var')
    Xobj.XvalidationInput = sample(Xobj.XFullmodel.Xinput,'Nsamples',Nsamples);
end

%% Output of full model

if isempty(Xobj.XvalidationOutput)
    if ~isempty(Xobj.XvalidationInput.Xsamples)
        XSimOut = apply(Xobj.XFullmodel,Xobj.XvalidationInput);
    else
        error('openCOSSAN:metamodel:validation',...
            'XvalidationInput does not contain any samples.');
    end
    for isim = 1:XSimOut.Nsamples
        Xmodesvalidation(isim) = Modes('MPhi',XSimOut.Tvalues(isim).(Xobj.Cnamesmodalprop{2}),...
            'Vlambda',XSimOut.Tvalues(isim).(Xobj.Cnamesmodalprop{1}));
    end
    Xobj.XvalidationOutput = Xmodesvalidation;
end

%% Output of metamodel

Xmodes = apply(Xobj,Xobj.XvalidationInput);

return;

