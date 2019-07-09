function varargout=computeIndices(Xobj,varargin)
%COMPUTEINDICES This method computes the indices of for Global Sensitivity
%analysis based on Random Balance Design methods
%
% See Also:
% https://cossan.co.uk/wiki/index.php/computeIndices@GlobalSensitivityRandomBalanceDesign
% 
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

%% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xtarget','xmodel'}
            Xobj=Xobj.addModel(varargin{k+1}(1));
        case {'cxtarget','cxmodel'}
            Xobj=Xobj.addModel(varargin{k+1}{1});
        otherwise
            error('openCOSSAN:GlobalSensitivityRandomBalanceDesign:computeIndices',...
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

%% Compute Sobol' Indices

[MfirstOrder, MfirstOrderCoV, MfirstOrderCI, varargout{2}]=Xobj.runRandomBalanceDesign;


%% Export results
% Construct SensitivityMeasure object
for n=1:length(Xobj.Coutputnames)    
    varargout{1}(n)=SensitivityMeasures('Cinputnames',Xobj.Cinputnames, ... 
    'Soutputname',  Xobj.Coutputnames{n},'Xevaluatedobject',Xobj.Xtarget, ...
    'Sevaluatedobjectname',Xobj.Sevaluatedobjectname, ...
    'VsobolFirstIndices',MfirstOrder(:,n)', ...
    'VsobolFirstIndicesCoV',MfirstOrderCoV(:,n)', ...
    'Msobolfirstorderci',MfirstOrderCI(:,:,n), ...
    'Sestimationmethod','Sensitivity.randomBalanceDesign'); %#ok<AGROW>
end

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