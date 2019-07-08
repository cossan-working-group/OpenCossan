function Xextrema=computeExtrema(Xobj)
% COMPUTEEXTREMA is a private method of ExtremeCase. The purpose of this
% method is to finalize the ExtremeCase analysis, computing the extreme
% values of the failure probability using the information from the optimum.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/computeExtrma@ExtremeCase
%
% Author:~Marco~de~Angelis
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

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
%% delete simulation results
% delete automatically generated simulation folders
if Xobj.LdeleteSimulationResults
    vtime=clock;
    string=num2str(vtime(1));
    [status,result]=rmdir(fullfile(OpenCossan.getCossanWorkingPath,string,'*'),'s');
end
if Xobj.LuserDefinedConjugateDirection
    VaverageConjugateDirection=Xobj.VuserDefinedConjugateDirection;
else
    %% clear the directory from existing txt files
    delete(fullfile(Xobj.StempPath,'*.txt'));
    
    %% create temporary directory
    [~,~]=mkdir(Xobj.StempPath);
    %% Perform the global min/max optimization
    [CXresults,Niterations]=Xobj.extremize();
    %% Extract info from the search analysis
    % extract limit state points from the analysis
    if Xobj.LwriteTextFiles==true
        fid = fopen(fullfile(Xobj.StempPath,'mlimitstatecoordsphy.txt'), 'rt');
        if fid<0
            error('OpenCOSSAN:ExtremeCase:ComputeExtrema',...
                'The matrix containing Limit State points is empty')
        else
            Mlsp = fscanf(fid,'%e',[Xobj.NrandomVariablesInnerLoop,Niterations]);
            fclose(fid);
            Mlsp = Mlsp';
        end
    else
        %         fid = fopen(fullfile(Xobj.StempPath,'mlimitstatecoordsphy.bin'), 'rt');
        %         Mlsp=fread(fid,[Niterations,Xobj.NrandomVariablesInnerLoop],'float64');
        %         fclose(fid);
        load(fullfile(Xobj.StempPath,'mlimitstatecoordsphy.mat'));
    end
    
    % extract points in the failure region
    if Xobj.LwriteTextFiles==true
        fid = fopen(fullfile(Xobj.StempPath,'mfailpointcoordsphy.txt'), 'r');
        if fid<0
            error('OpenCOSSAN:ExtremeCase:ComputeExtrema',...
                'The matrix containing Failure points is empty')
        else
            Mfp = fscanf(fid, '%e', [Xobj.NrandomVariablesInnerLoop,Niterations]);
            fclose(fid);
            Mfp = Mfp';
        end
    else
        %         fid = fopen(fullfile(Xobj.StempPath,'mfailpointcoordsphy.bin'), 'rt');
        %         Mfp=fread(fid,[Niterations,Xobj.NrandomVariablesInnerLoop],'float64');
        %         fclose(fid);
        load(fullfile(Xobj.StempPath,'mfailpointcoordsphy.mat'));
    end
    
    % extract candidate realizations
    if Xobj.LwriteTextFiles==true
        fid = fopen(fullfile(Xobj.StempPath,'mcandidatepointsouterloop.txt'), 'r');
        if fid<0
            error('OpenCOSSAN:ExtremeCase:ComputeExtrema',...
                'The matrix containing candidate points is empty')
        else
            Mcp = fscanf(fid, '%e', [Xobj.NintervalOuterLoop,Niterations]);
            fclose(fid);
            Mcp = Mcp';
        end
    else
        %         fid = fopen(fullfile(Xobj.StempPath,'mcandidatepointsouterloop.bin'), 'rt');
        %         Mcp=fread(fid,[Niterations,Xobj.NintervalOuterLoop],'float64');
        %         fclose(fid);
        load(fullfile(Xobj.StempPath,'mcandidatepointsouterloop.mat'));
    end
    
    
    % extract matrix of results
    if Xobj.LwriteTextFiles==true
        fid = fopen(fullfile(Xobj.StempPath,'matrixofresults.txt'), 'r');
        if fid<0
            error('OpenCOSSAN:ExtremeCase:ComputeExtrema',...
                'The matrix containing results from the global search is empty')
        else
            Mre = fscanf(fid, '%e', [5 inf]);
            fclose(fid);
        end
    else
        %         fid = fopen(fullfile(Xobj.StempPath,'matrixofresults.bin'), 'rt');
        %         Mre=fread(fid,[Niterations,Xobj.NrandomVariablesInnerLoop],'float64');
        %         fclose(fid);
        load(fullfile(Xobj.StempPath,'matrixofresults.mat'));
    end
    
    % extract important directions (Physical Space)
    if Xobj.LwriteTextFiles==true
        fid = fopen(fullfile(Xobj.StempPath,'mimportantdirectionsphy.txt'), 'r');
        if fid<0
            error('OpenCOSSAN:ExtremeCase:ComputeExtrema',...
                'The file containing the important directions is empty')
        else
            Mid = fscanf(fid, '%e', [Xobj.NrandomVariablesInnerLoop,Niterations]);
            fclose(fid);
            Mid = Mid';
        end
    else
        %         fid = fopen(fullfile(Xobj.StempPath,'mimportantdirectionsphy.bin'), 'rt');
        %         Mid=fread(fid,[Niterations,Xobj.NrandomVariablesInnerLoop],'float64');
        %         fclose(fid);
        load(fullfile(Xobj.StempPath,'mimportantdirectionsphy.mat'));
    end
    %% Compute conjugate directions
    % Most probable important directions are averaged to obtain the
    % conjugate direction. This direction is also referred to as
    % Averaged Conjugate Direction
    VaverageConjugateDirection=mean(Mid,1);
end

%     % The following is a conjugate direction obtained connecting the centre
%     % of mass of the failure points to the median state. This direction is
%     % also called Failure (Mode) Conjugate Direction
%     VfailureCentreMass=mean(Mfp,1);
%     % get the median state
%     VmedianCoordinates=Xobj.XinputProbabilistic.getStatistics('CSstatistic',{'median'});
%     VfailureConjugateDirection=VfailureCentreMass-VmedianCoordinates;
%     VfailureConjugateDirection=VfailureConjugateDirection/norm(VfailureConjugateDirection);

% These two directions should not differ much from one another. It is
% essential that every coordinate of one direction has the same sign
% of the equivalent coordinate of the other direction. If this is not
% the case, it does not mean that the analysis is to throw away, but it
% may mean that that coordinate has little relevance or contribute a
% little on the overall failure probability.

%% Process the results

% Extract the sign and bounds of design variables
VsignConjBeam=sign(VaverageConjugateDirection);
[Vlower,Vupper]=Xobj.XinputMapping.getBounds;
Mbounds=[Vlower;Vupper];



Nintervals = length(Xobj.CdesignMapping(:,1));
Nvariables = length(Xobj.XinputOriginal.CnamesRandomVariable);
Ninputs = Nintervals+Nvariables;
indexes=zeros(1,Nintervals);
CnamesIntervals=Xobj.CdesignMapping(:,1)';
for n=1:size(Xobj.CdesignMapping,1)
    switch lower(Xobj.CdesignMapping{n,3})
        case 'mean'
            CnamesIntervals(n)=Xobj.CdesignMapping(n,2)';
        case {'std', 'var'}
            CnamesIntervals(n)=Xobj.CdesignMapping(n,1)';
    end
end

% Random variables have to be always before the intervals
CnamesInputs=[Xobj.XinputOriginal.CnamesRandomVariable,Xobj.XinputOriginal.CnamesIntervalVariable];
for n=1:Ninputs
    for h=1:Nintervals
        if strcmpi(CnamesInputs{n},CnamesIntervals{h})
            indexes(h)=n;
        end
    end
end

VargMinimum=zeros(1,size(Xobj.CdesignMapping,1));
VargMaximum=zeros(1,size(Xobj.CdesignMapping,1));
k=0;
h=0;
for n=1:size(Xobj.CdesignMapping,1)
    switch lower(Xobj.CdesignMapping{n,3})
        case 'mean'
            k=k+1;
            posMin=round(-VsignConjBeam(indexes(k))/2+0.01)+1;
            posMax=round(VsignConjBeam(indexes(k))/2+0.01)+1;
            VargMinimum(n)=Mbounds(posMin,n);
            VargMaximum(n)=Mbounds(posMax,n);
        case {'std', 'var'}
            k=k+1;
            h=h+1;
            if isempty(Xobj.MstandardDeviationCheckPoints)
                VargMinimum(n)=Mbounds(1,n);
                VargMaximum(n)=Mbounds(2,n);
            else
                centre=(Mbounds(2,n)+Mbounds(1,n))/2;
                radius=(Mbounds(2,n)-Mbounds(1,n))/2;
                VargMinimum(n)=centre+Xobj.MstandardDeviationCheckPoints(h,1)*radius;
                VargMaximum(n)=centre+Xobj.MstandardDeviationCheckPoints(h,2)*radius;
            end
    end
end

%% compute the optima running two reliability analyses on the candidate arguments
%% compute MAXIMUM
% Extract Input from Extreme Case object
Xinput=Xobj.XinputParameters;
% Extract Evaluator from ProbabilisticModel object
Xevaluator=Xobj.XprobabilisticModel.Xmodel.Xevaluator;
% Extract PerformanceFunction and performance function name
XperformanceFunction=Xobj.XprobabilisticModel.XperformanceFunction;
SperfName=XperformanceFunction.Soutputname;
% Update Input object
warning('OFF','OpenCossan:Parameter:set:obsolete')
Nvariables2map=size(Xobj.CdesignMapping,1);
for n=1:Nvariables2map
    Xinput=Xinput.set('SobjectName',Xobj.CdesignMapping{n,2},...
        'SpropertyName',Xobj.CdesignMapping{n,4},'value',VargMaximum(n));
end
% Reconstruct Model
Xmodel=Model('Xinput',Xinput,'Xevaluator',Xevaluator);
% Reconstruct ProbabilisticModel
Xpm=ProbabilisticModel('XperformanceFunction',XperformanceFunction,'Xmodel',Xmodel);
% Write the updated input into the probabilistic model
Xpm.Xmodel.Xinput=Xinput;
% Extract RandomVariables index
CRVnames=Xobj.XinputOriginal.CnamesRandomVariable;
for k=1:Nvariables
    for h=1:length(VsignConjBeam)
        if strcmpi(CnamesInputs{h},CRVnames{k})
            RVindex(k)=h;
        end
    end
end
% Assign direction based on the RVs only
Vdirection=VsignConjBeam(RVindex);
Xobj.XadaptiveLineSampling.Valpha=Vdirection/norm(Vdirection);
% reliability analysis for the maximum
if Xobj.LuseMCtoFinalise
    Xmc=MonteCarlo('Nsamples',Xobj.NmonteCarloSamples);
    [XpfMAX,~]=Xmc.computeFailureProbability(Xpm);
else
    [XpfMAX,~]=Xobj.XadaptiveLineSampling.computeFailureProbability(Xpm);
    
    XlineDataMAX=LineData('Sdescription','My first Line Data object',...
    'Xals',Xobj.XadaptiveLineSampling,'LdeleteResults',false,...
    'Sperformancefunctionname',SperfName,...
    'Xinput',Xinput);
end
%% compute MINIMUM
% Extract Input from Extreme Case object
Xinput=Xobj.XinputParameters;
% Extract Evaluator from ProbabilisticModel object
Xevaluator=Xobj.XprobabilisticModel.Xmodel.Xevaluator;
% Extract PerformanceFunction and performance function name
XperformanceFunction=Xobj.XprobabilisticModel.XperformanceFunction;
SperfName=XperformanceFunction.Soutputname;
% Update Input object
warning('OFF','OpenCossan:Parameter:set:obsolete')
Nvariables2map=size(Xobj.CdesignMapping,1);
for n=1:Nvariables2map
    Xinput=Xinput.set('SobjectName',Xobj.CdesignMapping{n,2},...
        'SpropertyName',Xobj.CdesignMapping{n,4},'value',VargMinimum(n));
end
% Reconstruct Model
Xmodel=Model('Xinput',Xinput,'Xevaluator',Xevaluator);
% Reconstruct ProbabilisticModel
Xpm=ProbabilisticModel('XperformanceFunction',XperformanceFunction,'Xmodel',Xmodel);
% Write the updated input into the probabilistic model
Xpm.Xmodel.Xinput=Xinput;

if Xobj.LuseMCtoFinalise
    Xmc=MonteCarlo('Nsamples',Xobj.NmonteCarloSamples);
    [XpfMIN,~]=Xmc.computeFailureProbability(Xpm);
else
    % reliability analysis for the minimum
    [XpfMIN,~]=Xobj.XadaptiveLineSampling.computeFailureProbability(Xpm);
    
    XlineDataMIN=LineData('Sdescription','My first Line Data object',...
        'Xals',Xobj.XadaptiveLineSampling,'LdeleteResults',false,...
        'Sperformancefunctionname',SperfName,...
        'Xinput',Xinput);
end

%% Post process the results
if Xobj.LuserDefinedConjugateDirection
    if Xobj.LuseMCtoFinalise
        Nevaluations=2*Xobj.NmonteCarloSamples;
    else
        Nevaluations=XlineDataMAX.Nevaluations+XlineDataMIN.Nevaluations;
    end
    CXresults{1}=Optimum;
    Niterations=0;
else
    if Xobj.LuseMCtoFinalise
        Nevaluations=2*Xobj.NmonteCarloSamples;
    else
        Nevaluations=size(Mfp,1)+XlineDataMAX.Nevaluations+XlineDataMIN.Nevaluations;
    end
end
%% Assign the output of the analysis
Xextrema=Extrema('Sdescription','Solution of the Extreme Case analysis',...
    'CdesignVariableNames',Xobj.CdesignMapping(:,1),...
    'CVargOptima',{VargMinimum,VargMaximum},...
    'CXoptima',{XpfMIN,XpfMAX},...
    'Coptima',{XpfMIN.pfhat,XpfMAX.pfhat},...
    'CcovOptima',{XpfMIN.cov,XpfMAX.cov},...
    ...'CXsimOutOptima',{XsimOutMin,XsimOutMax},...
    'CXresults',CXresults,...
    'XanalysisObject',Xobj,...
    'NmodelEvaluations',Nevaluations,...
    'Niterations',Niterations);

