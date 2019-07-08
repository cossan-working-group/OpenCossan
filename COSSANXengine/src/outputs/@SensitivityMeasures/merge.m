function Xobj = merge(Xobj,Xobj2)
%MERGE This method merges 2 objects of type SensitivityMeasures.
%
%  See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Merge@SensitivityMeasures

% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@SensitivityMeasures
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli

%% Processing Inputs
assert(isa(Xobj2,'SensitivityMeasures'), ...
    'openCOSSAN:Inputs:merge', ...
    'An object of type SensitivityMeasures is required, provided object type %s', ...
    class(Xobj2))

assert(logical(strcmp(Xobj.SoutputName,Xobj2.SoutputName)), ...
    'openCOSSAN:Inputs:merge', ...
    'The two SensitivityMeasures object must have been computed for the same outputs')



%% Check variables
% identify variables of the second object present in the first
Vindex2=find(ismember(Xobj2.CinputNames,Xobj.CinputNames));

Vindex1=size(Vindex2);
Vnan=1:length(Xobj.CinputNames);
for n=1:length(Vindex2)
    Vindex1(n)=find(ismember(Xobj.CinputNames,Xobj2.CinputNames{n}));
end

Vnan(Vindex1)=[];

% identify variables
if ~isempty(Vindex2)
    %% Process total indices
    if ~isempty(Xobj2.VtotalIndices)
        if isempty(Xobj.VtotalIndices),
            Xobj.VtotalIndices(Vnan)=NaN;
        end
        Xobj.VtotalIndices(Vindex1)=Xobj2.VtotalIndices(Vindex2);
    end
    
    if ~isempty(Xobj2.VtotalIndicesCoV)
        if isempty(Xobj.VtotalIndicesCoV)
            Xobj.VtotalIndicesCoV(Vnan)=NaN;
        end
        Xobj.VtotalIndicesCoV(Vindex1)=Xobj2.VtotalIndicesCoV(Vindex2);
    end
    
    if ~isempty(Xobj2.MtotalIndicesCI)
        if isempty(Xobj.MtotalIndicesCI)
            Xobj.MtotalIndicesCI(1:2,Vnan)=NaN;
        end
        Xobj.MtotalIndicesCI(:,Vindex1)=Xobj2.MtotalIndicesCI(:,Vindex2);
    end
    
    
    %% Process upper bounds
    if ~isempty(Xobj2.VupperBounds)
        if isempty(Xobj.VupperBounds),
            Xobj.VupperBounds(Vnan)=NaN;
        end
        Xobj.VupperBounds(Vindex1)=Xobj2.VupperBounds(Vindex2);
    end
    
    if ~isempty(Xobj2.VupperBoundsCoV)
        if isempty(Xobj.VupperBoundsCoV)
            Xobj.VupperBoundsCoV(Vnan)=NaN;
        end
        Xobj.VupperBoundsCoV(Vindex1)=Xobj2.VupperBoundsCoV(Vindex2);
    end
    
    if ~isempty(Xobj2.MupperBoundsCI)
        if isempty(Xobj.MupperBoundsCI)
            Xobj.MupperBoundsCI(1:2,Vnan)=NaN;
        end
        Xobj.MupperBoundsCI(:,Vindex1)=Xobj2.MupperBoundsCI(:,Vindex2);
    end
    
    
    %% Process First indices
    if ~isempty(Xobj2.VsobolFirstIndices)
        if isempty(Xobj.VsobolFirstIndices),
            Xobj.VsobolFirstIndices(Vnan)=NaN;
        end
        Xobj.VsobolFirstIndices(Vindex1)=Xobj2.VsobolFirstIndices(Vindex2);
    end
    
    if ~isempty(Xobj2.VsobolFirstIndicesCoV)
        if isempty(Xobj.VsobolFirstIndicesCoV)
            Xobj.VsobolFirstIndicesCoV(Vnan)=NaN;
        end
        Xobj.VsobolFirstIndicesCoV(Vindex1)=Xobj2.VsobolFirstIndicesCoV(Vindex2);
    end
    
    if ~isempty(Xobj2.MsobolFirstIndicesCI)
        if isempty(Xobj.MsobolFirstIndicesCI)
            Xobj.MsobolFirstIndicesCI(1:2,Vnan)=NaN;
        end
        Xobj.MsobolFirstIndicesCI(:,Vindex1)=Xobj2.MsobolFirstIndicesCI(:,Vindex2);
    end
    
    
    
    if isempty(Xobj.SestimationMethod)
        Xobj.SestimationMethod=Xobj2.SestimationMethod;
    end
end

%% Add sensitivity measures
VindexAdd=find(~ismember(Xobj2.CinputNames,Xobj.CinputNames));
if ~isempty(VindexAdd)
    % Add variables
    Xobj.CinputNames=[Xobj.CinputNames Xobj2.CinputNames(VindexAdd)];
    if ~isempty(Xobj2.VtotalIndices)
        Xobj.VtotalIndices=[Xobj.VtotalIndices Xobj2.VtotalIndices(VindexAdd)];
    end
    if ~isempty(Xobj2.VtotalIndicesCoV)
        Xobj.VtotalIndicesCoV=[Xobj.VtotalIndicesCoV Xobj2.VtotalIndicesCoV(VindexAdd)];
    end
    if  ~isempty(Xobj2.MtotalIndicesCI)
        Xobj.MtotalIndicesCI=[Xobj.MtotalIndicesCI Xobj2.MtotalIndicesCI(:,VindexAdd)];
    end
    
    if ~isempty(Xobj2.VupperBounds)
        Xobj.VupperBounds=[Xobj.VupperBounds Xobj2.VupperBounds(VindexAdd)];
    end
    if ~isempty(Xobj2.VupperBoundsCoV)
        Xobj.VupperBoundsCoV=[Xobj.VupperBoundsCoV Xobj2.VupperBoundsCoV(VindexAdd)];
    end
    if ~isempty(Xobj2.MupperBoundsCI)
        Xobj.MupperBoundsCI=[Xobj.MupperBoundsCI Xobj2.MupperBoundsCI(:,VindexAdd)];
    end
    
    if ~isempty(Xobj2.VsobolFirstIndices)
        Xobj.VsobolFirstIndices=[Xobj.VsobolFirstIndices Xobj2.VsobolFirstIndices(VindexAdd)];
    end
    if ~isempty(Xobj2.VsobolFirstIndicesCoV)
        Xobj.VsobolFirstIndicesCoV=[Xobj.VsobolFirstIndicesCoV Xobj2.VsobolFirstIndicesCoV(VindexAdd)];
    end
    if ~isempty(Xobj2.MsobolFirstIndicesCI)
        Xobj.MsobolFirstIndicesCI=[Xobj.MsobolFirstIndicesCI Xobj2.MsobolFirstIndicesCI(:,VindexAdd)];
    end
end

%% Add sobol indices
VindexAdd=find(~ismember(Xobj2.CsobolComponentsIndices,Xobj.CsobolComponentsIndices));
if ~isempty(VindexAdd)
    Xobj.VsobolIndices=[Xobj.VsobolIndices Xobj2.VsobolIndices(VindexAdd)];
    Xobj.VsobolIndicesCoV=[Xobj.VsobolIndicesCoV Xobj2.VsobolIndicesCoV(VindexAdd)];
    Xobj.MsobolIndicesCI=[Xobj.MsobolIndicesCI Xobj2.MsobolIndicesCI(VindexAdd)];
    Xobj.CsobolComponentsIndices=[Xobj.CsobolComponentsIndices Xobj2.CsobolComponentsIndices(VindexAdd)];
end


