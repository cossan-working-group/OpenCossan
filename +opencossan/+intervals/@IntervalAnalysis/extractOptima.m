function  Xextrema  = extractOptima(Xobj,varargin)
% EXTRACTOPTIMA  This method constructs the Extrema object given two(one)
% Optimum objects or a SimulationData object

% if nargin==0
%     % assign empty object
%    return
% end

OpenCossan.validateCossanInputs(varargin{:})
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'cxoptima'
            CXoptima=varargin{k+1};
        case 'xoptimum' %case genetic algorithm min/max
            Xoptimum=varargin{k+1};
        case 'xsimulationoutput'
            XSimulationData=varargin{k+1};
    end
end



if exist('CXoptima','var')
    assert(length(CXoptima)==2,...
        'openCOSSAN:IntervalAnalysis:extractOptima',...
        'In order to extract minimum and maximum two Optimum objects are required');
       
        XoptimumMin=CXoptima{1};
        VobjDataMin=XoptimumMin.XobjectiveFunction.Vdata;
        [~,posMin]=min(VobjDataMin);
        
        Niter=XoptimumMin.XobjectiveFunction.VdataLength;
        Ndvs =length(XoptimumMin.XdesignVariable);
        MdvsData=zeros(Ndvs,Niter);
        for idv=1:length(XoptimumMin.XdesignVariable)
            MdvsData(idv,:)=XoptimumMin.XdesignVariable(idv).Vdata;
        end
        minimum=VobjDataMin(posMin);
        VargumentMin=MdvsData(:,posMin);
        
        
        XoptimumMax=CXoptima{2};
        VobjDataMax=XoptimumMax.XobjectiveFunction.Vdata;
        [~,posMax]=max(-VobjDataMax);
        
        Niter=XoptimumMax.XobjectiveFunction.VdataLength;
        Ndvs =length(XoptimumMax.XdesignVariable);
        MdvsData=zeros(Ndvs,Niter);
        for idv=1:length(XoptimumMax.XdesignVariable)
            MdvsData(idv,:)=XoptimumMax.XdesignVariable(idv).Vdata;
        end
        maximum=-VobjDataMax(posMax);
        VargumentMax=MdvsData(:,posMax);
        
elseif exist('Xoptimum','var')
    
elseif exist('XSimulationData','var')
    VobjData=XSimulationData.getValues('Sname',Xobj.Coutputnames{1});
    [~,posAscend]=sort(VobjData,'ascend');
    VdvsData=XSimulationData.getValues('Cnames',Xobj.CnamesIntervalVariables);
    minimum=VobjData(posAscend(1));
    VargumentMin=VdvsData(posAscend(1),:);
    maximum=VobjData(posAscend(end));
    VargumentMax=VdvsData(posAscend(end),:);
end


% Create the Extrema object
if exist('XSimulationData','var')
    Xextrema=Extrema('Sdescription','',...
        'XintervalAnalysis',Xobj,...
        'CdesignVariableNames',Xobj.Xinput.CnamesDesignVariable,...
        'CVargOptima',{VargumentMin,VargumentMax},...
        'Coptima',{minimum,maximum},...
        'XsimData',XSimulationData);
else
    Xextrema=Extrema('Sdescription','',...
        'XintervalAnalysis',Xobj,...
        'CdesignVariableNames',Xobj.Xinput.CnamesDesignVariable,...
        'CXoptima',{XoptimumMin,XoptimumMax},...
        'CVargOptima',{VargumentMin,VargumentMax},...
        'Coptima',{minimum,maximum});
end



% if ~isa(Xobj.Xsolver,'GeneticAlgorithms')
%     
%     Xextrema=Extrema('Sdescription','Solution of the Interval Analysis analysis',...
%         'CdesignVariableNames',Xobj.Xinput.CnamesDesignVariable,...
%         'CXoptima',CXoptima);
% else
%     % check if genetic algorithm was used with the flag "minmax"
% end



