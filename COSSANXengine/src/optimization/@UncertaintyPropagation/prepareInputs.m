function Xobj=prepareInputs(Xobj)
% PREPAREINPUTS is a method of ExtremeCase used to create two input objects
% from the original input, in order to perform the mapping from intervals
% to design variables.

% Extract input from the object
Xinput0= Xobj.XprobabilisticModel.Xmodel.Xinput;

% Assign the names of the bounded sets
CnamesBoundedSet=Xinput0.CnamesBoundedSet;
assert(~isempty(CnamesBoundedSet),...
    'openCOSSAN:UncertaintyPropagation:prepareInputs',...
    'The UncertaintyPropagation analysis requires at least one bounded set to be defined')
Nbset=length(CnamesBoundedSet);


% Check if there aren't any interval hyper-parameters 
if isempty(Xinput0.CinputMapping) % when only intervals are defined the input mapping has to be created (THIS CASE APPLIES IF ONLY INTERVALS ARE DEFINED)
    % Intervals must be converted into normal random variables, which mean value is a bounded design variable. 
    XinputMapping=Input;            % this input contains only design variables
    XinputEquivalent=Xinput0;       % this is the original input with p in place of the intervals
    
    % Evaluate total number of interval variables
    NivTotal=0;
    for n=1:Nbset
        Niv=Xinput0.Xbset.(CnamesBoundedSet{n}).Niv; % number of intervals in the bounded set
        NivTotal=Niv+NivTotal;
    end
    % Initialise cell-array for the input mapping
    CinputMapping=cell(NivTotal,3);
    
    % Start loop over the bounded sets for the input objects
    for n=1:Nbset
        Niv=Xinput0.Xbset.(CnamesBoundedSet{n}).Niv; % number of intervals in the bounded set
        CnamesInterval=Xinput0.Xbset.(CnamesBoundedSet{n}).Cmembers;
        VlowerBounds=Xinput0.Xbset.(CnamesBoundedSet{n}).VlowerBounds;
        VupperBounds=Xinput0.Xbset.(CnamesBoundedSet{n}).VupperBounds;
        VcentralValues=0.5*(VupperBounds+VlowerBounds);
        for i=1:Niv
            P=Parameter('value',VcentralValues(i));
            XinputEquivalent.Xparameters.(CnamesInterval{i})=P;
            DV=DesignVariable('lowerBound',VlowerBounds(i),'upperBound',VupperBounds(i));
            XinputMapping.XdesignVariable.([CnamesInterval{i}])=DV;
            CinputMapping(i,:)={CnamesInterval{i},CnamesInterval{i},'mean'};
        end
        XinputEquivalent.Xbset=rmfield(XinputEquivalent.Xbset,CnamesBoundedSet{n});
    end
    Xobj.CdesignMapping=CinputMapping;
else % when interval hyper-parameters are defined the input mapping is provided (as mandatory) by the user  (THIS CASE APPLIES IF A MIX OF HYPERPARAMETERS AND INTERVALS ARE DEFINED)
    CinputMapping=Xinput0.CinputMapping;
    % Intervals must be converted into normal random variables, which mean value is a bounded design variable. 
    XinputMapping=Input;            % this input contains only design variables
    XinputEquivalent=Xinput0;    % this is the original input with normal random variables in place of the intervals
    
    % Evaluate total number of interval variables
    NivTotal=length(Xinput0.CnamesIntervalVariable);
    VNiv=zeros(1,Nbset);
    indexes=zeros(1,NivTotal);
    for n=1:Nbset
        Niv=Xinput0.Xbset.(CnamesBoundedSet{n}).Niv; % number of intervals in the bounded set
        VNiv(n)=Niv;
        for i=1:Niv
            CnamesIntervals=Xinput0.Xbset.(CnamesBoundedSet{n}).Cmembers;
            istart=sum(VNiv)-Niv;
            for h=1:size(CinputMapping,1)
                if strcmpi(CinputMapping{h,1},CnamesIntervals{i})
                    indexes(1,i+istart)=h;      % keep track of the intervals that need to be mapped
                end
            end
        end
    end
    
    % Reinitialise cell-array for the input mapping, add entries to the
    % input mapping (HERE WE NEED TO ADD THE INTERVALS TO THE MAPPING)
    CinputMappingNew=cell(NivTotal,3);
        
    % Start loop over the bounded sets for the input objects
    for n=1:Nbset
        Niv=Xinput0.Xbset.(CnamesBoundedSet{n}).Niv; % number of intervals in the bounded set
        CnamesInterval=Xinput0.Xbset.(CnamesBoundedSet{n}).Cmembers;
        VlowerBounds=Xinput0.Xbset.(CnamesBoundedSet{n}).VlowerBounds;
        VupperBounds=Xinput0.Xbset.(CnamesBoundedSet{n}).VupperBounds;
        VcentralValues=0.5*(VupperBounds+VlowerBounds);
        istart=sum(VNiv(1:n))-Niv;
        icount=0;
        for i=1:Niv
            if indexes(istart+i)~=0 % the interval is a hyperparameter
                DV=DesignVariable('lowerBound',VlowerBounds(i),'upperBound',VupperBounds(i));
                XinputMapping.XdesignVariable.([CnamesInterval{i}])=DV;
                CinputMappingNew(istart+i,:)=CinputMapping(indexes(istart+i),:);
            else             % the interval IS NOT a hyperparameter
                % create an equivalent normal random variable with interval
                % mean and fixed standard deviation
                icount=icount+1;
                P=Parameter('value',VcentralValues(i));
                XinputEquivalent.Xparameters.(CnamesInterval{i})=P;
                DV=DesignVariable('lowerBound',VlowerBounds(i),'upperBound',VupperBounds(i));
                XinputMapping.XdesignVariable.([CnamesInterval{i}])=DV;
                CinputMappingNew(istart+i,:)={CnamesInterval{i},CnamesInterval{i},'mean'};
            end
        end
        XinputEquivalent.Xbset=rmfield(XinputEquivalent.Xbset,CnamesBoundedSet{n});
    end
    % a new design mapping is added to the class object
    Xobj.CdesignMapping=CinputMappingNew;
end

Xobj.XinputOriginal=Xinput0;
Xobj.XinputEquivalent=XinputEquivalent;
Xobj.XinputMapping=XinputMapping;

return