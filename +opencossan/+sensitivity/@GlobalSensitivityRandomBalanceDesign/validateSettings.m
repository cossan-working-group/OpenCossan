function Xobj = validateSettings(Xobj)
%VALIDATESETTINGS This is a private function of LocalSensitivityMonteCarlo
%used to validate the inputs

% See also:
% https://cossan.co.uk/wiki/index.php/@LocalSensitivityMonteCarlo
%
% Author: Edoardo Patelli
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

%% Set maximum number of harmonics to Nsamples
if Xobj.Nsamples<Xobj.Nharmonics
    Xobj.Nharmonics=Xobj.Nsamples-1;
end

%% Check Input names
if isempty(Xobj.Cinputnames)
   Xobj.Cinputnames=Xobj.Xinput.RandomVariableNames;
else
   assert(all(ismember(Xobj.Cinputnames,[Xobj.Xinput.RandomVariableNames, Xobj.Xinput.DesignVariableNames])), ...
   'openCOSSAN:sensitivity:randomBalanceDesign', ...
   ['Selected output names are not present in the model output. \n' ...
    'Selected Inputs: ' sprintf('%s; ',Xobj.Cinputnames{:}) ...
    '\nAvailable RandomVariables: ',  sprintf('%s; ',Xobj.Xinput.RandomVariableNames{:}),...
    '\nAvailable DesignVariables: ',  sprintf('%s; ',Xobj.Xinput.DesignVariableNames(:))]);

end

% If the output names are not defined the sensitivity indices are computed
% for all the output variables
if isempty(Xobj.Coutputnames)
    Xobj.Coutputnames=Xobj.Xtarget.Coutputnames;
else
   assert(all(ismember(Xobj.Coutputnames,Xobj.Xtarget.OutputNames)), ...
   'openCOSSAN:sensitivity:randomBalanceDesign', ...
   ['Selected output names are not present in the model output. \n' ...
    'Selected Outputs: ' sprintf('%s; ',Xobj.Coutputnames{:}) ...
    '\nAvailable outputs: ',  sprintf('%s; ',Xobj.Xtarget.OutputNames{:})]);
end

end

