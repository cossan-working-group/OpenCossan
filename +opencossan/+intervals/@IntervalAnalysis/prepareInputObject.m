function Xobj=prepareInputObject(Xobj)
% PREPAREINPUTOBJECT This method creates a design mapping to convert
% intervals into design variables. 


% Assign original input object
Xinput0=Xobj.Xinput;

% Assign the names of the bounded sets
CnamesBoundedSet=Xinput0.CnamesBoundedSet;
assert(~isempty(CnamesBoundedSet),...
    'openCOSSAN:ExtremeCase:prepareInputs',...
    'The extrme case analysis requires at least one bounded set to be defined')
% number of bounded sets
Nbset=length(CnamesBoundedSet);

% create the design mapping
% Evaluate total number of interval varaibles
NivTotal=0;
for n=1:Nbset
    Niv=Xinput0.Xbset.(CnamesBoundedSet{n}).Niv; % number of intervals in the bounded set
    NivTotal=Niv+NivTotal;
end

Xinput1=Xinput0;
% Start loop over the bounded sets for the input objects
for n=1:Nbset
    Xinput1.Xbset=rmfield(Xinput1.Xbset,CnamesBoundedSet{n});
    Niv=Xinput0.Xbset.(CnamesBoundedSet{n}).Niv; % number of intervals in the bounded set
    CnamesInterval=Xinput0.Xbset.(CnamesBoundedSet{n}).Cmembers;
    VlowerBounds=Xinput0.Xbset.(CnamesBoundedSet{n}).VlowerBounds;
    VupperBounds=Xinput0.Xbset.(CnamesBoundedSet{n}).VupperBounds;
    for i=1:Niv % transform the intervals into design variables
        DV=DesignVariable('lowerBound',VlowerBounds(i),'upperBound',VupperBounds(i));
        Xinput1.XdesignVariable.([CnamesInterval{i}])=DV;
    end
end
Xobj.XinputEquivalent=Xinput1;

