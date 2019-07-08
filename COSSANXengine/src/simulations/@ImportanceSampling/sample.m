function Xs = sample(Xobj,varargin)
%SAMPLE
% This method generate a Samples object.
% The samples are generated according the IS distribution.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/sample@ImportanceSampling
%
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

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%% Process inputs
Nsamples=Xobj.Nsamples;

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'nsamples'}
            Nsamples=varargin{k+1};
        case {'xinput'}
            Xinput=varargin{k+1};
        otherwise
            error('openCOSSAN:Simulations:ImportanceSampling:sample',...
                ['Input parameter ' varargin{k} ' not allowed '])
    end
end

if ~exist('Xinput','var')
    error('openCOSSAN:ImportanceSampling:sample',...
        'An Input object is required to generate samples with the ImportanceSampling')
end


%% Define Proposal Density
% Define a mapping matrix (each colums for each RandomVariable of the
% proposal distribution Set) 
% ==0 use original distribution
% !=0 use proposal distribution 
VmappingIS=zeros(1,size(Xobj.Cmapping,1));

% Collect information of the RandomVariable and RandomVariableSet defined
% in the Input Object

Crvnames=Xinput.CnamesRandomVariable; % get the names of RandomVariables 
CnamesRandomVariableSet=Xinput.CnamesRandomVariableSet; 
Nrvset=length(CnamesRandomVariableSet); % Number of RandomVariableSets

% Check if the Cmapping is consistent with the Xtarget object
for irv=1:size(Xobj.Cmapping,1)
    pos=find(strcmp(Xobj.Cmapping(irv,2),Crvnames));
    
    assert(length(pos)==1, ...
        'openCOSSAN:InportanceSampling:sample',...
        strcat('The variable %s defined in the Cmapping field of the', ...
        'ImportanceSampling object is not present in the Input object'),...
        Xobj.Cmapping{irv,2});
    % Collect the position of the RandomVariables replaced by the proposal
    % distribution
    VmappingIS(irv)=pos;
end


%% Initialize variables
MisPhysicalSpace=zeros(Nsamples,size(Xobj.Cmapping,1)); % Samples of the proposal distribution in Physical Space
MhPdfLog=zeros(Nsamples,length(Xobj.XrvsetUD)); % percentile of the samples from the proposal distribution
MfPdfLog=zeros(Nsamples,Nrvset);                % percentile of the samples from the original distribution
MconditionalPdfLog=zeros(Nsamples,Nrvset);      % percentile of the samples from the conditional distribution

%% Generate the samples from the "Proposal distribution"
irvStart=0; % reset counter
for irvs=1:length(Xobj.XrvsetUD)
    NrvCurrestSet=Xobj.XrvsetUD{irvs}.Nrv; % Number or RV present in the current set
    Vindices=irvStart+(1:NrvCurrestSet); % Index of the RVs;
    
    XsUD = Xobj.XrvsetUD{irvs}.sample(Nsamples);  % Samples object 
    MisPhysicalSpace(:,Vindices)=XsUD.MsamplesPhysicalSpace;
    
    % compute the pdf of the samples
    MhPdfLog(:,irvs)   = evalpdf(Xobj.XrvsetUD{irvs},'Xsamples',XsUD,'Llog',true);
    irvStart=irvStart+NrvCurrestSet;
end

%% Generate samples from each RandomVariableSet defined in the Input
irvStart=0; % reset counter
for irvs=1:Nrvset
    % Set Current RVSET
    Xrvset=Xinput.Xrvset.(CnamesRandomVariableSet{irvs});
    NrvCurrestSet=Xrvset.Nrv; % Number or RV present in the current set
    
    Vindices=1:NrvCurrestSet; % Index of the RVs of the original distribution
    VindicesIS=zeros(1,NrvCurrestSet); % Index of the RVs of the proposal distribution
    % Identify whether the RandomVariables from the proposal distribution are mapping the RandomVariables of the current RandomVariableSet
    % are mapped in the current RVSET
    for icheck=1:NrvCurrestSet
        pos=find(VmappingIS==(Vindices(icheck)+irvStart));
        if ~isempty(pos)
            VindicesIS(icheck)=pos;
        end
    end
    
    Vindices(VindicesIS~=0)=[]; % Remove indices of RV replaced by IS
    
    %% Sample from the original distribution
    % The samples are generated in the Standard Normal Space
    Msamples=zeros(Nsamples,NrvCurrestSet);
    
    
    if ~isempty(Vindices)
        if isempty(Xrvset.McorrelationNataf)
            Msamples(:,Vindices)=randn(Nsamples,length(Vindices));
            MconditionalPdfLog(:,irvs) = sum(log(normpdf(Msamples(:,Vindices))),2);
        else
            % Generate values from a multivariate normal distribution with
            % specified mean vector and covariance matrix.
            
            % Compute Vmeans and Mcovariance
            % See http://en.wikipedia.org/wiki/Multivariate_normal_distribution#Conditional_distributions
            % Partition the covariance matrix:
            % Mcovariance=[Msigma11 Msigma21; Msigma12 Msigma22]
            Msigma11=Xrvset.McorrelationNataf(Vindices,Vindices);
            Msigma12=Xrvset.McorrelationNataf(Vindices,VindicesIS~=0);
            Msigma22=Xrvset.McorrelationNataf(VindicesIS~=0,VindicesIS~=0);
            % then the distribution of x1 conditional on x2 = a is
            % multivariate normal  where:
            Vmeans=Msamples(:,VindicesIS~=0)*(Msigma12/Msigma22)';
            Mcovariance = Msigma11-Msigma12/Msigma22*Msigma12';
            Msamples(:,Vindices)=mvnrnd(Vmeans,Mcovariance);
            MconditionalPdfLog(:,irvs) =log(mvnpdf(Msamples(:,Vindices),Vmeans,Mcovariance));
        end
    end
    
    MsamplesPhysicalSpace=Xrvset.map2physical(Msamples);
    % Replace samples from the IS distribution
    MsamplesPhysicalSpace(:,VindicesIS~=0)=MisPhysicalSpace(:,VindicesIS(VindicesIS~=0));
    
    XStmp = Samples('Xrvset',Xrvset,'MsamplesPhysicalSpace',MsamplesPhysicalSpace);
    % It should be (waiting for PB)
    MfPdfLog(:,irvs)=evalpdf(Xrvset,'Xsamples',XStmp,'Llog',true);
    
    %% Merge the Samples
    if exist('Xs','var')
        Xs=Xs.add('Xsamples',XStmp);
    else
        Xs=XStmp;
    end
    
    irvStart=irvStart+NrvCurrestSet; % Update counter
end

%% Compute the weights
Vweights    = exp(sum(MfPdfLog,2) - sum(MhPdfLog,2)-sum(MconditionalPdfLog,2));

% Add weights to the samples object
Xs.Vweights=Vweights;
