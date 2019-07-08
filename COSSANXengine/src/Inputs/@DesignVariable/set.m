function Xobj = set(Xobj,varargin)
% SET This method is used to change the value of a property of the DesignVariable
% object
%

% Copyright 1993-2011, University of Innsbruck
% Author: Edoardo Patelli

% Check input arguments
OpenCossan.validateCossanInputs(varargin{:});

% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        
        case {'designvariablevalue','value'}
            Xobj.value = varargin{k+1};
        case 'lowerbound'
            Xobj.lowerBound = varargin{k+1};
        case 'upperbound'
            Xobj.upperBound = varargin{k+1};
        case 'vsupport'
            Xobj.Vsupport = varargin{k+1};
            
        otherwise
            error('COSSAN:DesignVariable:set',...
                'The PropertyName %s is not available', ...
                varargin{k})
    end
end


