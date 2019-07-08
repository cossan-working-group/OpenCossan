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
OpenCossan.validateCossanInputs(varargin{:})
% OpenCossan.resetRandomNumberGenerator(357357)
%% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xtarget','xmodel'}
            Xobj=Xobj.addModel(varargin{k+1}(1));
        case {'cxtarget','cxmodel'}
            Xobj=Xobj.addModel(varargin{k+1}{1});
        otherwise
            error('openCOSSAN:LocalSensitivityMonteCarlo:computeIndices:WrontInputArgument',...
                'The PropertyName %s is not allowed',varargin{k});
    end
end

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

% Get the local indices
[Mindices, NfunctionEvaluation, varargout{2}]=Xobj.doMonteCarlo;

% Compute Local Indices

%% Export results
varargout{1}(length(Xobj.Coutputnames))=LocalSensitivityMeasures;
for n=1:length(Xobj.Coutputnames)
    varargout{1}(n)=LocalSensitivityMeasures('Sdescription',...
        ['Finite Difference estimation the local sensitivity analysis of ' Xobj.Coutputnames{n}], ...
        'Cnames',Xobj.Cinputnames, ...
        'NfunctionEvaluation',NfunctionEvaluation,...
        'Vmeasures',Mindices(:,n),'Vreferencepoint',Xobj.VreferencePoint,...
        'SfunctionName',Xobj.Coutputnames{n});
end

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',....
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',varargout(1),...
            'CcossanObjectsNames',{'Xgradient'});
    end
end
