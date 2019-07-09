function [Xobj varargout]= findCutSets(Xobj)
% FINDMINIMALCUTSETS This function identify the mininal cut set of the
% FaultTree. The minimalcutsets are stored as a field of the FaultTree
% object.
%
% The function return a FaultTree object

if length(Xobj.CnodeNames)>50
    warning('openCOSSAN:reliability:FaultTree',...
        'findMinimalCutSets is not efficient for very large tree');
end

%% Initialize variable

LcurrentCutSet= false(length(Xobj.VnodeConnections),1);
LcheckCutSet=false;
currentCutSet=1; % numebr of cut set
Lcontinue=true;
Ccutset=[];

%% Find the top event
% currentEvent=Top Event
[~, currentEvent]=find(Xobj.VnodeConnections==0); 

while Lcontinue
    
    % find components attached to the topEvent
    [~, indexLeaf]=find(Xobj.VnodeConnections==currentEvent);
    
    opencossan.OpenCossan.cossanDisp([' Processing Leaf #' num2str(indexLeaf)],3)
    
    if length(indexLeaf)==1 % Gate
        switch Xobj.CnodeTypes{indexLeaf}
            case {'AND'}
                currentGate='AND';
            case {'OR'}
                currentGate='OR';
            case {'Input'}
                % The output is connected to the input
                LcheckCutSet(indexLeaf)=1;
            otherwise
                error('openCOSSAN:reliability:FaultTree',...
                    'Event type not implemented');
        end
        currentEvent=indexLeaf;
    else    % Events
        switch currentGate
            case {'AND'}
                Lcutset=LcurrentCutSet;
                Lcutset(currentEvent)=0;   % Remove processed event from the cutset
                Lcutset(indexLeaf)=1;
                Ccutset{currentCutSet}=Lcutset;
            case {'OR'}
                for iev=1:length(indexLeaf)
                    Lcutset=LcurrentCutSet;
                    Lcutset(currentEvent)=0;   % Remove processed event from the cutset
                    Lcutset(indexLeaf(iev))=1; % Add current leaf
                    LcheckCutSet(currentCutSet+iev-1)=0;
                    Ccutset{currentCutSet+iev-1}=Lcutset;
                end
            otherwise
                error('openCOSSAN:reliability:FaultTree',...
                    'only AND and OR gate are implemented');
        end
    end
    
    %% check if the cut-set contains only basic events
    for ics=1:length(Ccutset)
        if ~LcheckCutSet(ics)
            for ievent=1:length(Ccutset{ics})
                if Ccutset{ics}(ievent)
                    if ~strcmp(Xobj.CnodeTypes(ievent),'Input')
                        LcheckCutSet(ics)=0;
                        % Set the current cutset
                        currentEvent=ievent;
                        currentGate=Xobj.CnodeTypes{ievent};
                        LcurrentCutSet=Ccutset{ics};
                        currentCutSet=ics;
                        break
                    else
                        LcheckCutSet(ics)=1;
                    end
                end
            end
        end
    end
    
    if all(LcheckCutSet)
        Lcontinue=false;
    end
    
    % Compact cut set and store in the FaultTree object
    Xobj.McutSets=cell2mat(Ccutset);
    
    if nargout>1
        varargout{1}=Ccutset;
    end
    
end
