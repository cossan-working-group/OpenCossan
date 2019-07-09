function Xsm = upperBounds(varargin)
%UPPERBOUNDS Compute upper bounds of the Total sensitivity indices
%   This method estimate the upper bounds od the total sensitivity indices adopting a MCMC algorithms and a Monte Carlo based
%   gradient estimator
%   Ref: Patelli et al. Global Sensitivity of Structural Variability by Random Sampling
%   Computer Physics Communications 2010
%   http://dx.doi.org/10.1016/j.cpc.2010.08.007
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/UpperBounds@Sensitivity
%
%
% Author: Edoardo Patelli
%
% Institute for Risk and Uncertainty, University of Liverpool, UK
%
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

warning('OpenCossan:Sensitivity',...
    strcat('DEPRECATED METHOD!!!!',...
    '\n This static method will be remove soon!!!',...
    '\n More info:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@Sensitivity'))

    % Lap time for each batch
OpenCossan.setLaptime('description', ...
    '[Sensitivity:upperBounds] Start estimator of the upper bounds');


%% Check inputs
OpenCossan.validateCossanInputs(varargin{:})

%% Initialize parameters
Nbootstrap=100;
Nsamples=1e2;
Nchains=10;
Lfinitedifference=false; % select the type of gradient estimation
Carguments={};

%% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'sevaluatedobjectname'}
            Sevaluatedobjectname=varargin{k+1};
        case {'xmodel','xtarget'}
            Xtarget=varargin{k+1};
        case {'cxmodel','cxtarget'}
            Xtarget=varargin{k+1}{1};
        case 'nsamples'
            Nsamples=varargin{k+1};
        case {'nmarkovchains','nmarkovchain'}
            Nchains=varargin{k+1};
        case {'nbootstrap'}
            Nbootstrap=varargin{k+1};
        case {'csinputnames','cinputnames'}
            Cinputnames=varargin{k+1};
        case {'csoutputnames','coutputnames'}
            Coutputnames=varargin{k+1};
        case {'xproposaldistribution'}
            assert(isa(varargin{k+1},'RandomVariableSet'), ...
                'openCOSSAN:sensitivity:upperBounds',...
                'The proposal distribution must be a RandomVariableSet object.\nProvided object; \s',...
                class(varargin{k+1}))
            Xrvsoff=varargin{k+1};
        case {'cxproposaldistribution'}
            assert(isa(varargin{k+1}{1},'RandomVariableSet'), ...
                'openCOSSAN:sensitivity:upperBounds',...
                'The proposal distribution must be a RandomVariableSet object.\nProvided object; \s',...
                class(varargin{k+1}{1}))
            Xrvsoff=varargin{k+1}{1};
        case {'lfinitedifferences'}
            Lfinitedifference=varargin{k+1};
        % Additional parameters for gradientMonteCarlo
        case {'tolerance'}
             Carguments{end+1}=varargin{k};
             Carguments{end+1}=varargin{k+1};
        case {'perturbation'}
             Carguments{end+1}=varargin{k};
             Carguments{end+1}=varargin{k+1};
        case {'ndeltasampleset'}
             Carguments{end+1}=varargin{k};
             Carguments{end+1}=varargin{k+1};
        case {'nsimulations'}
             Carguments{end+1}=varargin{k};
             Carguments{end+1}=varargin{k+1};
        case {'nindicesbyfinitedifference'}
             Carguments{end+1}=varargin{k};
             Carguments{end+1}=varargin{k+1};
        case {'nmaxfailure'}
             Carguments{end+1}=varargin{k};
             Carguments{end+1}=varargin{k+1};
        otherwise
            error('openCOSSAN:sensitivity:upperBounds',...
                'PropertyName %s is not allowed',varargin{k});
    end
end

if ~exist('Sevaluatedobjectname','var')
    Sevaluatedobjectname=class(Xtarget);
end
OpenCossan.setAnalysisID;
if ~isdeployed && isempty(OpenCossan.getAnalysisName)
    OpenCossan.setAnalysisName('upperBounds');
end

%% Extract the number of Random Variable and Input object
% All the model that return a SimulationData object can be used in to
% compute the sobolIndices.

switch class(Xtarget)
    case {'Model'}
        Xinput=Xtarget.Xinput;
    case {'PolyharmonicSplines','NeuralNetwork','ResponseSurface'}
        if ~isempty(Xtarget.XFullmodel)
            Xinput=Xtarget.XFullmodel.Xinput;
        else
            Xinput=Xtarget.XcalibrationInput;
        end
    case {'ProbabilisticModel'}
        Xinput=Xtarget.Xmodel.Xinput;
    otherwise
        error('openCOSSAN:sensitivity:upperBounds',...
            'support for object of class %s to be implemented',class(Xtarget))
end

%% Set default values to Carguments to be sure that is never empty
if isempty(Carguments)
    Carguments{1}='perturbation';
    Carguments{2}=1e-4; % default value for cheap function evaluations
    if isa(Xtarget,'Model') % check if the model contains a Connector
        for isolver = 1:length(Xtarget.Xevaluator.CXsolvers)
            if isa(Xtarget.Xevaluator.CXsolvers{isolver},'Connector') 
                % if there is a Connector, the evaluation is expensive
                % and the perturbation is set to a lower value
                Carguments{2}=1e-2; 
            end
        end
    end
end


% If the output names are not defined the sensitivity indices are computed
% for all the output variables
if ~exist('Coutputnames','var')
    Coutputnames=Xtarget.Coutputnames;
else
    assert(all(ismember(Coutputnames,Xtarget.Coutputnames)), ...
        'openCOSSAN:sensitivity:upperBounds', ...
        ['Selected output names are not present in the model output. \n' ...
        'Selected Outputs: ' sprintf('%s; ',Coutputnames{:}) ...
        '\nAvailable outputs: ',  sprintf('%s; ',Xtarget.Coutputnames{:})]);
end

% If the input names are not defined the sensitivity indices are computed
% for all the input variables

% Store local variables
Nrv=Xinput.NrandomVariables;
CnamesRandomVariable=Xinput.CnamesRandomVariable;

if ~exist('Cinputnames','var')
    Cinputnames=CnamesRandomVariable;
    Ninputs=Nrv;
    Vpos=1:Nrv;
else
    assert(all(ismember(Cinputnames,CnamesRandomVariable)), ...
        'openCOSSAN:sensitivity:upperBounds', ...
        ['Selected input names are not present in the model output. \n' ...
        'Selected Inputs: ' sprintf('%s; ',Cinputnames{:}) ...
        '\nAvailable Inputs: ',  sprintf('%s; ',CnamesRandomVariable{:})]);
    Ninputs=length(Cinputnames);
    Vpos=zeros(Ninputs,1);
    for n=1:Ninputs
        Vpos(n)=find(strcmp(Cinputnames{n},CnamesRandomVariable));
    end
end

assert(Ninputs>0,'openCOSSAN:sensitivity:upperBounds',...
    'Number of input is equal 0,\n Check Cinputnames %s',Cinputnames{:})

% Prepare RandomVaraibleSet for the MarkovChain
% The markov chain should always contain all the variables.

for n=1:Nrv
    % Collect RandomVariable objects
    Cmembers{n}=Xinput.get('Xrv',CnamesRandomVariable{n}); %#ok<AGROW>
end

Xbase=RandomVariableSet('CXrandomvariables',Cmembers,'Cmembers',CnamesRandomVariable);

%% Create Markov Chains
% The initial points are not computed automatically by the MarkovChain object.
% Create Input object with Samples
InitialPoint=rand(Nchains,Nrv);
InitialPoint(1,:)=0; % Force the first point to be at the origin

Xs=Samples('Msamplesstandardnormalspace',InitialPoint,'Xrandomvariableset',Xbase);

%% Create proposal distribution
if exist('Xrvsoff','var')
    assert(Xrvsoff.Nrv==Ninputs, ...
        'openCOSSAN:sensitivity:upperBounds',...
        strcat('The proposal distribution must contain %i random variables.',...
        'Provided object contains %i random varialble'),...
        Xrvsoff.Nrv,Ninputs)
else
    XrvUni=RandomVariable('Sdistribution','uniform','lowerBound',-0.01,'upperBound',0.01);
    Xrvsoff = RandomVariableSet('Xrv',XrvUni,'Nrviid',Nrv);
end

% % Construct the markov chain object
OpenCossan.cossanDisp('Create Markov Chains',4)
Xmkv=MarkovChain('Xbase',Xbase,'XoffSprings',Xrvsoff, ...
    'Npoints',floor(Nsamples/Nchains),'Xsamples',Xs);

% retrieve the point of the Markov chains
MmarkovchainPoints=Xmkv.getChain;

OpenCossan.cossanDisp('Evaluate gradient in each point of the Markov Chains',4)

%% Evaluate the gradient in each point of the MarkovChain
for iout=1:length(Coutputnames)
    OpenCossan.cossanDisp(['[Status:upperBounds] * Output: ' num2str(iout) '/' num2str(length(Coutputnames)) ],2)
    OpenCossan.cossanDisp(['[Status:upperBounds]   * Samples: ' num2str(1) '/' num2str(Nsamples) ],2)
    
    % Compute gradient
    if Lfinitedifference
        Xgradient=Sensitivity.gradientFiniteDifferences(...
            'Xtarget',Xtarget,'Coutputname',Coutputnames(iout), ...
            'VreferencePoint',MmarkovchainPoints(1,:),'CnamesRandomVariable',Cinputnames,......
             Carguments{:});
    else
        Xgradient=Sensitivity.gradientMonteCarlo(...
            'Xtarget',Xtarget,'Coutputname',Coutputnames(iout), ...
            'VreferencePoint',MmarkovchainPoints(1,:),'CnamesRandomVariable',Cinputnames,......
             Carguments{:});
    end
    
    %% Collection all the gradient information
    MgradientSquared=zeros(Nsamples,length(Cinputnames));
    MgradientSquared(1,:)=Xgradient.Vgradient.^2;
    
    Dmcmc=sum(Xgradient.Vgradient.^2);
    Neval=Xgradient.Nsamples;
    Vnu=Xgradient.Vgradient.^2;
    
    for ipoint=2:Nsamples
        OpenCossan.cossanDisp(['[Status:upperBounds]   * Samples: ' num2str(ipoint) '/' num2str(Nsamples) ],2)
        Valpha=Xgradient.Valpha;
        
        % Compute gradient
        if Lfinitedifference
            Xgradient=Sensitivity.gradientFiniteDifferences(...
                'Xtarget',Xtarget,'Coutputname',Coutputnames(iout), ...
                'VreferencePoint',MmarkovchainPoints(ipoint,:),'CnamesRandomVariable',Cinputnames,......
                 Carguments{:});
        else
            Xgradient=Sensitivity.gradientMonteCarlo(...
            'Xtarget',Xtarget,'Coutputname',Coutputnames(iout), ...
            'VreferencePoint',MmarkovchainPoints(ipoint,:),'CnamesRandomVariable',Cinputnames,...
            'Valpha',Valpha,...
             Carguments{:});
        end

        MgradientSquared(ipoint,:)=Xgradient.Vgradient.^2;
        %% Compute mu
        Vnu=Vnu+Xgradient.Vgradient.^2;
        %mu=mu+abs(Vgradnew);
        Neval=Neval+Xgradient.Nsamples;
        Dmcmc(ipoint)=sqrt(sum(Xgradient.Vgradient.^2));
    end
    % normalize components
    
    % Total variance
    %totalVariance=sum(Dmcmc)/Nsamples;
    
    %% Bound the Sobol index
    OpenCossan.setLaptime('description', ...
        ['[Sensitivity:upperBounds] Bootstraping: ' Coutputnames{iout} ]);
    
    hcomputeUpperBounds=@(MgradientSquared)computeUpperBounds(MgradientSquared);
    VupperBounds=hcomputeUpperBounds(MgradientSquared);
    
    %Nbootstrap=hcomputeUpperBounds(MgradientSquared);
    
    if Nbootstrap>0
        Mupperbounds=bootstrp(Nbootstrap,hcomputeUpperBounds,MgradientSquared);
        MupperBoundsCI=bootci(Nbootstrap,{hcomputeUpperBounds,MgradientSquared},'type','per');
    
        boundsVarEstbootstraping=var(Mupperbounds,[],1);
        VupperBoundsCoV=sqrt(boundsVarEstbootstraping)./VupperBounds;
    
    
    %% Construct SensitivityMeasure object
        Xsm(iout)=SensitivityMeasures('Cinputnames',Cinputnames, ...
        'Soutputname',  Coutputnames{iout},'Xevaluatedobject',Xtarget, ...
        'Sevaluatedobjectname',Sevaluatedobjectname, ...
        'VupperBounds',VupperBounds, ...
        'VupperBoundsCoV',VupperBoundsCoV, ...
        'MupperBoundsCI',MupperBoundsCI, ...
        'Sestimationmethod','Sensitivity.upperBounds');  %#ok<AGROW>
    else
            %% Construct SensitivityMeasure object
        Xsm(iout)=SensitivityMeasures('Cinputnames',Cinputnames, ...
        'Soutputname',  Coutputnames{iout},'Xevaluatedobject',Xtarget, ...
        'Sevaluatedobjectname',Sevaluatedobjectname, ...
        'VupperBounds',VupperBounds, ...
        'Sestimationmethod','Sensitivity.upperBounds');  %#ok<AGROW>
    end
end

OpenCossan.setLaptime('description','[Sensitivity:upperBounds] Upper bounds computed')

end

function VupperBounds=computeUpperBounds(MgradientSquared)
%% Private Function to compute the upper-Bounds
Nsamples=size(MgradientSquared,1);
Vnu=sum(MgradientSquared,1)/Nsamples;
totalVariance=sum(sqrt(sum(MgradientSquared,2)))/Nsamples;

%% Bounds of the total effect indices
VupperBounds=Vnu/totalVariance;
end
