function Xobj=prepareInputs(Xobj)
% PREPAREINPUTS is a method of ExtremeCase used to manipulate the original
% input object to perform the ExtremeCase analysis. 
% Please refer to the documentation for more details on the method.

% create two input objects
% from the original input, in order to perform the mapping from intervals
% to design variables.
import opencossan.common.inputs.*
import opencossan.optimization.DesignVariable
% Extract input from the object
Xinput0= Xobj.XprobabilisticModel.Xinput;

% Assign the names of the bounded sets
CnamesBoundedSet=Xinput0.CnamesBoundedSet;
assert(~isempty(CnamesBoundedSet),...
    'openCOSSAN:ExtremeCase:prepareInputs',...
    'The extrme case analysis requires at least one bounded set to be defined')
Nbset=length(CnamesBoundedSet);

% Check if there are any interval hyper-parameters 
if isempty(Xinput0.CinputMapping) % when only intervals are defined the input mapping has to be created (THIS CASE APPLIES IF ONLY INTERVALS ARE DEFINED)
    % Intervals must be converted into normal random variables, which mean
    % values is a bounded design variable. 
    XinputMapping=opencossan.common.inputs.Input; % Create a empty object (this input contains only design variables)
    XinputProbabilistic=Xinput0;    % this is the original input with normal random variables in place of the intervals
    XinputParameters =Xinput0;      % this is the original input with parameters in place of the intervals
    % Evaluate total number of interval variables
    NivTotal=0;
    for n=1:Nbset
        Niv=Xinput0.Xbset.(CnamesBoundedSet{n}).Niv; % number of intervals in the bounded set
        NivTotal=Niv+NivTotal;
    end
    % Initialise cell-array for the input mapping
    CinputMapping=cell(NivTotal,4);
    
    % Start loop over the bounded sets for the input objects
    for n=1:Nbset

        Niv=Xinput0.Xbset.(CnamesBoundedSet{n}).Niv; % number of intervals in the bounded set
        CnamesInterval=Xinput0.Xbset.(CnamesBoundedSet{n}).Cmembers;
        VlowerBounds=Xinput0.Xbset.(CnamesBoundedSet{n}).VlowerBounds;
        VupperBounds=Xinput0.Xbset.(CnamesBoundedSet{n}).VupperBounds;
        for i=1:Niv
            VcentralValues=0.5*(VupperBounds+VlowerBounds);
            VradiusValues=0.5*(VupperBounds-VlowerBounds);
            RV=RandomVariable('Sdistribution','normal','mean',VcentralValues(i),'std',0.2*VradiusValues(i));
            P =Parameter('value',VcentralValues(i));
            eval([CnamesInterval{i},'=RV']);
            Sname=[CnamesInterval{i}];
            eval(['CXintervalRvset{i}=',Sname]);
            eval([CnamesInterval{i},'=P']);
            eval(['CXintervalParameter{i}=',Sname]);
            eval('CnamesIntervalRvset{i}=Sname');
            DV=opencossan.optimization.DesignVariable('lowerBound',VlowerBounds(i),'upperBound',VupperBounds(i));
            XinputMapping.XdesignVariable.([CnamesInterval{i}])=DV;
            CinputMapping(i,:)={CnamesInterval{i},[CnamesInterval{i}],'mean','parametervalue'};
            XinputParameters.Xbset.(CnamesBoundedSet{n})=XinputParameters.Xbset.(CnamesBoundedSet{n}).remove(Sname);
            XinputParameters=XinputParameters.add('Xmember',CXintervalParameter{i},'Sname',Sname); % si incazza perche' il nome del parametro ce lo ha gia' come intervallo
        end
        XinputProbabilistic.Xbset=rmfield(XinputProbabilistic.Xbset,CnamesBoundedSet{n});
        XinputParameters.Xbset=rmfield(XinputParameters.Xbset,CnamesBoundedSet{n});         
    end
    XintervalRvset=RandomVariableSet('CXrandomVariables',CXintervalRvset,...
        'CSmembers',CnamesIntervalRvset);
    XinputProbabilistic=XinputProbabilistic.add('Xmember',XintervalRvset,'Sname','XintervalRvset');
    Xobj.CdesignMapping=CinputMapping;
else % when interval hyper-parameters are defined the input mapping is provided (as mandatory) by the user 
    CinputMapping=Xinput0.CinputMapping;
    % Intervals must be converted into normal random variables, which mean
    % values is a bounded design variable. 
    XinputMapping=Input;            % this input contains only design variables
    XinputProbabilistic=Xinput0;    % this is the original input with normal random variables in place of the intervals
    XinputParameters =Xinput0;      % this is the original input with parameters in place of the intervals
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
    CinputMappingNew=cell(NivTotal,4);
        
    % Start loop over the bounded sets for the input objects
    for n=1:Nbset
        Niv=Xinput0.Xbset.(CnamesBoundedSet{n}).Niv; % number of intervals in the bounded set
        CnamesInterval=Xinput0.Xbset.(CnamesBoundedSet{n}).Cmembers;
        VlowerBounds=Xinput0.Xbset.(CnamesBoundedSet{n}).VlowerBounds;
        VupperBounds=Xinput0.Xbset.(CnamesBoundedSet{n}).VupperBounds;
        VcentralValues=0.5*(VupperBounds+VlowerBounds);
        VradiusValues=0.5*(VupperBounds-VlowerBounds);
        istart=sum(VNiv(1:n))-Niv;
        icount=0;
        for i=1:Niv
            if indexes(istart+i)~=0 % the interval is a hyperparameter
                DV=DesignVariable('lowerBound',VlowerBounds(i),'upperBound',VupperBounds(i));
                XinputMapping.XdesignVariable.([CnamesInterval{i}])=DV;
                CinputMappingNew(istart+i,1:3)=CinputMapping(indexes(istart+i),:);
                CinputMappingNew(istart+i,4)=CinputMapping(indexes(istart+i),3);
            else                    % the interval is a structural parameter
                % create an equivalent normal random variable with interval
                % mean and fixed standard deviation
                icount=icount+1;
                RV=RandomVariable('Sdistribution','normal','mean',VcentralValues(i),'std',0.2*VradiusValues(i));
                P =Parameter('value',VcentralValues(i));
                eval([CnamesInterval{i},'=RV']);
                Sname=[CnamesInterval{i}];
                eval(['CXintervalRvset{i}=',Sname]);
                eval('CnamesIntervalRvset{i}=Sname');
                eval([CnamesInterval{i},'=P']);
                eval(['CXintervalParameter{i}=',Sname]);
                DV=DesignVariable('lowerBound',VlowerBounds(i),'upperBound',VupperBounds(i));
                XinputMapping.XdesignVariable.([CnamesInterval{i}])=DV;
                CinputMappingNew(istart+i,:)={CnamesInterval{i},Sname,'mean','parametervalue'};
                XinputParameters.Xbset.(CnamesBoundedSet{n})=XinputParameters.Xbset.(CnamesBoundedSet{n}).remove(Sname);
                XinputParameters=XinputParameters.add('Xmember',CXintervalParameter{i},'Sname',Sname);
            end
        end
        XinputProbabilistic.Xbset=rmfield(XinputProbabilistic.Xbset,CnamesBoundedSet{n});
        XinputParameters.Xbset=rmfield(XinputParameters.Xbset,CnamesBoundedSet{n});
    end
    if exist('CXintervalRvset','var')
    % a new random variable set of independent normal variables is added to
    % the input object
    XintervalRvset=RandomVariableSet('CXrandomVariables',CXintervalRvset,...
        'CSmembers',CnamesIntervalRvset);
    XinputProbabilistic=XinputProbabilistic.add('Xmember',XintervalRvset,'Sname','XintervalRvset');
    end
    % a new design mapping is added to the class object
    Xobj.CdesignMapping=CinputMappingNew;
end

Xobj.XinputOriginal=Xinput0;
Xobj.XinputProbabilistic=XinputProbabilistic;
Xobj.XinputMapping=XinputMapping;
Xobj.XinputParameters=XinputParameters;

return
