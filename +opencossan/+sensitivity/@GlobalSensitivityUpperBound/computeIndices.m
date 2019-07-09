function varargout=computeIndices(Xobj,varargin)
%COMPUTEINDICES This method computes the upper bound of the Total indices 
% based on 
% Patelli, E.; Pradlwarter, H. J. & Schuëller, G. I. Global
% Sensitivity of Structural Variability by Random Sampling Computer Physics
% Communications, 2010, 181, 2072-2081  
%
% DOI: 10.1016/j.cpc.2010.08.007
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
            error('openCOSSAN:GlobalSensitivitySobol:computeIndices',...
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

% Store local variables
Nrv=Xobj.Xinput.NrandomVariables;
CnamesRandomVariable=Xobj.Xinput.CnamesRandomVariable;
Ninputs=length(Xobj.Cinputnames);

Vpos=zeros(Ninputs,1);
for n=1:Ninputs
    Vpos(n)=find(strcmp(Xobj.Cinputnames{n},CnamesRandomVariable));
end

if isa(Xobj.XlocalSensitivity,'LocalSensitivityMonteCarlo')
    Lfinitedifference=false;
else
    Lfinitedifference=true;
end

% Prepare RandomVaraibleSet for the MarkovChain
% The markov chain should always contain all the variables.

for n=1:Nrv
    % Collect RandomVariable objects
    Cmembers{n}=Xobj.Xinput.get('Xrv',CnamesRandomVariable{n}); %#ok<AGROW>
end

Xbase=RandomVariableSet('CXrandomvariables',Cmembers,'Cmembers',CnamesRandomVariable);

%% Create Markov Chains
% The initial points are not computed automatically by the MarkovChain object.
% Create Input object with Samples
InitialPoint=rand(Xobj.Nchains,Nrv);
InitialPoint(1,:)=0; % Force the first point to be at the origin

Xs=Samples('Msamplesstandardnormalspace',InitialPoint,'Xrandomvariableset',Xbase);

%% Create proposal distribution
if ~isempty(Xobj.XproposalDistribution)
    assert(Xobj.XproposalDistribution.Nrv==Ninputs, ...
        'openCOSSAN:sensitivity:upperBounds',...
        strcat('The proposal distribution must contain %i random variables.',...
        'Provided object contains %i random varialble'),...
        Xobj.XproposalDistribution.Nrv,Ninputs)
    Xrvsoff=Xobj.XproposalDistribution;
else
    XrvUni=RandomVariable('Sdistribution','uniform','lowerBound',-0.01,'upperBound',0.01);
    Xrvsoff = RandomVariableSet('Xrv',XrvUni,'Nrviid',Nrv);
end

% % Construct the markov chain object
OpenCossan.cossanDisp('Create Markov Chains',4)
Xmkv=MarkovChain('Xbase',Xbase,'XoffSprings',Xrvsoff, ...
    'Npoints',floor(Xobj.Nsamples/Xobj.Nchains),'Xsamples',Xs);

% retrieve the point of the Markov chains
MmarkovchainPoints=Xmkv.getChain;

OpenCossan.cossanDisp('Evaluate gradient in each point of the Markov Chains',4)

if isempty(Xobj.XlocalSensitivity)
    
end

Xlocalsolver=Xobj.XlocalSensitivity;

%% Evaluate the gradient in each point of the MarkovChain
for iout=1:length(Xobj.Coutputnames)
    OpenCossan.cossanDisp(['[Status:upperBounds] * Output: ' num2str(iout) '/' num2str(length(Xobj.Coutputnames)) ],2)
    OpenCossan.cossanDisp(['[Status:upperBounds]   * Samples: ' num2str(1) '/' num2str(Xobj.Nsamples) ],2)
    
    % Update the Local Sensitivity object
    Xlocalsolver.VreferencePoint=MmarkovchainPoints(1,:);
    Xlocalsolver.Coutputnames=Xobj.Coutputnames(iout);
    % Compute gradient
    Xgradient=Xlocalsolver.computeGradientStandardNormalSpace;
    
    %% Collection all the gradient information
    MgradientSquared=zeros(Xobj.Nsamples,length(Xobj.Cinputnames));
    MgradientSquared(1,:)=Xgradient.Vgradient.^2;
    
    Dmcmc=sum(Xgradient.Vgradient.^2);
    Neval=Xgradient.Nsamples;
    Vnu=Xgradient.Vgradient.^2;
    
    for ipoint=2:Xobj.Nsamples
        OpenCossan.cossanDisp(['[Status:upperBounds]   * Samples: ' num2str(ipoint) '/' num2str(Xobj.Nsamples) ],2)
        Valpha=Xgradient.Valpha;
        
        % Update the Local Sensitivity object
        Xlocalsolver.VreferencePoint=MmarkovchainPoints(ipoint,:);
        
        if ~Lfinitedifference
            Xlocalsolver.Valpha=Valpha;
        end
        
        % Compute gradient
        Xgradient=Xlocalsolver.computeGradientStandardNormalSpace;
        
        MgradientSquared(ipoint,:)=Xgradient.Vgradient.^2;
        %% Compute mu
        Vnu=Vnu+Xgradient.Vgradient.^2;
        %mu=mu+abs(Vgradnew);
        Neval=Neval+Xgradient.Nsamples;
        Dmcmc(ipoint)=sqrt(sum(Xgradient.Vgradient.^2));
        
        % normalize components
        
        % Total variance
        %totalVariance=sum(Dmcmc)/Nsamples;
        
        %% Bound the Sobol index
       
        hcomputeUpperBounds=@(MgradientSquared)computeUpperBounds(MgradientSquared);
        VupperBounds=hcomputeUpperBounds(MgradientSquared);
        
        %Nbootstrap=hcomputeUpperBounds(MgradientSquared);
        
        if Xobj.Nbootstrap>0
            Mupperbounds=bootstrp(Xobj.Nbootstrap,hcomputeUpperBounds,MgradientSquared);
            MupperBoundsCI=bootci(Xobj.Nbootstrap,{hcomputeUpperBounds,MgradientSquared},'type','per');
            
            boundsVarEstbootstraping=var(Mupperbounds,[],1);
            VupperBoundsCoV=sqrt(boundsVarEstbootstraping)./VupperBounds;
            
            
            %% Construct SensitivityMeasure object
            Xsm(iout)=SensitivityMeasures('Cinputnames',Xobj.Cinputnames, ...
                'Soutputname',  Xobj.Coutputnames{iout},'Xevaluatedobject',Xobj.Xtarget, ...
                'Sevaluatedobjectname',Xobj.Sevaluatedobjectname, ...
                'VupperBounds',VupperBounds, ...
                'VupperBoundsCoV',VupperBoundsCoV, ...
                'MupperBoundsCI',MupperBoundsCI, ...
                'Sestimationmethod','GlobalSensitivityUpperBound');  %#ok<AGROW>
        else
            %% Construct SensitivityMeasure object
            Xsm(iout)=SensitivityMeasures('Cinputnames',Xobj.Cinputnames, ...
                'Soutputname',  Xobj.Coutputnames{iout},'Xevaluatedobject',Xobj.Xtarget, ...
                'Sevaluatedobjectname',Xobj.Sevaluatedobjectname, ...
                'VupperBounds',VupperBounds, ...
                'Sestimationmethod','GlobalSensitivityUpperBound');  %#ok<AGROW>
        end
    end    
    
end

%export results
varargout{1}=Xsm;

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

end

function VupperBounds=computeUpperBounds(MgradientSquared)
%% Private Function to compute the upper-Bounds
Nsamples=size(MgradientSquared,1);
Vnu=sum(MgradientSquared,1)/Nsamples;
totalVariance=sum(sqrt(sum(MgradientSquared,2)))/Nsamples;

%% Bounds of the total effect indices
VupperBounds=Vnu/totalVariance;
end
