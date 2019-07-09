function Xss=constructSolutionSequence(Xobj)
% CONSTUCTSOLUTIONSEQUENCE This function is used to create a
% SolutionSequence object required to evaluate the inner loop in the
% ExtremeCase analysis
%
% See also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/constructSolutionSequence@ExtremeCase
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
% Predefine variables
Cinputs=Xobj.CdesignMapping(:,1);

if Xobj.LsearchByGA
    CXobjects={Xobj.XprobabilisticModel,Xobj.XadaptiveLineSampling,Xobj.XgeneticAlgorithms,Xobj};
    CobjectsTypes={'opencossan.reliability.ProbabilisticModel',...
        'opencossan.simulations.AdaptiveLineSampling',...
        'opencossan.optimization.GeneticAlgorithms',...
        'opencossan.intervals.ExtremeCase'};
    CobjectsNames={'XprobabilisticModel','XadaptiveLineSampling','XgeneticAlgorithm','XextremeCase'};
else
    % user defined script will not run 
    CXobjects={Xobj.XprobabilisticModel,Xobj.XadaptiveLineSampling,Xobj};
    CobjectsTypes={'opencossan.reliability.ProbabilisticModel',...
        'opencossan.simulations.AdaptiveLineSampling',...
        'opencossan.intervals.ExtremeCase'};
    CobjectsNames={'XprobabilisticModel','XadaptiveLineSampling','XextremeCase'};
end

% % get the object's path
% SobjectPath=fileparts(which(class(Xobj)));
% the path where scripts are stored
% SfullPath=fullfile(SobjectPath,'innerLoopScripts');

% get the pathwhere the script is stored
SfullPath=fullfile(OpenCossan.getCossanRoot,'src','+intervals',...
    'solutionSequenceScripts','innerLoopExtremeCase');

% construct solution sequence
 Xss=opencossan.workers.SolutionSequence(...
    'Sfile','solutionSequenceExtremeCase.m',...
    'Spath',SfullPath,...
    'CinputNames', Cinputs,...
    'Coutputnames',{Xobj.SfailureProbabilityName},...
    ...'Cobject2input',{'.NmaxIterations','.NmaxEvaluations'},...
    'Cobject2output',{'.pfhat'}, ...
    'CglobalObjects',{'NiterationsEC,NevaluationsEC,MfailurePointsEC,MstatePointsEC'},...
    'CobjectsNames',{'XfailureProbability'},...
    'CprovidedObjectTypes',{'opencossan.reliability.FailureProbability'},...
    'CXobjects',CXobjects,...
    'CobjectsTypes',CobjectsTypes,...
    'CobjectsNames',CobjectsNames);