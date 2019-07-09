function checkConsistency(Xobj)
%checkConsistency   This private method checks the consistency of the
%object DesignPoint
%
%   MANDATORY ARGUMENTS:
%   - Xobj   : DesignPoint object
%
%
%   EXAMPLE:
%
%       checkConsistency(Xobj)
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% =====================================================

%% 1.   Check that probabilistic model has been defined
if isempty(Xobj.Xinput)  
    error('openCOSSAN:outputs:DesignPoint',...
        'no Input object has been passed');
end

%% 2.   Check that design point has been defined
if isempty(Xobj.VDesignPointPhysical),
    error('openCOSSAN:outputs:DesignPoint',...
        'no design point has been passed');
end

%% 3.   Check length of design point
if length(Xobj.Xinput.CnamesRandomVariable) ~= length(Xobj.VDesignPointPhysical)
    error('openCOSSAN:outputs:DesignPoint',...
        'length of defined design point and number of random variables in associated performance function do not match');
end
