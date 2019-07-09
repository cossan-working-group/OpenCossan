function Vout = compute(XSimOut,varargin)
%COMPUTE Perform operation of the variable defined in the SimulationData
% object
%
% PropertyName:
% Cnames: cell array containg the name of variables
% Soperation: Specify the arithmetic operation to be performed (accettable
% values are: plus (+) minus (-)
%
%  Example:  Vout=compute('Cnames',{'var1','var2'},'Soperation','-')
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% =====================================================

import opencossan.common.utilities.*

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'cnames'}
            Cnames=varargin{k+1};
        case {'soperation'}
            Soperation=varargin{k+1};
        otherwise
            error('openCOSSAN:SimulationData:compute', ...
                ['PropertyName (' varargin{k} ' ) is not allowed']);
    end
end

Vfield1=strcmp(XSimOut.Cnames,Cnames{1});

assert(sum(Vfield1)==1,'openCOSSAN:SimulationData:compute', ...
    ['The request variable %s is not present in the SimulationData object\nAvailable variables are: ' ...
    sprintf(' %s;',XSimOut.Cnames{:})],Cnames{1})

Vfield2=strcmp(XSimOut.Cnames,Cnames{2});
assert(sum(Vfield2)==1,'openCOSSAN:SimulationData:compute', ...
    ['The request variable %s is not present in the SimulationData object\nAvailable variables are: ' ...
    sprintf(' %s;',XSimOut.Cnames{:})],Cnames{2})

% The data are stored always as Table

    switch Soperation
        case {'minus','-'}
            Vout=XSimOut.TableValues{:,Vfield1}-XSimOut.TableValues{:,Vfield2};
        case {'plus','+'}
            Vout=XSimOut.TableValues{:,Vfield1}+XSimOut.TableValues{:,Vfield2};
    end
end



