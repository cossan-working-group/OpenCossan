function Xobj = split(Xobj,varargin)
%SPLIT SimulationData objects
%
%   MANDATORY ARGUMENTS
%   - Vindices: Indicies of the samples to be extracted
%   - Cmembers: Cell array of the variables to be extracted
%
%   OUTPUT
%   - Xobj: object of class SimulationData
%
%   USAGE
%   Xobj = Xobj.split(PropertyName, PropertyValue, ...)
%
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% =====================================================

Vindices=[];
Cmembers=[];
Cremove=[];


%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%% 1.   Argument Check
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'vindices'
            Vindices=varargin{k+1};
        case {'cmembers', 'cnames'}
            Cmembers=varargin{k+1};   
        case {'cremove', 'cremovenames'}
            Cremove=varargin{k+1};   
        otherwise
          error('openCOSSAN:SimulationData:split',...
          [ varargin{k} ' is not a valid PropertyName']);
    end
end

%% Old names 
ColdNames=Xobj.Cnames;

%% Remove Realizations

if ~isempty(Vindices)
    % Remove realizations from the structure
    Xobj.Tvalues=Xobj.Tvalues(Vindices);
    
    % Remove realizations from the Mvalues
    if ~isempty(Xobj.Mvalues)
        Xobj.Mvalues=Xobj.Mvalues(Vindices,:);
    end
end

%% Remove Variables

if ~isempty(Cmembers)
    Cremove=ColdNames(~strcmp(ColdNames,Cmembers(1)));
    for ires=2:length(Cmembers)
        Cremove(strcmp(Cremove,Cmembers(ires)))=[];
    end
end

if ~isempty(Cremove)
    Xobj.Tvalues=rmfield(Xobj.Tvalues,Cremove);
    
    if ~isempty(Xobj.Mvalues)
        % Remove variables from the Mvalues
        Lpos=zeros(length(ColdNames),1);
        for n=1:length(ColdNames);
            Lpos(n)=any(strcmp(ColdNames(n),Cremove));
        end
        Xobj.Mvalues=Xobj.Mvalues(:,~Lpos);
    end     
end





