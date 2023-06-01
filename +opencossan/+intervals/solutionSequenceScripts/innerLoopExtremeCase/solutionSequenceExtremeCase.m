% Solution Sequence Script for the EXTREME CASE analysis

% Declare global variable to use results from previous iterations
global NiterationsEC NevaluationsEC Lmaximize

% initialise inner counter
if isempty(NevaluationsEC),
    NevaluationsEC=0;
end,

% initialise outer counter
if isempty(NiterationsEC),
    NiterationsEC=0;
end,

if isempty(Lmaximize)
    Lmaximize=false;    % perform minimization first
end

% if XextremeCase.LminMax
%     NmaxIterations      =XextremeCase.NmaxIterations;
%     NmaxEvaluations     =XextremeCase.NmaxEvaluations;
% else
%     if Lmaximize
%         NmaxIterations      =floor(XextremeCase.NmaxIterations/2);
%         NmaxEvaluations     =floor(XextremeCase.NmaxEvaluations/2);
%     elseif ~Lmaximize
%         NmaxIterations      =ceil(XextremeCase.NmaxIterations/2);
%         NmaxEvaluations     =ceil(XextremeCase.NmaxEvaluations/2);
%     end
% end


% % % Check if the number of iterations has been reached
% if NiterationsEC>=NmaxIterations,
%     if Lmaximize==true
%         Xpf = FailureProbability('CXmembers',{XprobabilisticModel},...
%             'Smethod','AdaptiveLineSampling',...
%             'pf',1.05,'variancepf',NaN,...
%             'Nsamples',0,...
%             'Nlines',XadaptiveLineSampling.Nlines);
%     elseif Lmaximize==false
%         Xpf = FailureProbability('CXmembers',{XprobabilisticModel},...
%             'Smethod','AdaptiveLineSampling',...
%             'pf',-0.05,'variancepf',NaN,...
%             'Nsamples',0,...
%             'Nlines',XadaptiveLineSampling.Nlines);
%     end
% elseif NevaluationsEC>=NmaxEvaluations,
%     if Lmaximize==true
%         Xpf = FailureProbability('CXmembers',{XprobabilisticModel},...
%             'Smethod','AdaptiveLineSampling',...
%             'pf',1.05,'variancepf',NaN,...
%             'Nsamples',0,...
%             'Nlines',XadaptiveLineSampling.Nlines);
%     elseif Lmaximize==false
%         Xpf = FailureProbability('CXmembers',{XprobabilisticModel},...
%             'Smethod','AdaptiveLineSampling',...
%             'pf',-0.05,'variancepf',NaN,...
%             'Nsamples',0,...
%             'Nlines',XadaptiveLineSampling.Nlines);
%     end
% else
import opencossan.common.Model
import opencossan.reliability.ProbabilisticModel
import opencossan.reliability.FailureProbability
import opencossan.sensitivity.LocalSensitivityFiniteDifference
% Extract Input from Extreme Case object
Xinput=XextremeCase.XinputProbabilistic;
% Extract Evaluator from ProbabilisticModel object
Xevaluator=XextremeCase.XprobabilisticModel.Xevaluator;
% Extract PerformanceFunction and performance function name
% XperformanceFunction=XextremeCase.XprobabilisticModel.XperformanceFunction;
% SperformanceFunctionName=XperformanceFunction.Soutputname;

%% Update Input object

warning('OFF','OpenCossan:Parameter:set:obsolete')
Nvariables2map=size(XextremeCase.CdesignMapping,1);
for n=1:Nvariables2map
    Xinput=Xinput.set('SobjectName',XextremeCase.CdesignMapping{n,2},...
        'SpropertyName',XextremeCase.CdesignMapping{n,3},'value',varargin{n});
end

% Reconstruct Model
Xmodel=Model('Xinput',Xinput,'Xevaluator',Xevaluator);
% Reconstruct ProbabilisticModel
% XprobabilisticModel=ProbabilisticModel('XperformanceFunction',XperformanceFunction,'Xmodel',Xmodel);
XprobabilisticModel=ProbabilisticModel('Xmodel',Xmodel);

% Write the updated input into the probabilistic model
XprobabilisticModel.Xinput=Xinput;


if NiterationsEC == 0
    % initialise conjugate direction
    if XextremeCase.LiniAsGradAtFirstRealisation
        % compute the gradient (Physical Space) either at the centre of the
        % epistemic space or on first epistemic realization
        % construct the Local Sensitivity by Finite Difference
        Xlsfd=LocalSensitivityFiniteDifference(...
            'Xtarget',XprobabilisticModel,'Coutputnames',{XextremeCase.XprobabilisticModel.SperformanceFunctionVariable});
        % compute the Gradient
        Xgradient = Xlsfd.computeGradient;
        XextremeCase.VgradientDescend= -Xgradient.Valpha;
        XextremeCase.VconjugateDirection=XextremeCase.VgradientDescend;
        % update important direction based on the conjugate direction
        % XadaptiveLineSampling.Vdirection= VgradientDescend;
    elseif XextremeCase.LiniUsingMC
        % run a Monte Carlo simulation. If no fail-points are
        % identified, use Monte Carlo information to approximate
        % the gradient (see Patelli and Pradlwarter paper)
        
        % TODO
    elseif XextremeCase.LuseExistingDirection
        % use the existing direction to initialise the conjugate
        % direction
        XextremeCase.VgradientDescend=[];
        XextremeCase.VconjugateDirection=XextremeCase.VexistingDirection;
    end
end



if XextremeCase.LuseInfoPreviousSimulations && ~isempty(XextremeCase.SresultsPath) && NiterationsEC == 0
    % use existing information to update the important direction
    
    if XextremeCase.LwriteTextFiles==true
        fid = fopen(fullfile(XextremeCase.SresultsPath,'mlimitstatecoordsphy.txt'), 'rt');
        if fid<0
            error('OpenCOSSAN:ExtremeCase:ComputeExtrema',...
                'Cannot open the file with the Limit State points')
        else
            Mlsp = fscanf(fid,'%e',[XextremeCase.NrandomVariablesInnerLoop,inf]);
            fclose(fid);
        end
    else
%         fid = fopen(fullfile(XextremeCase.SresultsPath,'mlimitstatecoordsphy.bin'), 'rt');
%         Mlsp=fread(fid,[inf,XextremeCase.NrandomVariablesInnerLoop],'float64');
%         fclose(fid);
            load(fullfile(XextremeCase.SresultsPath,'mlimitstatecoordsphy.mat'))
    end
    Mlsp=transpose(Mlsp);
    XadaptiveLineSampling.MstatePointsPHY=Mlsp;
    
    % TODO: use failure points as existing info
    
elseif XextremeCase.LuseInfoPreviousSimulations && NiterationsEC > 0
    % use existing information to update the important direction
    
    if XextremeCase.LwriteTextFiles==true
        fid = fopen(fullfile(XextremeCase.StempPath,'mlimitstatecoordsphy.txt'), 'rt');
        if fid<0
            error('OpenCOSSAN:ExtremeCase:ComputeExtrema',...
                'Cannot open the file with the Limit State points')
        else
            Mlsp = fscanf(fid,'%e',[XextremeCase.NrandomVariablesInnerLoop,inf]);
            fclose(fid);
        end
    else
%         fid = fopen(fullfile(XextremeCase.SresultsPath,'mlimitstatecoordsphy.bin'), 'rt');
%         Mlsp=fread(fid,[XextremeCase.NrandomVariablesInnerLoop,inf],'float64');
%         fclose(fid);
            load(fullfile(XextremeCase.SresultsPath,'mlimitstatecoordsphy.mat'));
    end
    Mlsp=transpose(Mlsp);
    XadaptiveLineSampling.MstatePointsPHY=Mlsp;
    
else % recompute the important direction at every iteration step
    
    % compute the gradient (Standard Space)
    % construct the Local Sensitivity by Finite Difference
    Xlsfd=LocalSensitivityFiniteDifference(...
        'Xtarget',XprobabilisticModel,'Coutputnames',{XextremeCase.XprobabilisticModel.SperformanceFunctionVariable});
    % compute the Gradient in SNS
    Xindices = Xlsfd.computeIndices;
    VinitialDirection= -Xindices.Valpha;
    % update important direction based on the conjugate direction
    XadaptiveLineSampling.VdirectionSNS=VinitialDirection;
%     XadaptiveLineSampling.Valpha=VinitialDirection;
    
    % here the important direction is the final direction after ALS is
    % performed Valpha transformed in the phyisical space
    
    % here the conjugate direction is obtained as average of the
    % important directions.
    
end

% perform reliability analysis
 [Xpf,XsimOut]=XadaptiveLineSampling.computeFailureProbability(XprobabilisticModel);

% % process results and create output object
% SperfName=XprobabilisticModel.XperformanceFunction.Soutputname;
% XlineData=LineData('Sdescription','Line Data object',...
%     'Xals',XadaptiveLineSampling,'LdeleteResults',true,...
%     'Sperformancefunctionname',SperfName,...
%     'Xinput',Xinput);


% XlineData=simulations.LineSamplingOutput('Ladaptivelinesampling',true,...
%     'Sperformancefunctionname',XprobabilisticModel.SperformanceFunctionVariable,...
%     'Xinput',Xinput,'Xsimulationdata',XsimOut,'LdeleteResults',true,'Smainpath',XsimOut.SmainPath); 

if isnan(Xpf.pfhat)
    if Lmaximize==true
        Xpf = FailureProbability('CXmembers',{XprobabilisticModel},...
            'Smethod','AdaptiveLineSampling',...
            'pf',0,'variancepf',NaN,...
            'Nsamples',Xpf.Nsamples,...
            'Nlines',XadaptiveLineSampling.Nlines);
    elseif Lmaximize==false
        Xpf = FailureProbability('CXmembers',{XprobabilisticModel},...
            'Smethod','AdaptiveLineSampling',...
            'pf',1,'variancepf',NaN,...
            'Nsamples',Xpf.Nsamples,...
            'Nlines',XadaptiveLineSampling.Nlines);
    end
end
%% Store (and save) results of the analysis

% export important directions (Physical Space)
VimportantDirection=XsimOut.VlastDirectionPHY;

if XextremeCase.LwriteTextFiles==true
    % store coordinates in a text file
    fid = fopen(fullfile(XextremeCase.StempPath,'mimportantdirectionsphy.txt'), 'a');
    fprintf(fid, XextremeCase.SstringTxtInnerLoop, VimportantDirection);
    fclose(fid);
else
%     fid = fopen(fullfile(XextremeCase.StempPath,'mimportantdirectionsphy.bin'), 'rt');
%     if fid<0
%         Mid=VimportantDirection(:)';
%     else
%         Mid=fread(fid,[NiterationsEC,XextremeCase.NrandomVariablesInnerLoop],'float64');
%         fclose(fid);
%         Mid=[Mid;VimportantDirection(:)'];
%     end
%     fid = fopen(fullfile(XextremeCase.StempPath,'mimportantdirectionsphy.bin'), 'w');
%     fwrite(fid, Mid, 'float64');
%     fclose(fid);
    try 
        load(fullfile(XextremeCase.StempPath,'mimportantdirectionsphy.mat'));
        Mid=[Mid;VimportantDirection(:)'];
    catch
        Mid=VimportantDirection(:)';
    end
    save(fullfile(XextremeCase.StempPath,'mimportantdirectionsphy.mat'),'Mid');
     
end

% export limit state points to a matrix array
MstatePointsPhysical=XsimOut.MlimitStateCoordsPHY;
% store limit state points in a text file
if XextremeCase.LwriteTextFiles==true
    fid = fopen(fullfile(XextremeCase.StempPath,'mlimitstatecoordsphy.txt'), 'a');
    fprintf(fid, XextremeCase.SstringTxtInnerLoop, MstatePointsPhysical');
    fclose(fid);
else
%     fid = fopen(fullfile(XextremeCase.StempPath,'mlimitstatecoordsphy.bin'), 'rt');
%     if fid<0
%         Mlsp=MstatePointsPhysical;
%     else
%         Mlsp=fread(fid,[NiterationsEC,XextremeCase.NrandomVariablesInnerLoop],'float64');
%         fclose(fid);
%         Mlsp=[Mlsp;MstatePointsPhysical];
%     end
%     fid = fopen(fullfile(XextremeCase.StempPath,'mlimitstatecoordsphy.bin'), 'w');
%     fwrite(fid, Mlsp, 'float64');
%     fclose(fid);
    try 
        load(fullfile(XextremeCase.StempPath,'mlimitstatecoordsphy.mat'));
        Mlsp=[Mlsp;MstatePointsPhysical];
    catch
        Mlsp=MstatePointsPhysical;
    end
    save(fullfile(XextremeCase.StempPath,'mlimitstatecoordsphy.mat'),'Mlsp');
end

% export fail points to a matrix array
Vg=XsimOut.getValues('Sname',XprobabilisticModel.SperformanceFunctionVariable);
MinputValues=XsimOut.getValues('CSnames',Xinput.CnamesRandomVariable);
MinputFailurePhysical=MinputValues(Vg<0,:);
% store fail points in a text file
if XextremeCase.LwriteTextFiles==true
    fid = fopen(fullfile(XextremeCase.StempPath,'mfailpointcoordsphy.txt'), 'a');
    fprintf(fid, XextremeCase.SstringTxtInnerLoop, MinputFailurePhysical');
    fclose(fid);
else
%     fid = fopen(fullfile(XextremeCase.StempPath,'mfailpointcoordsphy.bin'), 'rt');
%     if fid<0
%         Mfp=MinputFailurePhysical;
%     else
%         Mfp=fread(fid,[NiterationsEC,XextremeCase.NrandomVariablesInnerLoop],'float64');
%         fclose(fid);
%         Mfp=[Mfp;MinputFailurePhysical];
%     end
%     fid = fopen(fullfile(XextremeCase.StempPath,'mfailpointcoordsphy.bin'), 'w');
%     fwrite(fid, Mfp, 'float64');
%     fclose(fid);
    try 
        load(fullfile(XextremeCase.StempPath,'mfailpointcoordsphy.mat'));
        Mfp=[Mfp;MinputFailurePhysical];
    catch
        Mfp=MinputFailurePhysical;
    end
    save(fullfile(XextremeCase.StempPath,'mfailpointcoordsphy.mat'),'Mfp');
end


% store candidate points
VcandidatePoint=cell2mat(varargin);
if XextremeCase.LwriteTextFiles==true
    fid = fopen(fullfile(XextremeCase.StempPath,'mcandidatepointsouterloop.txt'), 'a');
    fprintf(fid, XextremeCase.SstringTxtOuterLoop, VcandidatePoint);
    fclose(fid);
else
%     fid = fopen(fullfile(XextremeCase.StempPath,'mcandidatepointsouterloop.bin'), 'rt');
%     if fid<0
%         Mco=VcandidatePoint(:)';
%     else
%         Mco=fread(fid,[NiterationsEC,XextremeCase.NintervalOuterLoop],'float64');
%         fclose(fid);
%         Mco=[Mco;VcandidatePoint(:)'];
%     end
%     fid = fopen(fullfile(XextremeCase.StempPath,'mcandidatepointsouterloop.bin'), 'w');
%     fwrite(fid, Mco, 'float64');
%     fclose(fid);
    try 
        load(fullfile(XextremeCase.StempPath,'mcandidatepointsouterloop.mat'));
        Mco=[Mco;VcandidatePoint(:)'];
    catch
        Mco=VcandidatePoint(:)';
    end
    save(fullfile(XextremeCase.StempPath,'mcandidatepointsouterloop.mat'),'Mco');
end


% Step increase inner counter
NevaluationsEC=NevaluationsEC+Xpf.Nsamples;


% store matrix of results
Vresults=[Xpf.pfhat,Xpf.cov,Xpf.Nsamples,NevaluationsEC,Lmaximize];
if XextremeCase.LwriteTextFiles==true
    fid = fopen(fullfile(XextremeCase.StempPath,'matrixofresults.txt'), 'a');
    fprintf(fid, '\n %1.12e %1.6e %i %i %i', Vresults);
    fclose(fid);
else
%     fid = fopen(fullfile(XextremeCase.StempPath,'matrixofresults.bin'), 'rt');
%     if fid<0
%         Mr=Vresults;
%     else
%         Mr=fread(fid,[5,inf],'float64');
%         fclose(fid);
%         Mr=[Mr';Vresults];
%     end
%     fid = fopen(fullfile(XextremeCase.StempPath,'matrixofresults.bin'), 'w');
%     fwrite(fid, Mr, 'float64');
%     fclose(fid);
    try 
        load(fullfile(XextremeCase.StempPath,'matrixofresults.mat'));
        Mr=[Mr;Vresults];
    catch
        Mr=Vresults;
    end
    save(fullfile(XextremeCase.StempPath,'matrixofresults.mat'),'Mr');
end


if NiterationsEC == 0
    % create a file for instructions
    fid = fopen(fullfile(XextremeCase.StempPath,'matrixofresultsinfo.txt'), 'a');
    Sresults='pfhat,  cov,  N. samples,  total N. samples,  maximize true/false';
    fprintf(fid, Sresults);
    fclose(fid);
end


% Step increase counter of total simulations
NiterationsEC=NiterationsEC+1;

% end, %end condition over maximum number of iterations/evaluations

% Assign output
COSSANoutput{1}=Xpf;