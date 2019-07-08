function Cout = evaluateFunction(Xinput,varargin)
%EVALUATEFUNCTION evaluate the function defined in the Input object based
%on the current values of the random variables stored in the of the Samples and
%the DesignVariables
%
% Revised by EP
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================


%% Default value
Cfun    = Xinput.CnamesFunction;

%% argument check
OpenCossan.validateCossanInputs(varargin{:});

% Process Input
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'sname'}
            Cfun=varargin(k+1);
        case {'cnames'}
            Cfun=varargin{k+1};
        otherwise
            error('openCOSSAN:Input:evaluateFunction', ...
                ['PropertyName: ' varargin{k} ' not allowed'])
    end
end

%% Evaluate Function
Nfunctions=length(Cfun);
% preallocate memory
if ~isempty(Xinput.Xsamples)
    Cout    = cell(Xinput.Nsamples,Nfunctions);   %cell to store values
else
    Cout    = cell(1,Nfunctions);
end

for ifun=1:Nfunctions
    Mout =Xinput.Xfunctions.(Cfun{ifun}).evaluate(Xinput);
    for n=1:size(Mout,1)
        Cout{n,ifun}=Mout(n,:);
    end
end

