function Xss=constructSolutionSequence(Xobj)
% CONSTUCTSOLUTIONSEQUENCE This function is used to create a
% SolutionSequence object required to evaluate the inner loop in the 
% IntervalAnalysis
%
% See also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/constructSolutionSequence@IntervalAnalysis
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

if isa(Xobj.Xsolver,'GeneticAlgorithms')
    CXobjects={Xobj.XgeneticAlgorithms,Xobj};
    CobjectsTypes={'GeneticAlgorithms','IntervalAnalysis'};
    CobjectsNames={'XgeneticAlgorithm','XintervalAnalysis'};
elseif isa(Xobj.Xsolver,'Bobyqa')
    % TODO: add optimization solver, such as BOBYQA
else
    % user defined script will not run 
    CXobjects={Xobj};
    CobjectsTypes={'IntervalAnalysis'};
    CobjectsNames={'XintervalAnalysis'};
end

% construct solution sequence
Xss=SolutionSequence(...
    'Sfile','solutionSequenceIntervalAnalysis.m',...
    'Spath',fullfile(OpenCossan.getCossanRoot,'src','interval','userDefinedScripts'),...
    'CinputNames', Cinputs,...
    'Coutputnames',{Xobj.SintervalOutputName},...
    'CobjectsNames',{'XsimOut'},...
    'CprovidedObjectTypes',{'SimulationData'},...
    ...'Cobject2input',{'.NmaxIterations','.NmaxEvaluations'},...
    ...'Cobject2output',{'.pfhat'}, ...
    ...'CglobalObjects',{'NiterationsEC,NevaluationsEC,MfailurePointsEC,MstatePointsEC'},...
    'CXobjects',CXobjects,...
    'CobjectsTypes',CobjectsTypes,...
    'CobjectsNames',CobjectsNames);