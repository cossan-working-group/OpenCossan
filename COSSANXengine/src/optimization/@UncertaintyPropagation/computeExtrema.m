function Xextrema=computeExtrema(Xobj)
% COMPUTEEXTREMA is a private method of UncertaintyPropagation. The purpose of this
% method is to finalize the UncertaintyPropgation analysis, computing the extreme
% values of the statistical quantity of interest with any searching
% procedure
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/computeExtrema@UncertaintyPropagation
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
%% clear the directory from existing txt files
delete(fullfile(Xobj.StempPath,'*.txt'));

%% create temporary directory
[~,~]=mkdir(Xobj.StempPath);
%% Perform the global min/max optimization
[CXresults,Niterations]=Xobj.extremize();
%% delete simulation results
% delete automatically generated simulation folders
if Xobj.LdeleteSimulationResults
    vtime=clock;
    string=num2str(vtime(1));
    [~,~]=rmdir(fullfile(OpenCossan.getCossanWorkingPath,string,'*'),'s');
end
%% Extract info from the analysis
% extract candidate realizations
if Xobj.LwriteTextFiles==true
    fid = fopen(fullfile(Xobj.StempPath,'mcandidatepointsouterloop.txt'), 'r');
    if fid<0
        error('OpenCOSSAN:ExtremeCase:ComputeExtrema',...
            'There is no file containing candidate points is empty')
    else
        Mcp = fscanf(fid, '%e', [Xobj.NintervalOuterLoop,Niterations]);
        fclose(fid);
    end
    Mcp=transpose(Mcp);
    mcandidatepointsouterloop=Mcp;
    save(fullfile(Xobj.StempPath,'mcandidatepointsouterloop.mat'),'mcandidatepointsouterloop')
else
    fid = fopen(fullfile(Xobj.StempPath,'mcandidatepointsouterloop.bin'), 'rt');
    Mcp=fread(fid,[Niterations,Xobj.NintervalOuterLoop],'float64');
    fclose(fid);
end


% extract matrix of results
if Xobj.LwriteTextFiles==true
    fid = fopen(fullfile(Xobj.StempPath,'matrixofresults.txt'), 'r');
    if fid<0
        error('OpenCOSSAN:ExtremeCase:ComputeExtrema',...
            'There is no file containing results from the global search is empty')
    else
        Mre = fscanf(fid, '%e', [6,Niterations]);
        fclose(fid);
    end
    Mre=transpose(Mre);
    matrixofresults=Mre;
    save(fullfile(Xobj.StempPath,'matrixofresults.mat'),'matrixofresults')
else
    fid = fopen(fullfile(Xobj.StempPath,'matrixofresults.bin'), 'rt');
    Mre=fread(fid,[Niterations,Xobj.NrandomVariablesInnerLoop],'float64');
    fclose(fid);
end

%% Post process the results
VoutValues=Mre(:,2);
[MINIMUM,posMIN]=min(VoutValues);
[MAXIMUM,posMAX]=max(VoutValues);

VargMINIMUM=Mcp(posMIN,:);
VargMAXIMUM=Mcp(posMAX,:);

covMINIMUM=Mre(posMIN,3);
covMAXIMUM=Mre(posMAX,3);

Nevaluations=Mre(end,5);
%% Outputs
Xextrema=Extrema('Sdescription','Solution of the Uncertainty Propagation analysis',...
    'CdesignVariableNames',Xobj.CintervalVariableNames,...
    'CVargOptima',{VargMINIMUM,VargMAXIMUM},...
    ...'CXoptima',{XpfMin,XpfMax},...
    'Coptima',{MINIMUM,MAXIMUM},...
    'CcovOptima',{covMINIMUM,covMAXIMUM},...
    ...'CXsimOutOptima',{XsimOutMin,XsimOutMax},...
    'CXresults',CXresults,...
    'XanalysisObject',Xobj,...
    'NmodelEvaluations',Nevaluations,...
    'Niterations',Niterations);

