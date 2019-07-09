function Xoutput = set(Xoutput,varargin)
%SET Set field(s) of an object of the class DesignPoint
%   
%   The method SET takes one required input, an object DesignPoint.
%   The method then takes a variable number of token value pairs.  These
%   pairs set properties of the object DesignPoint.
%
%   The function SET returns a object DesignPoint.
%
%   MANDATORY ARGUMENTS:
%
%    - Xoutput   : object of the class DesignPoint
%
%   OPTIONAL ARGUMENTS:
%
%   - 'VDesignPointPhysical' : coordinates of the design point in the
%   physical space
%   - 'VDirectionDesignPointStdNormal': coordinates of the design point in
%   the standard normal space
%
%   OUTPUT
%
%    - Xoutput   : object of the class DesignPoint
%
%  EXAMPLE:
%   Xoutput  = set(Xs,'PropertyName','PropertyValue') assigns
%       PropertyValue to the PropertyName of the Xsamples objet
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =====================================================


%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%%  Process arguments passed by the user
for k=1:2:length(varargin)
    switch lower(varargin{k}),
        %3.1.   DesignPoint in physical space
        case {'vdesignpointphysical'},
            if isnumeric(varargin{k+1}),
                Xoutput.VDesignPointPhysical    = varargin{k+1};    %define design point in physical space
            else
                error('openCOSSAN:DesignPoint:set',...
                    'design point must be numeric');
            end
        %3.2.   DesignPoint in standard normal space
        case {'vdesignpointstdnormal'},
            if isnumeric(varargin{k+1}),
                VDesignPointStdNormal   = ...
                    varargin{k+1};  %define design point in standard normal space
            else
                error('openCOSSAN:DesignPoint:set',...
                    'design point must be numeric');
            end
            %define design point in physical space
            Xoutput.VDesignPointPhysical = map2physical(Xoutput.Xinput,VDesignPointStdNormal); 
        %3.3.   Other cases
        otherwise
            warning('openCOSSAN:DesignPoint:set',['argument ' varargin{k} ' has been ignored']);
    end
end

checkConsistency(Xoutput);  %method to check consistency of values set by the user

return
