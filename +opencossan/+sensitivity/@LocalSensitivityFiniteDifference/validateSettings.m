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

% Nothing to do, yet!!
if isempty(Xobj.perturbation)
    Xobj.perturbation=1e-4; % default value for cheap function evaluations
    
    if isa(Xobj.Xtarget,'Model')
        Xmodel=Xobj.Xtarget;
        for isolver = 1:length(Xmodel.Xevaluator.CXsolvers)
            if isa(Xmodel.Xevaluator.CXsolvers{isolver},'Connector')
                % if there is a Connector, the evaluation is expensive
                % and the perturbation is set to a lower value
                Xobj.perturbation=1e-2;
            end
        end
    elseif isa(Xobj.Xtarget,'ProbabilisticModel')
        Xmodel=Xobj.Xtarget.Xmodel;
        for isolver = 1:length(Xmodel.Xevaluator.CXsolvers)
            if isa(Xmodel.Xevaluator.CXsolvers{isolver},'Connector')
                % if there is a Connector, the evaluation is expensive
                % and the perturbation is set to a lower value
                Xobj.perturbation=1e-2;
            end
        end       
    end    
end

% Check the validation point!
if isempty(Xobj.VreferencePoint)
    Tdefault=Xobj.Xinput.getDefaultValuesStructure;
    
    CnamesRV=Xobj.Xinput.RandomVariableNames;
    CnamesDV=Xobj.Xinput.DesignVariableNames;
    
    VreferencePointUserDefinedRV=zeros(1,length(CnamesRV));    
    VreferencePointUserDefinedDV=zeros(1,length(CnamesDV));
    
    for n=1:length(CnamesRV);
        VreferencePointUserDefinedRV(n)=Tdefault.(CnamesRV{n});
    end
    for n=1:length(CnamesDV);
        VreferencePointUserDefinedDV(n)=Tdefault.(CnamesDV{n});
    end

    Xobj.VreferencePoint=[VreferencePointUserDefinedRV VreferencePointUserDefinedDV];
end

if isempty(Xobj.Cinputnames)
   Xobj.Cinputnames=Xobj.Xinput.CnamesRandomVariable;
else
   assert(all(ismember(Xobj.Cinputnames,[Xobj.Xinput.RandomVariableNames, Xobj.Xinput.DesignVariableNames])), ...
   'openCOSSAN:sensitivity:randomBalanceDesign', ...
   ['Selected output names are not present in the model output. \n' ...
    'Selected Inputs: ' sprintf('%s; ',Xobj.Cinputnames{:}) ...
    '\nAvailable RandomVariables: ',  sprintf('%s; ',Xobj.Xinput.RandomVariableNames{:}),...
    '\nAvailable DesignVariables: ',  sprintf('%s; ',Xobj.Xinput.DesignVariableNames{:})]);

end

end

