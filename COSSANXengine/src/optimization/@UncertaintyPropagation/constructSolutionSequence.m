function Xss=constructSolutionSequence(Xobj)
% CONSTUCTSOLUTIONSEQUENCE This function is used to create a
% SolutionSequence object required to evaluate the inner loop of the uncertainty propagation.
%
% See also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/constructSolutionSequence@UncertaintyPropagation
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

% See the solutionSequence file in "COSSANXengine/src/interval/userDefinedScripts/"

% % get the object's path
% SobjectPath=fileparts(which(class(Xobj)));
% % get the pathwhere the script is stored
% SfullPath=fullfile(SobjectPath,'innerLoopScripts');

% get the pathwhere the script is stored
SfullPath=fullfile(OpenCossan.getCossanRoot,'src','common',...
    'solutionSequenceScripts','innerLoopUncertaintyPropagation');

if strcmpi(Xobj.SstatisticalQuantityName,'failureProbability')

% construct solution sequence
Xss=SolutionSequence(...
    'Sfile','solutionSequenceUncertaintyPropagation.m',...
    'Spath',SfullPath,...
    'CinputNames', Cinputs,...
    'Coutputnames',{'pf'},...
    'Cobject2output',{'.pfhat'}, ...
    'CglobalObjects',{'NiterationsUP,NevaluationsUP,MfailurePointsUP','MatrixOfResults','Lmaximize'},...
    'CobjectsNames',{'XfailureProbability'},...
    'CprovidedObjectTypes',{'FailureProbability'},...
    'CXobjects',{Xobj.XprobabilisticModel,Xobj.Xsimulator,Xobj},...
    'CobjectsTypes',{'ProbabilisticModel','Simulations','UncertaintyPropagation'},...
    'CobjectsNames',{'XprobabilisticModel','Xsimulator','XuncertaintyPropagation'} );

elseif strcmpi(Xobj.SstatisticalQuantity,'mean')
    
elseif strcmpi(Xobj.SstatisticalQuantity,'variance')
    
end
