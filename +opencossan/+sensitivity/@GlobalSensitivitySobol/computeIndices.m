function varargout=computeIndices(Xobj,varargin)
%COMPUTEINDICES This method does the Local Sensitivity analysis, and
%computes the local sensitivity indices
%
% $Copyright~1993-2017,~COSSAN~Working~Group,~UK$
% $Author: Edoardo-Patelli and Ganesh Ala$

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
        case {'smethod'}
            assert(ismember(lower(varargin{k+1}),Xobj.CmethodNames), ...
                'openCOSSAN:GlobalSensitivitySobol:methodNotValid',...
                'The method %s is not a valid name. Available methods are %s',...
                varargin{k+1},sprintf('"%s" ',Xobj.CmethodNames{:}))
        case {'nfrequency'}
            Xobj.NfreqValue=varargin{k+1};
        otherwise
            error('openCOSSAN:GlobalSensitivitySobol:computeIndices',...
                'The PropertyName %s is not allowed',varargin{k});
    end
end
%% Set the analysis name when not deployed
if ~isdeployed
    opencossan.OpenCossan.setAnalysisName(class(Xobj));
end
%% Set the analysis ID
if isempty(opencossan.OpenCossan.getAnalysisId())
    opencossan.OpenCossan.setAnalysisId(1)
else
    opencossan.OpenCossan.setAnalysisId(opencossan.OpenCossan.getAnalysisId()+1)
end

% Insert entry in Analysis Database
if ~isempty(opencossan.OpenCossan.getDatabaseDriver)
    insertRecord(opencossan.OpenCossan.getDatabaseDriver,'StableType','Analysis',...
        'Nid',opencossan.OpenCossan.getAnalysisID);
end
%%


if strcmpi(Xobj.Smethod,'givendata')
    if isempty(Xobj.XsimulationData)
         assert(~isempty(Xobj.Xsimulator) && ~isempty(Xobj.Xtarget), ...
             'openCOSSAN:GlobalSensitivitySobol',...
             ['A simulator and a Model are required to compute the ' ...
             'sensitivity indices using given data and without ' ...
             'a SimulationData object'])
        % Generate data and then compute the indices
        % Xobj.Xsimulator is the simulator
        % Xobj.Xtarget is the Model
        Xobj.XsimulationData=Xobj.Xsimulator.apply(Xobj.Xtarget);
    end
    
    varargout{1}=useGivenData(Xobj);
else
    [varargout{1}, varargout{2}]=useRandomSamples(Xobj);
end
       