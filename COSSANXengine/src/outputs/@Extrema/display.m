function display(Xobj)
%DISPLAY  Displays the object Extrema
%
% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================



%% Name and description
OpenCossan.cossanDisp('==========================================================================',3);
OpenCossan.cossanDisp([ class(Xobj) ' object  -  Description: ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('==========================================================================',3);

VargMinimum=Xobj.CVargOptima{1};
VargMaximum=Xobj.CVargOptima{2};


if isa(Xobj.XanalysisObject,'IntervalAnalysis')
    OpenCossan.cossanDisp(['** Results obtained with ', class(Xobj.XanalysisObject.Xsolver), ' method:' ],2);
    
    %    OpenCossan.cossanDisp(['*** bounds          = ' sprintf('[%9.3e, %9.3e]',Xobj.minimum,Xobj.maximum)],2);
    OpenCossan.cossanDisp(['*** Minimum and Maximum of the quantity of interest: ',Xobj.XanalysisObject.CobjectiveFunctionNames{1}],2);
    OpenCossan.cossanDisp(['*** [min, max]       = ' sprintf('[%9.3e, %9.3e]  "',Xobj.Coptima{1},Xobj.Coptima{2}),...
        Xobj.XanalysisObject.CobjectiveFunctionNames{1},'"'],2);
    
    OpenCossan.cossanDisp('** Argument optima: ',2);
    for n=1:length(Xobj.CdesignVariableNames)
        OpenCossan.cossanDisp(['*** [ArgMin, ArgMax] = ' sprintf('(%9.3e, %9.3e)  "',VargMinimum(n),VargMaximum(n)),...
            Xobj.CdesignVariableNames{n},'"'],2);
    end
    
    
    %     for n=1:size(Cmapping,2)
    %         OpenCossan.cossanDisp(['*** (min, max) *',Cmapping{n,3},'* of ', Cmapping{n,2} ,'   = ' sprintf('(%9.3e, %9.3e)',...
    %             Xobj.VargMinimum(n),Xobj.VargMaximum(n))],2)
    %     end
    
%     if ~isempty(Xobj.XsimulationData)
%         NtotalEval=Xobj.XsimulationData.Nsamples;
%         Niterations=0;
%         Nsamples=Xobj.XsimulationData.Nsamples;
%     elseif ~isempty(Xobj.CXoptima)
%         NevalMin=Xobj.CXoptima{1}.NevaluationsObjectiveFunctions;
%         NevalMax=Xobj.CXoptima{2}.NevaluationsObjectiveFunctions;
%         NtotalEval=NevalMin+NevalMax;
%         Niterations=NtotalEval;
%         Nsamples=0;
%     else 
%         NtotalEval=Xobj.CXresults{1}.Nsamples;
%         Niterations=0;
%         Nsamples=Xobj.CXresults{1}.Nsamples;
%     end
CSsuperClass=superclasses(Xobj.XanalysisObject.Xsolver);
    switch lower(CSsuperClass{1})
        case 'optimizer'
            NevalMin=Xobj.CXresults{1}.NevaluationsObjectiveFunctions;
            NevalMax=Xobj.CXresults{2}.NevaluationsObjectiveFunctions;
            NtotalEval=NevalMin+NevalMax;
            Nsamples=0;
            Niterations=Xobj.CXresults{1}.Niterations+Xobj.CXresults{2}.Niterations;
        case 'simulations'
            NtotalEval=Xobj.CXresults{1}.Nsamples;
            Niterations=0;
            Nsamples=Xobj.CXresults{1}.Nsamples;
        case ''
    end
    
    OpenCossan.cossanDisp( '** Analysis details:',2);
    OpenCossan.cossanDisp(['*** # model evaluations     = ' sprintf('%9.3e',NtotalEval)],2);
    OpenCossan.cossanDisp(['*** # iterations            = ' sprintf('%9i',Niterations)],2);
    OpenCossan.cossanDisp(['*** # samples               = ' sprintf('%9i',Nsamples)],2);
    
    
elseif isa(Xobj.XanalysisObject,'ExtremeCase')
    
    Cmapping=Xobj.XanalysisObject.CdesignMapping;
    
    OpenCossan.cossanDisp(['** Inner loop results obtained with ' class(Xobj.XanalysisObject.XadaptiveLineSampling) ' method:' ],2);
    if isnan(Xobj.CXoptima{1}.cov)
        OpenCossan.cossanDisp(['*** Pf bounds          = ' sprintf('[%9.3e, %9.3e]',...
        0,Xobj.CXoptima{2}.pfhat*(1+3*Xobj.CXoptima{2}.cov))],2);
    elseif isnan(Xobj.CXoptima{2}.cov)
        OpenCossan.cossanDisp(['*** Pf bounds          = ' sprintf('[%9.3e, %9.3e]',...
        Xobj.CXoptima{1}.pfhat*(1-3*Xobj.CXoptima{1}.cov),1)],2);
    else
        OpenCossan.cossanDisp(['*** Pf bounds          = ' sprintf('[%9.3e, %9.3e]',...
        Xobj.CXoptima{1}.pfhat*(1-3*Xobj.CXoptima{1}.cov),Xobj.CXoptima{2}.pfhat*(1+3*Xobj.CXoptima{2}.cov))],2);
    end
    OpenCossan.cossanDisp(['*** [min, max] Pfhat   = ' sprintf('[%9.3e, %9.3e]',Xobj.CXoptima{1}.pfhat,Xobj.CXoptima{2}.pfhat)],2);
    OpenCossan.cossanDisp(['*** CoV minimum        = ' sprintf('%9.3e',Xobj.CXoptima{1}.cov)],2);
    OpenCossan.cossanDisp(['*** CoV maximum        = ' sprintf('%9.3e',Xobj.CXoptima{2}.cov)],2);
    OpenCossan.cossanDisp(['** Argument optima: '],2);
    for n=1:size(Cmapping,1)
        OpenCossan.cossanDisp(['*** (argMin, argMax) *',Cmapping{n,3},'* of ', Cmapping{n,2} ,'   = ' sprintf('(%9.3e, %9.3e)',...
            VargMinimum(n),VargMaximum(n))],2)
    end
    
    OpenCossan.cossanDisp( '** Simulation details:',2);
    OpenCossan.cossanDisp(['*** # samples     = ' sprintf('%9.3e',Xobj.Nevaluations)],2);
    OpenCossan.cossanDisp(['*** # iterations  = ' sprintf('%9i',Xobj.Niterations)],2);
    OpenCossan.cossanDisp(['*** # batches     = ' sprintf('%9i',1)],2);
    % OpenCossan.cossanDisp(['*** Exit Flag = ' Xobj.SexitFlag],2);
    
elseif isa(Xobj.XanalysisObject,'UncertaintyPropagation')
    
    Cmapping=Xobj.XanalysisObject.CdesignMapping;
    
    OpenCossan.cossanDisp(['** Outer loop results obtained with ' class(Xobj.XanalysisObject.Xsolver) ' method:' ],2);
    OpenCossan.cossanDisp(['** Inner loop results obtained with ' class(Xobj.XanalysisObject.Xsimulator) ' method:' ],2);
    if ~isempty(Xobj.CXoptima)
        OpenCossan.cossanDisp(['*** Pf bounds (+- 3*r)  = ' sprintf('[%9.3e, %9.3e]',...
            Xobj.Coptima{1}*(1-3*Xobj.CcovOptima{1}),Xobj.Coptima{2}*(1+3*Xobj.CcovOptima{2}))],2);
    end
    OpenCossan.cossanDisp(['*** [min, max] Pfhat      = ' sprintf('[%9.3e, %9.3e]',Xobj.Coptima{1},Xobj.Coptima{2})],2);
    OpenCossan.cossanDisp(['*** CoV of the minimum    = ' sprintf('%9.3e',Xobj.CcovOptima{1})],2);
    OpenCossan.cossanDisp(['*** CoV of the maximum    = ' sprintf('%9.3e',Xobj.CcovOptima{2})],2);
    OpenCossan.cossanDisp(['** Argument optima: '],2);
    for n=1:size(Cmapping,1)
        OpenCossan.cossanDisp(['*** (argMin, argMax) *',Cmapping{n,3},'* of ', Cmapping{n,2} ,'   = ' sprintf('(%9.3e, %9.3e)',...
            VargMinimum(n),VargMaximum(n))],2)
    end
    
    OpenCossan.cossanDisp( '** Simulation details:',2);
    OpenCossan.cossanDisp(['*** # samples     = ' sprintf('%9.3e',Xobj.Nevaluations)],2);
    OpenCossan.cossanDisp(['*** # iterations  = ' sprintf('%9i',Xobj.Niterations)],2);
    OpenCossan.cossanDisp(['*** # batches     = ' sprintf('%9i',1)],2);
    
end

% if isempty(Xobj.Xinput)
%     OpenCossan.cossanDisp('* Empty object',1);
%     return
% end

% OpenCossan.cossanDisp( '* ProbabilistiModel to be evaluated',3);
% OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xobj.Xmodel.Cinputnames{:})],3);
% OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xobj.Xmodel.Coutputnames{:})],3);

% OpenCossan.cossanDisp(['* * Simulation method: ',class(Xobj.Xsimulator)],2);

% Show Design Paremeter
OpenCossan.cossanDisp(['* Interval variables: ' sprintf('%s; ', Xobj.CdesignVariableNames{:})],2);

%% Objective function
% if isempty(Xobj.XobjectiveFunction)
%     OpenCossan.cossanDisp('* No objective function defined',3);
% else
%     for n=1:length(Xobj.XobjectiveFunction)
%         OpenCossan.cossanDisp(['* Objective Function #' num2str(n)],3);
%         OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xobj.XobjectiveFunction(n).Cinputnames{:})],3);
%         OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xobj.XobjectiveFunction(n).Coutputnames{:})],3);
%     end
% end

%% constraint
% if isempty(Xobj.Xconstraint)
%     OpenCossan.cossanDisp('* No constraints defined',3);
% else
%     for n=1:length(Xop.Xconstraint)
%         OpenCossan.cossanDisp(['* Constraint #' num2str(n)],3);
%         OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xobj.Xconstraint(n).Cinputnames{:})],3);
%         OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xobj.Xconstraint(n).Coutputnames{:})],3);
%     end
% end

%% Show details for metamodel
% if isempty(Xobj.SmetamodelType)
%    OpenCossan.cossanDisp('* No meta-model type defined',3);
% else
%    OpenCossan.cossanDisp(['* Meta-model type: ' Xobj.SmetamodelType],3);
%     for n=1:2:length(Xobj.CmetamodelProperties)
%         OpenCossan.cossanDisp(['* * Property Name: ' Xobj.CmetamodelProperties{n}],3);
%     end
% end
%% Show extrema






