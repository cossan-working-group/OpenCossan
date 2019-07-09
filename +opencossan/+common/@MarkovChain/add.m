function Xmkv = add(Xmkv,varargin)
%ADD  Increase the length of the Markov Chains
%
% This method add new samples of the Markov Chain
%
% The optional inputs is:
% * Npoints  = length of the chain
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =====================================================
opencossan.OpenCossan.validateCossanInputs(varargin{:})

Npoints=0;

%% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'npoints','nchainlength'}
            Npoints = varargin{k+1};
        otherwise
            error('openCOSSAN:MarkovChain:add',...
                ['PropertyName ' varargin{k} ' not allowed'])
    end
end


%% Construct chain
for c=1:Npoints
    
    XsampleOffSpring = offspring(Xmkv);
    
    % Add Samples to the MarkovChain
    Xmkv.Xsamples(end+1)=XsampleOffSpring;
end




