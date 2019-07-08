function [Mout varargout] = getValues(Xobj,varargin)
%getValues Retrieve the values of a variable present in the
%           SimulationOutput Object
%
%   MANDATORY ARGUMENTS
%   * Names of the variable passed in pair
%
%   OUTPUT
%   - Mout: array of the values of the requested variables 
%   - varargout{1}: vector of the size of variable Sname
%
%   USAGE
%   Cout = Xobj.getValues('Sname','NameoftheVariable')
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% =====================================================

%% Validate input arguments
validateCossanInputs(varargin{:})

if Xobj.Nsamples>1e5
    warning('openCOSSAN:outputs:SimulationOutput:getValues',...
        'Please use Batches... this operation may become too slow')
end

%% 1.   Argument Check
if ~mod(nargin,2),
    error('openCOSSAN:outputs:SimulationOutput:getValues',...
        'each FIELD should be followed by its corresponding VALUE');
end

Sname = [];
Vsize=[];

for k=1:2:nargin-1,
    switch lower(varargin{k})
        case 'sname'
            %check input
            Cnames = varargin{k+1};
        case 'cnames'
            %check input
            Cnames = varargin{k+1};
        otherwise
            warning('openCOSSAN:outputs:SimulationOutput:getValues', ...
                ['PropertyName: ' varargin{k} ' ignored'])
    end
end

if isempty(Cnames)
    error('openCOSSAN:SimulationOutput:getValues',...
        'It is a mandatory to specify at least an Output name ')
end

Vfield=strcmp(Xobj.Cnames,Cnames{1});

for n=2:length(Cnames)
    pos= strcmp(Xobj.Cnames,Cnames{n});
    Vfield(pos)=1;
end


%% Check if the values are also store in a Matrix format
if isempty(Xobj.Mvalues)
    %% Preallocate memory
    Cout=struct2cell(Xobj.Tvalues);
    Cout(~Vfield,:)=[];

    if isempty(Cout)
        warning('openCOSSAN:outputs:SimulationOutput:getValues', ...
            ['Variable ' Sname ' not available'])
        Mout=[];
    else
        Vsize=size(Cout{1});
        if ~isvector(Cout{1})
            for n=1:length(Cout)
                Cout{n}=Cout{n}(:);
            end
        end
            Mout=myCell2Mat(Cout)';
    end
    
else
    Mout=Xobj.Mvalues(:,Vfield);
end

varargout{1}=Vsize;
