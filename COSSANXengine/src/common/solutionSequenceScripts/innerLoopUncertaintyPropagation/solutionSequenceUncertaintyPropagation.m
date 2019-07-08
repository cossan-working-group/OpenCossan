% Solution Sequence Script for the EXTREME CASE analysis

% Declare global variable to use results from previous iterations
global  NiterationsUP NevaluationsUP Lmaximize

Xobj=XuncertaintyPropagation;

% initialise inner counter
if isempty(NevaluationsUP),
    NevaluationsUP=0;           % How many times the innerloop calls the model
end,

% initialise outer counter
if isempty(NiterationsUP),
    NiterationsUP=0;            % How many times the outerloop calls the innerloop
end,

%% Write the candidate point on a file
% store candidate points
VcandidatePoint=cell2mat(varargin);
if Xobj.LwriteTextFiles==true
    fid = fopen(fullfile(Xobj.StempPath,'mcandidatepointsouterloop.txt'), 'a');
    fprintf(fid, Xobj.SstringTxtOuterLoop, VcandidatePoint);
    fclose(fid);
else
    % this is a little slower
    try
        load(fullfile(Xobj.StempPath,'mcandidatepointsouterloop.mat'));
        Mcp=[Mcp;VcandidatePoint(:)'];
    catch
        Mcp=VcandidatePoint(:)';
    end
    save(fullfile(Xobj.StempPath,'mcandidatepointsouterloop.mat'),'Mcp');
end
%% Extract Input from ProbabilisticModel object
Xinput=Xobj.XinputEquivalent;
% Extract Evaluator from ProbabilisticModel object
Xevaluator=XprobabilisticModel.Xmodel.Xevaluator;
% Extract PerformanceFunction and performance function name
XperformanceFunction=XprobabilisticModel.XperformanceFunction;
SperformanceFunctionName=XperformanceFunction.Soutputname;

%% Update Input object

warning('OFF','OpenCossan:Parameter:set:obsolete')
Nvariables2map=size(Xobj.CdesignMapping,1);
for n=1:Nvariables2map
    Xinput=Xinput.set('SobjectName',Xobj.CdesignMapping{n,2},...
        'SpropertyName',Xobj.CdesignMapping{n,3},'value',varargin{n});
end

% Reconstruct Model
Xmodel=Model('Xinput',Xinput,'Xevaluator',Xevaluator);
% Reconstruct ProbabilisticModel
XprobabilisticModel=ProbabilisticModel('XperformanceFunction',XperformanceFunction,'Xmodel',Xmodel);
% Write the updated input into the probabilistic model
XprobabilisticModel.Xmodel.Xinput=Xinput;

[Xpf,XsimOut]=Xsimulator.computeFailureProbability(XprobabilisticModel);


%     if LkeepFailurePoints,
%         VperformanceValues=XsimOut.getValues('Sname',SperformanceFunctionName);
%         MinputValues=XsimOut.getValues('CSnames',Xinput.Cnames);
%         MinputFailurePhysical=MinputValues(VperformanceValues<0,:);
%         MfailurePointsUP=[MfailurePointsUP;MinputFailurePhysical];
%     end,

% Step increase inner counter
NevaluationsUP=NevaluationsUP+Xpf.Nsamples;
% Step increase counter of total simulations
NiterationsUP=NiterationsUP+1;

% assign output
COSSANoutput{1}=Xpf;

%% Write results on a file

% store matrix of results
Vresults=[NiterationsUP,Xpf.pfhat,Xpf.cov,Xpf.Nsamples,NevaluationsUP,Lmaximize];
if Xobj.LwriteTextFiles==true
    fid = fopen(fullfile(Xobj.StempPath,'matrixofresults.txt'), 'a');
    fprintf(fid, '\n %i %1.12e %1.6e %i %i %i', Vresults);
    fclose(fid);
else
    % this is a little slower
    try
        load(fullfile(Xobj.StempPath,'matrixofresults.mat'));
        Mre=[Mre;Vresults];
    catch
        Mre=Vresults;
    end
    save(fullfile(Xobj.StempPath,'matrixofresults.mat'),'Mre');
end

if NiterationsUP == 1
    % create a file for instructions
    fid = fopen(fullfile(Xobj.StempPath,'READMEmatrixofresults.txt'), 'a');
    Sresults=['| N. of iterations |   pfhat |  cov |  N. of samples |  total N. of samples  |  maximize true/false |'];
    fprintf(fid, Sresults);
    fclose(fid);
end


