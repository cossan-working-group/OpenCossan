function [Mgradients, Mindices, NfunctionEvaluation, XsimData]=doFiniteDifferences(Xobj)
% DOFINITEDIFFERENCES
% Private function for the sensitivity method
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/GradientFiniteDifferences@Sensitivity
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/localFiniteDifferences@Sensitivity
%
%
% $Copyright~1993-2012,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli and Marco-de-Angelis$

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

% Initialize variables
NfunctionEvaluation=0;

Nrv=Xobj.Xinput.NrandomVariables;           % Number of RV defined in the model
Ndv=Xobj.Xinput.NdesignVariables;           % Number of DV defined in the model
Niv=Xobj.Xinput.NintervalVariables;         % Number of IV defined in the model
Ninputs=length(Xobj.Cinputnames);           % Number of required inputs

[~, VstdRV]=Xobj.Xinput.getMoments;         % Collect the std of the RandomVariables
[Vlower, Vupper]=Xobj.Xinput.getBounds;     % Collect the bounds of the variables
Vbackward=false(Nrv+Ndv,1);                 % index of the component calculated with backward perturbation

CnamesRV=Xobj.Xinput.CnamesRandomVariable;
CnamesDV=Xobj.Xinput.CnamesDesignVariable;
CnamesIV=Xobj.Xinput.CnamesIntervalVariable;

VindexRV=[];
if Nrv>0
    VindexRV=zeros(2,Nrv);
    if any(ismember(CnamesRV,Xobj.Cinputnames))
        VindexRV(1,:)= find(ismember(Xobj.Cinputnames,CnamesRV));
        VindexRV(2,:)= find(ismember(CnamesRV,Xobj.Cinputnames));
    end
    VindexRV(:,VindexRV(2,:)==0)=[];
end

VindexIV=[];
if Niv>0
    VindexIV=zeros(2,Niv);
    if any(ismember(Xobj.Cinputnames,CnamesIV))
        VindexIV(1,:)= find(ismember(Xobj.Cinputnames,CnamesIV));
        VindexIV(2,:)= find(ismember(CnamesIV,Xobj.Cinputnames));
    end
    VindexIV(:,VindexIV(2,:)==0)=[];
end

VindexDV=[];
if Ndv>0
    VindexRV=zeros(2,Ndv);
    if any(ismember(CnamesDV,Xobj.Cinputnames))
        VindexDV(1,:)= find(ismember(Xobj.Cinputnames,CnamesDV));
        VindexDV(2,:)= find(ismember(CnamesDV,Xobj.Cinputnames));
    end
    VindexDV(:,VindexDV(2,:)==0)=[];
end

%% Generate Samples object from the Reference Point
if isempty(Xobj.Xsamples0)
    % Construct Reference Point
    % Check mandatory fields
    assert(length(Xobj.VreferencePoint)==Nrv+Niv+Ndv, ...
        'openCOSSAN:sensitivity:coreFiniteDifferences', ...
        strcat('The length of reference point (%i) must be equal to' , ...
        ' the sum of the number of random variables (%i), the number of interval variables (%i) and the number',...
        ' of design variables (%i)'), ...
        length(Xobj.VreferencePoint),Nrv,Niv,Ndv)
    %% Reordinate the VreferencePoint
    if Nrv>0
        VreferencePointUserDefinedRV=Xobj.VreferencePoint(VindexRV(1,:));
    end
    if Niv>0
        VreferencePointUserDefinedIV=Xobj.VreferencePoint(VindexIV(1,:));
    end
    if Ndv>0
        VreferencePointUserDefinedDV=Xobj.VreferencePoint(VindexDV(1,:));
    end
    
    if Nrv>0 && Niv>0 && Ndv>0
        Xobj.Xsamples0=Samples('MsamplesPhysicalSpace',VreferencePointUserDefinedRV, ...
            'MsamplesEpistemicSpace',VreferencePointUserDefinedIV, ...
            'MsamplesdoeDesignVariables',VreferencePointUserDefinedDV,...
            'Xinput',Xobj.Xinput);
    elseif Nrv>0 && Ndv>0
        Xobj.Xsamples0=Samples('MsamplesPhysicalSpace',VreferencePointUserDefinedRV, ...
            'MsamplesdoeDesignVariables',VreferencePointUserDefinedDV,'Xinput',Xobj.Xinput);
    elseif Nrv>0 && Niv>0
        Xobj.Xsamples0=Samples('MsamplesPhysicalSpace',VreferencePointUserDefinedRV, ...
            'MsamplesEpistemicSpace',VreferencePointUserDefinedIV,'Xinput',Xobj.Xinput);
    elseif Niv>0 && Ndv>0
        Xobj.Xsamples0=Samples('MsamplesEpistemicSpace',VreferencePointUserDefinedIV, ...
            'MsamplesdoeDesignVariables',VreferencePointUserDefinedDV,'Xinput',Xobj.Xinput);
    elseif Niv>0 && Ndv==0
        Xobj.Xsamples0=Samples('MsamplesEpistemicSpace',VreferencePointUserDefinedIV,'Xinput',Xobj.Xinput);
    elseif Nrv>0 && Ndv==0
        Xobj.Xsamples0=Samples('MsamplesPhysicalSpace',VreferencePointUserDefinedRV,'Xinput',Xobj.Xinput);
    else
        Xobj.Xsamples0=Samples('MsamplesdoeDesignVariables',VreferencePointUserDefinedDV,'Xinput',Xobj.Xinput);
    end
    
else
    Xobj.VreferencePoint=Xobj.Xsamples0.MsamplesPhysicalSpace;
end

if isempty(Xobj.fx0)
    Xout0=Xobj.Xtarget.apply(Xobj.Xsamples0);
    if ~isempty(OpenCossan.getDatabaseDriver)
        insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
            'XsimulationData',Xout0,'Nbatchnumber',0) 
    end  
    NfunctionEvaluation=NfunctionEvaluation+Xout0.Nsamples;
    Vreference=Xout0.getValues('Cnames',Xobj.Coutputnames);
else
    Cvariables=Xobj.Xsamples0.Cvariables;
    Cvariables(end+1)=Xobj.Coutputname;
    Mfx0=[Xobj.Xsamples0.MsamplesPhysicalSpace Xobj.fx0];
    Xout0=SimulationData('Cnames',Cvariables,'Mvalues',Mfx0);
    Vreference=Xobj.fx0;
end

%% Compute finite difference for each component
% Define the perturbation points in the physiscal space.
MsamplesPhysicalSpace=repmat(Xobj.Xsamples0.MsamplesPhysicalSpace,Ninputs,1);
%MUi=repmat(Xsamples0.MsamplesStandardNormalSpace,Ninputs,1);

MsamplesEpistemicSpace=repmat(Xobj.Xsamples0.MsamplesEpistemicSpace,Ninputs,1);

MDVp=repmat(Xobj.Xsamples0.MdoeDesignVariables,Ninputs,1);

for irv=1:Nrv
    %MUi(ic,VindexRV(ic))  = MUi(ic,VindexRV(ic)) + perturbation;
    % Check the bounds of the Random Variables
    if Vupper(VindexRV(1,irv)) >= (MsamplesPhysicalSpace(VindexRV(1,irv),VindexRV(2,irv)) + Xobj.perturbation*VstdRV(VindexRV(2,irv)))
        MsamplesPhysicalSpace(irv,VindexRV(2,irv))  = MsamplesPhysicalSpace(VindexRV(1,irv),VindexRV(2,irv)) + Xobj.perturbation*VstdRV(VindexRV(2,irv));
    elseif Vlower(VindexRV(1,irv)) <= MsamplesPhysicalSpace(VindexRV(1,irv),VindexRV(2,irv)) - Xobj.perturbation*VstdRV(VindexRV(2,irv));
        MsamplesPhysicalSpace(VindexRV(1,irv),VindexRV(2,irv))  = MsamplesPhysicalSpace(VindexRV(1,irv),VindexRV(2,irv)) - Xobj.perturbation*VstdRV(VindexRV(2,irv));
        Vbackward(irv)=true;
    else
        warning('openCOSSAN:sensitivity:coreFiniteDifferences',...
            'Perturbation failed for Random Variable %s!!!',CnamesRV{VindexRV(2,irv)})
    end
end

% add check if the perturbed value is inside the bounded domain
for iiv=1:Niv
    radius=(Vupper(VindexIV(1,iiv))-Vlower(VindexIV(1,iiv)))/2;
    if Vupper(VindexIV(1,iiv)) >= (MsamplesEpistemicSpace(VindexIV(1,iiv),VindexIV(2,iiv)) + Xobj.perturbation*radius)
        MsamplesEpistemicSpace(VindexIV(1,iiv),VindexIV(2,iiv))  = MsamplesEpistemicSpace(VindexIV(1,iiv),VindexIV(2,iiv)) + Xobj.perturbation*radius;
    elseif Vlower(VindexIV(1,iiv)) <= MsamplesEpistemicSpace(VindexIV(1,iiv),VindexIV(1,iiv)) - Xobj.perturbation*radius;
        MsamplesEpistemicSpace(VindexIV(1,iiv),VindexIV(2,iiv))  = MsamplesEpistemicSpace(VindexIV(1,iiv),VindexIV(2,iiv)) - Xobj.perturbation*radius;
        Vbackward(iiv)=true;
    else
        warning('openCOSSAN:sensitivity:coreFiniteDifferences',...
            'Perturbation failed for Interval Variable %s!!!',CnamesIV{VindexIV(2,iiv)})
    end
end

for idv=1:Ndv
    if Vupper(VindexDV(idv)) >= (MDVp(idv,VindexDV(idv)) + Xobj.perturbation*MDVp(VindexDV(idv)))
        MDVp(idv,VindexDV(idv))  = MDVp(idv,VindexDV(idv)) + Xobj.perturbation*MDVp(VindexDV(idv));
    elseif Vlower(VindexDV(idv)) <= MDVp(idv,VindexDV(idv)) - Xobj.perturbation*MDVp(VindexDV(idv));
        MDVp(idv,VindexDV(idv))  = MDVp(idv,VindexDV(idv)) - Xobj.perturbation*MDVp(VindexDV(idv));
        Vbackward(idv)=true;
    else
        warning('openCOSSAN:sensitivity:coreFiniteDifferences',...
            'Perturbation failed for Design variable %s!!!',CnamesDV{VindexRV(idv)})
    end
end


% Define a Samples object with the perturbated values
if Nrv>0 && Niv>0 && Ndv>0
    Xsmli=Samples('MsamplesPhysicalSpace',MsamplesPhysicalSpace, ...
        'MsamplesEpistemicSpace',MsamplesEpistemicSpace,...
        'MsamplesdoeDesignVariables',MDVp,...
        'Xinput',Xobj.Xinput);
elseif Nrv>0 && Niv>0
    Xsmli=Samples('MsamplesPhysicalSpace',MsamplesPhysicalSpace, ...
        'MsamplesEpistemicSpace',MsamplesEpistemicSpace,...
        'Xinput',Xobj.Xinput);
elseif Nrv>0 && Ndv>0
    Xsmli=Samples('MsamplesPhysicalSpace',MsamplesPhysicalSpace, ...
        'MsamplesdoeDesignVariables',MDVp,...
        'Xinput',Xobj.Xinput);
elseif Nrv>0 && Ndv==0
    Xsmli=Samples('MsamplesPhysicalSpace',MsamplesPhysicalSpace,...
        'Xinput',Xobj.Xinput);
elseif Niv>0 && Ndv==0
    Xsmli=Samples('MsamplesEpistemicSpace',MsamplesEpistemicSpace,...
        'Xinput',Xobj.Xinput);
else
    Xsmli=Samples('MsamplesdoeDesignVariables',MDVp,'Xinput',Xobj.Xinput);
end

% Store values in physical space
%MsamplesPhysicalSpace=Xsmli.MsamplesPhysicalSpace;
Xdeltai     = Xobj.Xtarget.apply(Xsmli);
if ~isempty(OpenCossan.getDatabaseDriver)
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
        'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
        'XsimulationData',Xdeltai,'Nbatchnumber',0) 
end  
NfunctionEvaluation     = NfunctionEvaluation+Xdeltai.Nsamples;

%% Compute gradient (in Physical Space)
Mgradients=zeros(Ninputs,length(Xobj.Coutputnames));

%% Compute Gradient
Vperturbation=zeros(Ninputs,1);
for n=1:Nrv
    Vperturbation(VindexRV(1,n))=MsamplesPhysicalSpace(n,VindexRV(2,n)) - Xobj.VreferencePoint(VindexRV(1,n));
end
for n=1:Niv
    Vperturbation(VindexIV(1,n))=MsamplesEpistemicSpace(n,VindexIV(2,n)) - Xobj.VreferencePoint(VindexIV(1,n));
end
for n=1:Ndv
    Vperturbation(VindexDV(1,n))=MDVp(n,VindexDV(2,n)) - Xobj.VreferencePoint(VindexDV(1,n));
end

for iout=1:length(Xobj.Coutputnames)
    Mgradients(:,iout) = (Xdeltai.getValues('Cnames',Xobj.Coutputnames(iout)) - Vreference(iout) )./Vperturbation;
    
end

%% Compute the variance of the responce in standard normal space
Mindices=zeros(Ninputs,length(Xobj.Coutputnames));

for iout=1:length(Xobj.Coutputnames)
    Mindices(:,iout) = (Xdeltai.getValues('Cnames',Xobj.Coutputnames(iout)) - ...
        Vreference(iout) )/Xobj.perturbation;
    
    % Change sign of the measures computed using backward finite
    % difference.
end
Mindices(Vbackward,:)=-Mindices(Vbackward,:);

XsimData=Xout0.merge(Xdeltai); % Export SimulationData

