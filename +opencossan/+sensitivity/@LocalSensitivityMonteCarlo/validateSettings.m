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

Nrv=Xobj.Xinput.NrandomVariables;
Ndv=Xobj.Xinput.NdesignVariables;
Ninputs=length(Xobj.Cinputnames);
if isempty(Xobj.NmaxFailure)
    Xobj.NmaxFailure=min(Xobj.NminValueFailure,Ninputs);
end

if isempty(Xobj.NindiciesFD)
    % Define the number of components computed by means a Finite Difference
    % Analyis
    Xobj.NindiciesFD=min(3,Ninputs);
end

% Define the increasing of the poll of samples set
if isempty(Xobj.NdeltaSampleSet)
    Xobj.NdeltaSampleSet=max(1,floor((Ninputs-Xobj.NindiciesFD)/Xobj.deltaSampleSetReductionFactor));
end

if Xobj.NindiciesFD>Ninputs
    warning('openCOSSAN:LocalSensitivityMonteCarlo:validateSettings',...
        'The number of indices computed by finite differences (%i) must be <= number of required components (%i)', ...
        Xobj.NindiciesFD,Ninputs)
    Xobj.NindiciesFD=Ninputs;
end


if isempty(Xobj.NsamplesSize)
    if(Nrv<10)
        Xobj.NsamplesSize= min(Ninputs,max(1,ceil(Nrv/4)));
    else
        Xobj.NsamplesSize = min(Ninputs,max(2,ceil(Nrv/8)));
    end
end

%% Generate Samples object from the Reference Point
if isempty(Xobj.Xsamples0)
    % Construct Reference Point
    if ~isempty(Xobj.VreferencePoint)
        % Check mandatory fields
        assert(length(Xobj.VreferencePoint)==Nrv, ...
            'openCOSSAN:LocalSensitivityMonteCarlo:validateSettings', ...
            strcat('The length of reference point (%i) must be equal to' , ...
            ' the number of random variables (%i)'), ...
            length(Xobj.VreferencePoint),Nrv)
        
    else
        Tdefault=Xobj.Xinput.get('DefaultValues');
        
        VreferencePointUserDefinedRV=zeros(1,Nrv);
        VreferencePointUserDefinedDV=zeros(1,Ndv);
        for n=1:Nrv
            VreferencePointUserDefinedRV(n)=Tdefault.(Xobj.Xinput.RandomVariableNames{n});
        end
        for n=1:Ndv
            VreferencePointUserDefinedDV(n)=Tdefault.(Xobj.Xinput.CnamesDesignVariable{n});
        end
        Xobj.VreferencePoint=[VreferencePointUserDefinedRV VreferencePointUserDefinedDV];
        
        if Nrv>0 && Ndv>0
            Xobj.Xsamples0=opencossan.common.Samples('MsamplesPhysicalSpace',VreferencePointUserDefinedRV, ...
                'MsamplesdoeDesignVariables',VreferencePointUserDefinedDV,'Xinput',Xobj.Xinput);
        elseif Nrv>0 && Ndv==0
            Xobj.Xsamples0=opencossan.common.Samples('MsamplesPhysicalSpace',VreferencePointUserDefinedRV,'Xinput',Xobj.Xinput);
        else
            Xobj.Xsamples0=opencossan.common.Samples('MsamplesdoeDesignVariables',VreferencePointUserDefinedDV,'Xinput',Xobj.Xinput);
        end
    end
else
    assert(Xobj.Xsamples0.Nsamples==1, 'openCOSSAN:LocalSensitivityMonteCarlo:validateSettings', ...
        'The Sample object must containts only 1 sample in order to define the reference point')
    Xobj.VreferencePoint=Xobj.Xsamples0.MsamplesPhysicalSpace;
end

%% Check perturbation parameter
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

if isempty(Xobj.Cinputnames)
   Xobj.Cinputnames=Xobj.Xinput.RandomVariableNames;
else
   assert(all(ismember(Xobj.Cinputnames,[Xobj.Xinput.RandomVariableNames, Xobj.Xinput.DesignVariableNames])), ...
   'openCOSSAN:sensitivity:randomBalanceDesign', ...
   ['Selected output names are not present in the model output. \n' ...
    'Selected Inputs: ' sprintf('%s; ',Xobj.Cinputnames{:}) ...
    '\nAvailable RandomVariables: ',  sprintf('%s; ',Xobj.Xinput.RandomVariableNames{:}),...
    '\nAvailable DesignVariables: ',  sprintf('%s; ',Xobj.Xinput.RandomVariableNames{:})]);

end

end

