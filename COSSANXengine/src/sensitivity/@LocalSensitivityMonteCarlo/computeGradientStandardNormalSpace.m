function varargout=computeGradientStandardNormalSpace(Xobj)
%COMPUTEGRADIENT This method does the Sensitivity analysis 
%
% $Copyright~1993-2019,~COSSAN~Working~Group$
% $Author: Edoardo-Patelli$

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


% Set the analysis name when not deployed
if ~isdeployed
    OpenCossan.setAnalysisName(class(Xobj));
end
% set the analyis ID 
OpenCossan.setAnalysisID;
% insert entry in Analysis DB
if ~isempty(OpenCossan.getDatabaseDriver)
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Analysis',...
        'Nid',OpenCossan.getAnalysisID);
end

% Select the appropriate method
[Vgradient, NfunctionEvaluation, varargout{2}]=Xobj.doMonteCarlo;

% Export results

varargout{1}=Gradient('Sdescription',...
        ['Monte Carlo Gradient estimation of ' Xobj.Coutputnames{:}], ...
        'Cnames',Xobj.Cinputnames, ...
        'LstandardNormalSpace',true, ...
        'NfunctionEvaluation',NfunctionEvaluation,...
        'Vgradient',Vgradient,'Vreferencepoint',Xobj.VreferencePoint,...
        'SfunctionName',Xobj.Coutputnames{1});

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',varargout(1),...
            'CcossanObjectsNames',{'Xgradient'});
    end
end
