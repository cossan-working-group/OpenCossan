function [Xobj varargout] = findMinimalCutSets(Xobj,varargin)
% FINDMINIMALCUTSETS This function identify the mininal cut set of the
% FaultTree. The minimalcutsets are stored as a field of the FaultTree
% object.
%
% The function return a FaultTree object

%% Initialize variables
Mfullcutsets=Xobj.McutSets;

%% Process inputs
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'mcutsets'}
                        Mfullcutsets=varargin{k+1};
                    otherwise
                        error('openCOSSAN:reliability:FaultTree:findMinimalCutSets',...
                            'Field name not allowed');
                end
            end


%% Check if the CutSets have already identified
if isempty(Mfullcutsets)
    Xobj=Xobj.findCutSets;
    Mfullcutsets=Xobj.McutSets;
end

%% Reduce the cut-sets to the minimal cut-set
Ncutset=size(Mfullcutsets,2);
Mminimal=Mfullcutsets;

Vrank=sum(Mfullcutsets,1);
Vposition=find(Mfullcutsets==1);

% Remove duplicate inputs
for ics=1:Ncutset
    % Extract names of the Basic Events
    Cnames=Xobj.CnodeNames(Mfullcutsets(:,ics));

    for icheck=1:length(Cnames)-1
           % Find if the current basic events appears more then once in the
           % cut-set
           Vloc = strcmp(Cnames(icheck), Cnames(icheck+1:end));
           Vindex=find(Vloc)+icheck;
           if ~isempty(Vindex)
            % Remove duplicate basic events from the cut-set
            Mminimal(Vposition(Vindex+sum(Vrank(1:ics-1))))=0;
           end
    end
    CnamesEvents{ics}=Xobj.CnodeNames(Mminimal(:,ics)); %#ok<AGROW>
end

% Re-compute the rank of the cut-sets
Vrank=sum(Mminimal,1);
[dummy Vindex]=sort(Vrank); %#ok<ASGLU>

% Check if the cut-set of minimal order are 
LMinimal=true(Ncutset,1);
for outerloop=1:Ncutset
    for innerloop=outerloop+1:Ncutset
        LnoMinimal=ismember(CnamesEvents{Vindex(outerloop)},CnamesEvents{Vindex(innerloop)});
        
        if all(LnoMinimal)
            LMinimal(Vindex(innerloop))=false;
        end
    end
end

% Remove no minimal cut set
Mminimal(:,~LMinimal)=[];

% Update FaultTree object
Xobj.MminimalCutSets=Mminimal;

Xobj.CminimalCutSets=[];
for imcs=1:size(Mminimal,2)
    Xobj.CminimalCutSets{imcs}=Xobj.CnodeNames(Mminimal(:,imcs));
end


if nargout>1
    varargout{1}=Xobj.CminimalCutSets;
end

end
