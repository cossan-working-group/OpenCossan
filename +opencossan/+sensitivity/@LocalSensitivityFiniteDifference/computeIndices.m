function varargout=computeIndices(Xobj,varargin)
%COMPUTEINDICES This method does the Local Sensitivity analysis, and
%computes the local sensitivity indices
%
% $Copyright~1993-2017,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
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


%% Check inputs
opencossan.OpenCossan.validateCossanInputs(varargin{:})
% OpenCossan.resetRandomNumberGenerator(357357)
%% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xtarget','xmodel'}
            Xobj=Xobj.addModel(varargin{k+1}(1));
        case {'cxtarget','cxmodel'}
            Xobj=Xobj.addModel(varargin{k+1}{1});
        otherwise
            error('openCOSSAN:LocalSensitivityFiniteDifference:computeIndices:WrontInputArgument',...
                'The PropertyName %s is not allowed',varargin{k});
    end
end

% Set the analysis name when not deployed
if ~isdeployed
    opencossan.OpenCossan.setAnalysisName(class(Xobj));
end
% set the analyis ID 
opencossan.OpenCossan.setAnalysisId(opencossan.OpenCossan.getAnalysisId + 1); %% TODO: check analysis id increment...
% insert entry in Analysis DB
if ~isempty(opencossan.OpenCossan.getDatabaseDriver)
    insertRecord(opencossan.OpenCossan.getDatabaseDriver,'StableType','Analysis',...
        'Nid',opencossan.OpenCossan.getAnalysisID);
end
%% Export results
% Evaluate the gradient
[~, Mindices, NfunctionEvaluation, varargout{2}]=Xobj.doFiniteDifferences;

% Compute Local Indices

%% Export results

for n=1:length(Xobj.Coutputnames)
    varargout{1}(n)=opencossan.sensitivity.LocalSensitivityMeasures('Sdescription',...
        ['Finite Difference estimation the local sensitivity analysis of ' Xobj.Coutputnames{n}], ...
        'Cnames',Xobj.Cinputnames, ...
        'NfunctionEvaluation',NfunctionEvaluation,...
        'Vmeasures',Mindices(:,n),'Vreferencepoint',Xobj.VreferencePoint,...
        'SfunctionName',Xobj.Coutputnames{n}); %#ok<AGROW>
end

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = opencossan.OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',varargout(1),...
            'CcossanObjectsNames',{'Xgradient'});
    end
end