function [Xopt, varargout]= optimizeLocalMetaModel(Xobj,varargin)
% OPTIMIZELOCALMETAMODEL This function is used to perform optimization using
% local MetaModel 
%
% See ALso: http://cossan.cfd.liv.ac.uk/wiki/index.php/OptimizeLocalMetaModel@RBOproblem
%
% Copyright  1993-2011 University of Innsbruck,
% Author: Edoardo Patelli

%% Default values
CargumentsOptimizer{1}='XOptimizationProblem';
CargumentsOptimizer{2}=Xobj;
CargumentsMetaModel=Xobj.CmetamodelProperties;

%% Process inputs
% validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

% Process arguments
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'nmaxlocalrboiterations'
            Xobj.NmaxLocalRBOIteration=varargin{k+1};
        case 'xoptimizer'
            Xoptimizer=varargin{k+1};
        case 'cxoptimizer'
            Xoptimizer=varargin{k+1}{1};
        case 'smetamodeltype'
            Xobj.SmetamodelType=varargin{k+1};
        case 'xsimulator'
            Xobj.Xsimulator=varargin{k+1};
        case 'cxsimulator'
            Xobj.Xsimulator=varargin{k+1}{1};
        case 'vperturbation'
            Xobj.VperturbationSize=varargin{k+1};
        case {'vinitialsolution','xoptimum','minitialsolutions'}
            CargumentsOptimizer{end+1}=varargin{k}; %#ok<AGROW>
            CargumentsOptimizer{end+1}=varargin{k+1}; %#ok<AGROW>
        otherwise
            CargumentsMetaModel{end+1}=varargin{k}; %#ok<AGROW>
            CargumentsMetaModel{end+1}=varargin{k+1}; %#ok<AGROW>
    end
end

if isempty(Xobj.NmaxLocalRBOIteration)
    Xobj.NmaxLocalRBOIteration=5;
end


%% Local MetaModel
% Store some variables locally
Ndv=Xobj.Xinput.NdesignVariables;
CdvNames=Xobj.Xinput.CnamesDesignVariable;
XinputRBO=Xobj.Xinput;
XevaluatorRBO=Xobj.Xmodel.Xevaluator;

assert(logical(~isempty(Xobj.VperturbationSize)),...
    'openCOSSAN:RBOproblem:optimizeLocalMetaModel',...
    'The perturbation size is mandatory')

assert(length(Xobj.VperturbationSize)==Ndv,...
    'openCOSSAN:RBOproblem:optimize',...
    'The length of VperturbationSize (%i) must be equal to the number of design variables (%i)', ...
    length(Xobj.VperturbationSize),Ndv)

% Store the original bounds for the DesignVariable
MoriginalBounds=zeros(2,Ndv);
VcurrentOpt=zeros(1,Ndv);

for iDV=1:Ndv
    MoriginalBounds(1,iDV)=Xobj.Xinput.XdesignVariable.(CdvNames{iDV}).lowerBound;
    MoriginalBounds(2,iDV)=Xobj.Xinput.XdesignVariable.(CdvNames{iDV}).upperBound;
    VcurrentOpt(iDV)=Xobj.Xinput.XdesignVariable.(CdvNames{iDV}).value;
end

Mbounds=zeros(2,Ndv);

%% Start optimization
for n=1:Xobj.NmaxLocalRBOIteration
    OpenCossan.cossanDisp(sprintf('RBO iteration # %i',n),2)
    %% Define local subdomain
    % create initial bounds of the Design Variable  in order to train the
    % meta-model and perform optimization in this restricted domain
    
    for iDV=1:Ndv
        % Use unmodified DV
        lowerBound=max(0,Xobj.Xinput.XdesignVariable.(CdvNames{iDV}).getPercentile ...
            (VcurrentOpt(iDV))-Xobj.VperturbationSize(iDV));
        upperBound=min(1,Xobj.Xinput.XdesignVariable.(CdvNames{iDV}).getPercentile ...
            (VcurrentOpt(iDV))+Xobj.VperturbationSize(iDV));
        
        Mbounds(:,iDV)=Xobj.Xinput.XdesignVariable.(CdvNames{iDV}).getValue ...
            ([lowerBound upperBound]);
        
        %% Reset bounds of the DesignVariable
        % Use unmodified DV
        Vsupport=Xobj.Xinput.XdesignVariable.(CdvNames{iDV}).Vsupport;
        if ~isempty(Vsupport)
            % Remove values exiding the new bounds
            Vsupport(Vsupport<Mbounds(1,nDV))=[];
            Vsupport(Vsupport>Mbounds(2,nDV))=[];
            % Perform changes on a copy of the Input object
            XinputRBO=XinputRBO.set('Sname',CdvNames{iDV},'SpropertyName','Vsupport','Vvalues',Vsupport);
        else
            % Perform changes on a copy of the Input object
            % Set Lower Bound
            XinputRBO=XinputRBO.set('Sname',CdvNames{iDV},'SpropertyName','lowerBound','value',Mbounds(1,iDV));
            % Set upper Bound
            XinputRBO=XinputRBO.set('Sname',CdvNames{iDV},'SpropertyName','upperBound','value',Mbounds(2,iDV));
        end
    end
    %% Calibrate MetaModel
    % Redifine a physical model
    XmodelRBO=Model('Xinput',XinputRBO,'Xevaluator',XevaluatorRBO);
    % Calibrate a metamodel for the physical model defined in the subdomain
    CargumentsMetaModel{end+1}='SmetamodelType'; %#ok<AGROW>
    CargumentsMetaModel{end+1}=Xobj.SmetamodelType;%#ok<AGROW>
    CargumentsMetaModel{end+1}='Xsimulator';%#ok<AGROW>
    CargumentsMetaModel{end+1}=Xobj.Xsimulator;%#ok<AGROW>
    CargumentsMetaModel{end+1}='XFullModel';%#ok<AGROW>
    CargumentsMetaModel{end+1}=XmodelRBO;%#ok<AGROW>
    
    Xobj=Xobj.calibrateMetaModel(CargumentsMetaModel{:});

    
    %% Perform optimization
    % Pass option input parameter to the optimizator
    [XoptTmp, XSimOutputTmp]  = Xoptimizer.apply(CargumentsOptimizer{:});
    
    %% Check results
    if n>1
         % optimum does not change
         currentValueObjFun=XoptTmp.XobjectiveFunction(end,end).Vdata;
         bestValueObjFun=Xopt.XobjectiveFunction(end,end).Vdata;
        if abs(currentValueObjFun(end)-bestValueObjFun(end))<Xoptimizer.toleranceObjectiveFunction
            % Merge Optimum
            Xopt=Xopt.merge(XoptTmp);
             XSimOutput=XSimOutputTmp;
            break
        end
        % Merge results
        Xopt=Xopt.merge(XoptTmp);
        XSimOutput=XSimOutput.merge(XSimOutputTmp);
    else
        Xopt=XoptTmp;
        XSimOutput=XSimOutputTmp;
    end
    
    %% Update DesignVariable
    % Set default value of the DesignVariable to the current optimum
    
    %% Set Artifical bounds for the DesignVariable
    VcurrentOpt=Xopt.XdesignVariable(:,end).Vdata;
    if OpenCossan.getVerbosityLevel>2
        sprintf('RBO current optimum: %e',VcurrentOpt)
    end
end

if nargout>1
    varargout{1}=XSimOutput;
end
