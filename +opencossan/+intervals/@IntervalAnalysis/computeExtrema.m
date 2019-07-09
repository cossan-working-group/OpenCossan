function  Xextrema  = computeExtrema(Xobj,varargin)
% COMPUTEEXTREMA  This method computes minimum and maximum of the provided
% objective function

%% Validate COSSAN inputs
OpenCossan.validateCossanInputs(varargin{:})

%% Assign the inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'xsolver'
            Xobj.Xsolver=varargin{k+1};
    end
end

%% Define the type of internal analysis
if isempty(Xobj.Xsolver)
    % If no solver is provided set a default analysis
    if Xobj.NintervalVariables <= 9
        % use full factorial Design of Experiment
        warning('OpenCOSSAN:ExtremeCase:extremize',...
            'A Solver object was not passed to the constructor: a full factorial scheme will be adopted for the analysis')
        % Full-factorial design of experiment requires 2^N model
        % evaluations, which means that in this case no more than 128
        % samples will be used for the analysis
        Xdoe = DesignOfExperiments('SdesignType','FullFactorial',...
            'VlevelValues',ones(1,length(Xobj.XinputEquivalent.CnamesDesignVariable))*2,...
            'ClevelNames',Xobj.XinputEquivalent.CnamesDesignVariable);
        Xobj.Xsolver=Xdoe;
    else
        % use GeneticAlgorithms if possible
        try
        XGA=GeneticAlgorithms('NPopulationSize',10,'NStallGenLimit',5,...
            'SMutationFcn','mutationadaptfeasible');
        warning('OpenCOSSAN:ExtremeCase:extremize',...
            'A Solver object was not passed to the constructor: GeneticAlgorithms will be adopted for the analysis')
        Xobj.Xsolver=XGA;
        catch
            % if GA is not available (because it is linked to the
            % optimization toolbox) perform an euristic search with LHS
            warning('OpenCOSSAN:ExtremeCase:extremize',...
            'A Solver object was not passed to the constructor: a Latin Hypercube search of 100 samples will be performed for the analysis')
            XLHS=LatinHypercubeSampling('Nsamples',100);
            Xobj.Xsolver=XLHS;
        end
    end
end

if isa(Xobj.Xsolver,'GeneticAlgorithms')
    % reassign initial candidate
    XLHS=LatinHypercubeSampling('Nsamples',Xobj.Xsolver.NPopulationSize);
    Xsamples=XLHS.sample('Xinput',Xobj.XinputEquivalent);
    MinSolution=Xsamples.MdoeDesignVariables;
    Xobj.VinitialSolution=MinSolution;
end
%% Perform the global min/max optimization 
CXresults=Xobj.extremize();


%% Post-process the results

if strcmpi(superclasses(Xobj.Xsolver),'Optimizer')
%     if isa(Xobj.Xsolver,'GeneticAlgorithms') && Xobj.LminMax
    if isa(Xobj.Xsolver,'GeneticAlgorithms')
        %% Minimum
        XoptimumMIN=CXresults{1};
        MscoresValues=XoptimumMIN.XobjectiveFunction.Vdata;
        [VbestScores,pos1] = min(MscoresValues,[],1);
        [MINIMUM,pos2]=min(VbestScores);
        Niv=length(Xobj.CnamesIntervalVariables);
        VargMINIMUM=zeros(1,Niv);
        for n=1:Niv
            MdataDV=XoptimumMIN.XdesignVariable(n).Vdata;
            VargMINIMUM(n)=MdataDV(pos1(pos2),pos2);
        end
        NiterationsMIN=length(VbestScores);
        NevaluationsMIN=size(MscoresValues,1)*size(MscoresValues,2);
        %% Maximum
        XoptimumMAX=CXresults{2};
        MscoresValues=XoptimumMAX.XobjectiveFunction.Vdata;
        [VbestScores,pos1] = max(-MscoresValues,[],1);
        [MAXIMUM,pos2]=max(VbestScores);
        Niv=length(Xobj.CnamesIntervalVariables);
        VargMAXIMUM=zeros(1,Niv);
        for n=1:Niv
            MdataDV=XoptimumMAX.XdesignVariable(n).Vdata;
            VargMAXIMUM(n)=MdataDV(pos1(pos2),pos2);
        end
        NiterationsMAX=length(VbestScores);
        NevaluationsMAX=size(MscoresValues,1)*size(MscoresValues,2);
        Niterations=NiterationsMIN+NiterationsMAX;
        Nevaluations=NevaluationsMIN+NevaluationsMAX;
    else
        %% Minimum
        XoptimumMIN=CXresults{1};
        VoutValues=XoptimumMIN.XobjectiveFunction.Vdata;
        MINIMUM=VoutValues(end);
        Niv=length(Xobj.CnamesIntervalVariables);
        Niterations=length(VoutValues);
        Mdata=zeros(Niterations,Niv);
        for n=1:length(Xobj.CnamesIntervalVariables)
            Mdata(:,n)=XoptimumMIN.XdesignVariable(n).Vdata';
        end
        VargMINIMUM=Mdata(end,:);
        NevaluationsMIN=Niterations;
        %% Maximum
        XoptimumMAX=CXresults{2};
        VoutValues=XoptimumMAX.XobjectiveFunction.Vdata;
        MAXIMUM=-VoutValues(end);
        Niv=length(Xobj.CnamesIntervalVariables);
        Niterations=length(VoutValues);
        Mdata=zeros(Niterations,Niv);
        for n=1:length(Xobj.CnamesIntervalVariables)
            Mdata(:,n)=XoptimumMAX.XdesignVariable(n).Vdata';
        end
        VargMAXIMUM=Mdata(end,:);
        NevaluationsMAX=Niterations;
        Nevaluations=NevaluationsMIN+NevaluationsMAX;
        Niterations=Nevaluations;
    end
elseif strcmpi(superclasses(Xobj.Xsolver),'Simulations')
    XsimData=CXresults{1};
    VoutValues = XsimData.getValues('CSnames',Xobj.Xmodel.Coutputnames);
    [MINIMUM,posMIN]=min(VoutValues);
    [MAXIMUM,posMAX]=max(VoutValues);
    Mdata = XsimData.getValues('CSnames',Xobj.CnamesIntervalVariables);
    VargMINIMUM = Mdata(posMIN,:);
    VargMAXIMUM = Mdata(posMAX,:);
    Niterations = XsimData.Nsamples;
    Nevaluations= Niterations;
end
%% Assign the output of the analysis
Xextrema=Extrema('Sdescription','Solution of the Extreme Case analysis',...
    'CdesignVariableNames',Xobj.CnamesIntervalVariables,...
    'CVargOptima',{VargMINIMUM,VargMAXIMUM},...
    ...'CXoptima',{XpfMIN,XpfMAX},...
    'Coptima',{MINIMUM,MAXIMUM},...
    ...'CcovOptima',{XpfMIN.cov,XpfMAX.cov},...
    ...'CXsimOutOptima',{XsimOutMin,XsimOutMax},...
    'CXresults',CXresults,...
    'XanalysisObject',Xobj,...
    'NmodelEvaluations',Nevaluations,...
    'Niterations',Niterations);
end % of computeExtrema