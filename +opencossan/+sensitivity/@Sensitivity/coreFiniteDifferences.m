function [Xfdout varargout]=coreFiniteDifferences(varargin)
% FINITEDIFFERENCESCORE
% Private function for the sensitivity method
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/GradientFiniteDifferences@Sensitivity
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/localFiniteDifferences@Sensitivity
%
%
% $Copyright~1993-2012,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
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

%% Initialize variables
Xsamples0=[];
fx0=[];
NfunctionEvaluation=0;
LperformanceFunction=false;
perturbation=[];
Coutputname=[];

%% Check inputs
OpenCossan.validateCossanInputs(varargin{:})
%% Process inputs
for k=1:2:nargin
    switch lower(varargin{k})
        case {'lgradient'}
            Lgradient=varargin{k+1};
        case {'coutputname' 'coutputnames' }
            Coutputname=varargin{k+1};
        case {'lperformancefunction'}
            LperformanceFunction=varargin{k+1};
        case {'xtarget'}
            Xtarget=varargin{k+1};
        case {'cxtarget'}
            Xtarget=varargin{k+1}{1};
        case {'vreferencepoint'}
            % Reference Point in PhysicalSpace
            assert(all([~isnan(varargin{k+1}) ~isinf(varargin{k+1})]), ...
                'openCOSSAN:sensitivity:coreFiniteDifferences',...
                 'The reference point can not contain NaN or Inf values\nProvided values: %s',...
                 sprintf('%e ',varargin{k+1}));                  
            VreferencePointUserDefined=varargin{k+1};
        case {'cnamesrandomvariable' 'csnames'}
            % Reference Point in PhysicalSpace
            Cnames=varargin{k+1};
        case {'xsamples'}
            Xsamples0=varargin{k+1};
        case {'cxsamples'}
            Xsamples0=varargin{k+1}{1};
        case {'functionvalue','fx0'}
            fx0=varargin{k+1};
        case {'perturbation'}
            perturbation=varargin{k+1}; 
        otherwise
            error('openCOSSAN:sensitivity:coreFiniteDifferences',...
                'PropertyName %s not allowed',varargin{k});
    end
end

% Check model and extract Input, perturbation and output names. 
[Xinput,perturbation,Coutputname]=Sensitivity.checkModel(Xtarget,perturbation,LperformanceFunction,Coutputname);


%% Indentify the indices for the required inputs.
if ~exist('Cnames','var')
    % By default use all random variables
    Cnames=Xinput.CnamesRandomVariable;
end

Nrv=Xinput.NrandomVariables;  % Number of RV dedined in the model
Ndv=Xinput.NdesignVariables;  % Number of DV dedined in the model
Ninputs=length(Cnames);       % Number of required inputs
[~, VstdRV]=Xinput.getMoments;  % Collect the std of the RandomVariables
[Vlower, Vupper]=Xinput.getBounds;   % Collect the bounds of the RandomVariables

Vbackward=false(Nrv+Ndv,1);     % index of the component calculated with backward perturbation

CnamesRV=Xinput.CnamesRandomVariable;
CnamesDV=Xinput.CnamesDesignVariable;

if Nrv>0
    VindexRV=zeros(Ninputs,1);
    for n=1:Ninputs
        VindexRV(n)= find(ismember(CnamesRV,Cnames(n)));
    end
    VindexRV(VindexRV==0)=[];
end

if Ndv>0
    VindexDV=zeros(Ninputs,1);
    for n=1:Ninputs
        VindexDV(n)= find(ismember(CnamesDV,Cnames(n)));
    end
    VindexDV(VindexDV==0)=[];
end

%% Generate Samples object from the Reference Point
if isempty(Xsamples0)
    % Construct Reference Point
    if exist('VreferencePointUserDefined','var')
        % Check mandatory fields
        assert(length(VreferencePointUserDefined)==Nrv+Ndv, ...
            'openCOSSAN:sensitivity:coreFiniteDifferences', ...
            strcat('The length of reference point (%i) must be equal to' , ...
            ' the sum of the number of random variables (%i) and the number',...
            ' of design variables (%i)'), ...
            length(VreferencePointUserDefined),Nrv,Ndv)
        %% Reordinate the VreferencePoint 
        if Nrv>0
            VreferencePointUserDefinedRV=VreferencePointUserDefined(VindexRV);
        end
        if Ndv>0
            VreferencePointUserDefinedDV=VreferencePointUserDefined(Nrv+VindexDV);
        end
    else
        Tdefault=Xinput.get('defaultvalues');
        
        VreferencePointUserDefinedRV=zeros(1,Nrv);
        VreferencePointUserDefinedDV=zeros(1,Ndv);
        for n=1:Nrv
            VreferencePointUserDefinedRV(n)=Tdefault.(Xinput.CnamesRandomVariable{n});
        end
        for n=1:Ndv
            VreferencePointUserDefinedDV(n)=Tdefault.(Xinput.CnamesDesignVariable{n});
        end
        VreferencePointUserDefined=[VreferencePointUserDefinedRV VreferencePointUserDefinedDV];
        
    end
    
    if Nrv>0 && Ndv>0
        Xsamples0=Samples('MsamplesPhysicalSpace',VreferencePointUserDefinedRV, ...
            'MsamplesdoeDesignVariables',VreferencePointUserDefinedDV,'Xinput',Xinput);
    elseif Nrv>0 && Ndv==0
        Xsamples0=Samples('MsamplesPhysicalSpace',VreferencePointUserDefinedRV,'Xinput',Xinput);
    else
        Xsamples0=Samples('MsamplesdoeDesignVariXsamples0.MsamplesPhysicalSpaceables',VreferencePointUserDefinedDV,'Xinput',Xinput);
    end
    
else
    VreferencePointUserDefined=Xsamples0.MsamplesPhysicalSpace;
end

if isempty(fx0)
    Xout0=Xtarget.apply(Xsamples0);
    NfunctionEvaluation=NfunctionEvaluation+Xout0.Nsamples;
    Vreference=Xout0.getValues('Cnames',Coutputname);
else
    Cvariables=Xsamples0.Cvariables;
    Cvariables(end+1)=Coutputname;
    Mfx0=[Xsamples0.MsamplesPhysicalSpace fx0];
    Xout0=SimulationData('Cnames',Cvariables,'Mvalues',Mfx0);
    Vreference=fx0;
end

%% Compute finite difference for each component
% Define the perturbation points in the physiscal space. 
MsamplesPhysicalSpace=repmat(Xsamples0.MsamplesPhysicalSpace,Ninputs,1);
%MUi=repmat(Xsamples0.MsamplesStandardNormalSpace,Ninputs,1);

MDVp=repmat(Xsamples0.MdoeDesignVariables,Ninputs,1);

for ic=1:Ninputs
    if ic<=length(VindexRV)
        %MUi(ic,VindexRV(ic))  = MUi(ic,VindexRV(ic)) + perturbation;
        % Check the bounds of the Random Variables
        if Vupper(VindexRV(ic)) >= (MsamplesPhysicalSpace(ic,VindexRV(ic)) + perturbation*VstdRV(VindexRV(ic)))
             MsamplesPhysicalSpace(ic,VindexRV(ic))  = MsamplesPhysicalSpace(ic,VindexRV(ic)) + perturbation*VstdRV(VindexRV(ic));
        elseif Vlower(VindexRV(ic)) <= MsamplesPhysicalSpace(ic,VindexRV(ic)) - perturbation*VstdRV(VindexRV(ic));
             MsamplesPhysicalSpace(ic,VindexRV(ic))  = MsamplesPhysicalSpace(ic,VindexRV(ic)) - perturbation*VstdRV(VindexRV(ic));
             Vbackward(ic)=true;
        else
            warning('openCOSSAN:sensitivity:coreFiniteDifferences',...
                'Perturbation failed for Random Variable %s!!!',CnamesRV{VindexRV(ic)})
        end
    else
        if Vupper(VindexDV(ic)) >= (MDVp(ic,VindexDV(ic)) + perturbation*MDVp(VindexDV(ic)))
             MDVp(ic,VindexDV(ic))  = MDVp(ic,VindexDV(ic)) + perturbation*MDVp(VindexDV(ic));
        elseif Vlower(VindexDV(ic)) <= MDVp(ic,VindexDV(ic)) - perturbation*MDVp(VindexDV(ic));
             MDVp(ic,VindexDV(ic))  = MDVp(ic,VindexDV(ic)) - perturbation*MDVp(VindexDV(ic));
             Vbackward(ic)=true;
        else
            warning('openCOSSAN:sensitivity:coreFiniteDifferences',...
                'Perturbation failed for Design variable %s!!!',CnamesRV{VindexRV(ic)})
        end
    end
end

% Define a Samples object with the perturbated values
if Nrv>0 && Ndv>0
    Xsmli=Samples('MsamplesPhysicalSpace',MsamplesPhysicalSpace, ...
        'MsamplesdoeDesignVariables',MDVp,'Xinput',Xinput);
    
  %  Xsmli=Samples('MsamplesStandardNormalSpace',MUi, ...
  %      'MsamplesdoeDesignVariables',MDVp,'Xinput',Xinput);
elseif Nrv>0 && Ndv==0
   Xsmli=Samples('MsamplesPhysicalSpace',MsamplesPhysicalSpace,'Xinput',Xinput);
   % Xsmli=Samples('MsamplesStandardNormalSpace',MUi,'Xinput',Xinput);
else
    Xsmli=Samples('MsamplesdoeDesignVariables',MDVp,'Xinput',Xinput);
end

% Store values in physical space
%MsamplesPhysicalSpace=Xsmli.MsamplesPhysicalSpace;
Xdeltai     = Xtarget.apply(Xsmli);
NfunctionEvaluation     = NfunctionEvaluation+Xdeltai.Nsamples;

%% Compute quantity of interest
if Lgradient
    %% Compute Gradient
    
    Vperturbation=zeros(Ninputs,1);
    for n=1:Ninputs
        if n<=length(VindexRV)
            Vperturbation(n)  = MsamplesPhysicalSpace(n,VindexRV(n)) -VreferencePointUserDefined(VindexRV(n));
        else
            Vperturbation(n) = MDVp(n,VindexDV(n)) -VreferencePointUserDefined(VindexDV(n));
        end
    end
    
    for iout=1:length(Coutputname)
        Vgradient = (Xdeltai.getValues('Cnames',Coutputname(iout)) - Vreference(iout) )./Vperturbation;
        
        %% Export results
        Xfdout(iout)=Gradient('Sdescription',...
            ['Finite Difference Gradient estimation of ' Coutputname{:}], ...
            'Cnames',Cnames, ...
            'NfunctionEvaluation',NfunctionEvaluation,...
            'Vgradient',Vgradient,'Vreferencepoint',VreferencePointUserDefined,...
            'SfunctionName',Coutputname{iout});    %#ok<AGROW>
    end
else
    % Compute the variance of the responce in standard normal space
    for iout=1:length(Coutputname)
        Vmeasures = (Xdeltai.getValues('Cnames',Coutputname(iout)) - ...
            Vreference(iout) )/perturbation;
        
        % Change sign of the measures computed using backward finite
        % difference. 
        Vmeasures(Vbackward)=-Vmeasures(Vbackward);
        
        %% Export results
        Xfdout(iout)=LocalSensitivityMeasures('Sdescription',...
            ['Finite Difference estimation the local sensitivity analysis of ' Coutputname{iout}], ...
            'Cnames',Cnames, ...
            'NfunctionEvaluation',NfunctionEvaluation,...
            'Vmeasures',Vmeasures,'Vreferencepoint',VreferencePointUserDefined,...
            'SfunctionName',Coutputname{iout}); %#ok<AGROW>
    end
end

varargout{1}=Xout0.merge(Xdeltai); % Export SimulationData
varargout{1}.SexitFlag='All (selected) input variables perturebated';
