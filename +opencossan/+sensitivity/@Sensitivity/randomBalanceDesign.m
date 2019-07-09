function Xsm = randomBalanceDesign(varargin)
%RANDOMBALANCEDESIGN 
%   This method estimate the Sobol' indices based on selecting N design
%   points. The points are selected over a curve in the input space using a
%   frequency equal to 1 for each factor.
%   numerical procedure for computing the full-set of first-order and
%   total-effect indices.
%   Ref: Saltelli et al. 2009 Global Sensitivity Analysis: The primer,
%   Wiley ISBN: 978-0-470-05997-5
%
% Sobol' indices estimation (Saltelli 2002)
% 
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/RandomBalanceDesign@Sensitivity
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

    OpenCossan.setAnalysisID;
    if ~isdeployed && isempty(OpenCossan.getAnalysisName)
    OpenCossan.setAnalysisName('randomBalanceDesign');
end
OpenCossan.setLaptime('description', ...
    '[Sensitivity:randomBalanceDesign] Start sensitivity analysis')

%% Check inputs
OpenCossan.validateCossanInputs(varargin{:})
Nbootstrap=100;
Nsamples=100;
Nharmonics=6;
Sevaluatedobjectname='';

%% Process inputs
for k=1:2:length(varargin)
	switch lower(varargin{k})
		case {'xmodel','xtarget'}
			Xtarget=varargin{k+1};
        case {'cxmodel','cxtarget'}
			Xtarget=varargin{k+1}{1}; 
        case {'sevaluatedobjectname'}
             Sevaluatedobjectname=varargin{k+1};
        case {'nbootstrap'}
			Nbootstrap=varargin{k+1};
		case {'csinputnames','cinputnames'}
			Cinputnames=varargin{k+1};
        case {'csoutputnames','coutputnames'}
			Coutputnames=varargin{k+1}; 
        case {'nsamples'}
			Nsamples=varargin{k+1}; 
        case {'nharmonics'}
			Nharmonics=varargin{k+1}; 
		otherwise
			error('openCOSSAN:sensitivity:randomBalanceDesign',...
				['PropertyName ' varargin{k} ' not allowed']);
	end	
end

%% Set maximum number of harmonics to Nsamples
if Nsamples<Nharmonics
    Nharmonics=Nsamples-1;
end


%% Extract the number of Random Variable and Input object
% All the model that return a SimulationData object can be used in to
% compute the sobolIndices.

switch class(Xtarget)
    case {'Model'}        
        Xinput=Xtarget.Xinput;
    case {'NeuralNetwork','ResponseSurface','PolyharmonicSplines'}
        if ~isempty(Xtarget.XFullmodel)
            Xinput = Xtarget.XFullmodel.Xinput;
        else
            Xinput = Xtarget.XcalibrationInput;
        end
    case 'ProbabilisticModel'
        Xinput=Xtarget.Xmodel.Xinput;
    otherwise
        error('openCOSSAN:sensitivity:randomBalanceDesign',...
            'support for object of class %s to be implemented',class(Xtarget))
end

% If the output names are not defined the sensitivity indices are computed
% for all the output variables
if ~exist('Coutputnames','var')
    Coutputnames=Xtarget.Coutputnames;
else
   assert(all(ismember(Coutputnames,Xtarget.Coutputnames)), ...
   'openCOSSAN:sensitivity:randomBalanceDesign', ...
   ['Selected output names are not present in the model output. \n' ...
    'Selected Outputs: ' sprintf('%s; ',Coutputnames{:}) ...
    '\nAvailable outputs: ',  sprintf('%s; ',Xtarget.Coutputnames{:})]);
end

Noutputs=length(Coutputnames);
% If the input names are not defined the sensitivity indices are computed
% for all the input variables

Nrv=Xinput.NrandomVariables;

if ~exist('Cinputnames','var')
   Ninputs=Nrv;
   Cinputnames=Xinput.CnamesRandomVariable;
else
   assert(all(ismember(Cinputnames,Xinput.CnamesRandomVariable)), ...
   'openCOSSAN:sensitivity:randomBalanceDesign', ...
   ['Selected output names are not present in the model output. \n' ...
    'Selected Inputs: ' sprintf('%s; ',Cinputnames{:}) ...
    '\nAvailable Inputs: ',  sprintf('%s; ',Xinput.CnamesRandomVariable{:})]);
   Ninputs=length(Cinputnames);
end

assert(Ninputs>0,'openCOSSAN:sensitivity:randomBalanceDesign',...
    'Number of input is equal 0,\n Check Cinputnames %s',Cinputnames{:})

% Mapping the input names
VindexInput=zeros(1,Ninputs);
for n=1:Ninputs
    VindexInput(n)=find(strcmp(Xinput.CnamesRandomVariable,Cinputnames{n}));
end

OpenCossan.cossanDisp(['Total number of model evaluation ' num2str(Nsamples)],2)

%% Estimate sensitivity indices

% According to Tarantola 2006
Vs0=-pi:2*pi/(Nsamples-1):pi;

Ms=zeros(Nsamples,Ninputs); % Preallocate memory

for n=1:Ninputs
    
    Ms(:,n)=Vs0(randperm(Nsamples)); % Perform a random permutation of the 
                                     % interfers from 1 to Nsamples
end

% Constract the input samples
Mx=0.5+asin(sin(1*Ms))/pi; % 1=\omega 

% Order the elements of Mx in ascending order
%[~, Mindex]=sort(Ms,1); % each input factor are reorder

%% Evaluate the model
OpenCossan.cossanDisp('Creating Samples object',4)

% Preallocate memory
Xinput=Xinput.sample('Nsamples',Nsamples);
Msamples=Xinput.Xsamples.MsamplesHyperCube;

Msamples(:,VindexInput)=Mx;

Xsamples=Samples('Xinput',Xinput,'MsamplesHyperCube',Msamples);

% Evaluate the model 
OpenCossan.cossanDisp('Evaluating the model ' ,4)
Xout=Xtarget.apply(Xsamples); % y_A=f(A)

% values of the output variables
OpenCossan.cossanDisp('Extract quantity of interest from SimulationData ' ,4)
Mout=Xout.getValues('Cnames',Coutputnames);

% MmainEffect=zeros(Noutputs,Ninputs);
% % sort output
% for nout=1:Noutputs
%     Vout=Mout(:,nout);
%     MoutSorted=Vout(Mindex);
%     
%     % Compute the spectrum using the fft
%     for n=1:Ninputs
%         spectrum=(abs(fft(MoutSorted(:,n)))).^2/Nsamples;
%         MmainEffect(nout,n)=2*sum(spectrum(2:Nharmonics+1));
%     end
% end
% 
% V=sum(spectrum(2:Nsamples)); % The sum of the specturum is always the same for permutated data. 
% 
% OpenCossan.cossanDisp('Compute First Order ' ,4)
% % Compute First order Sobol' indices
% MfirstOrder=transpose(MmainEffect./V);

%% Define a function handle to estimate the parameters
% This function handle is also used by the bootstraping method to estimate
% the variance of the estimators.
hcomputeindices=@(Vx,Vout)computeMainEffect(Vx,Vout,Nharmonics);

MfirstOrder=zeros(Ninputs,Noutputs);
VfirstOrderCoV=zeros(Ninputs,Noutputs);
MfirstOrderCI=zeros(2,Ninputs,Noutputs);

for nout=1:Noutputs
    
    for nin=1:Ninputs
        % Compute main effects
        MfirstOrder(nin,nout)=hcomputeindices(Mx(:,nin),Mout(:,nout));
        
        % Compute CoV
        Dybs=bootstrp(Nbootstrap,hcomputeindices,Mx(:,nin),Mout(:,nout));
        VfirstOrderCoV(nin,nout)=std(Dybs)./MfirstOrder(nin,nout);
        
        % Compute CI
        MfirstOrderCI(:,nin,nout)=bootci(Nbootstrap,{hcomputeindices,Mx(:,nin),Mout(:,nout)},'type','per');
    end
end

%% Construct SensitivityMeasure object
for n=1:length(Coutputnames)
    
    %VfirstOrderCoV=std(Dybs,[],2)./MfirstOrder(:,n);
    
    Xsm(n)=SensitivityMeasures('Cinputnames',Cinputnames, ... 
    'Soutputname',  Coutputnames{n},'Xevaluatedobject',Xtarget, ...
    'Sevaluatedobjectname',Sevaluatedobjectname, ...
    'VsobolFirstIndices',MfirstOrder(:,n)', ...
    'VsobolFirstIndicesCoV',VfirstOrderCoV(:,n)', ...
    'Msobolfirstorderci',MfirstOrderCI(:,:,n), ...
    'Sestimationmethod','Sensitivity.randomBalanceDesign'); %#ok<AGROW>
end

%% Finalizing timer
OpenCossan.setLaptime('description','[Sensitivity:randomBalanceDesign] end sensitivity analysis')

end

function mainEffect=computeMainEffect(Vin,Vout,Nharmonics)
    [~, Mindex]=sort(Vin,1);  % Sort inputs
    VoutSorted=Vout(Mindex); % Sort outputs
    
    % Compute the spectrum using the fft
    spectrum=(abs(fft(VoutSorted))).^2/length(Vin);
    mainEffect=2*sum(spectrum(2:Nharmonics+1))/sum(spectrum(2:length(Vin)));
end

