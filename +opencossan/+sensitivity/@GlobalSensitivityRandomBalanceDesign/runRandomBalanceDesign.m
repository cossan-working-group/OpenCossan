function [MfirstOrder, MfirstOrderCoV, MfirstOrderCI, Xout] = runRandomBalanceDesign(Xobj)
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

if ~isdeployed && isempty(opencossan.OpenCossan.getAnalysisName)
    opencossan.OpenCossan.setAnalysisName('randomBalanceDesign');
end
opencossan.OpenCossan.getTimer().lap('description', ...
    '[Sensitivity:randomBalanceDesign] Start sensitivity analysis')


Noutputs=length(Xobj.Coutputnames);
% If the input names are not defined the sensitivity indices are computed
% for all the input variables

Ninputs=length(Xobj.Cinputnames);
   
% Mapping the input names
VindexInput=zeros(1,Ninputs);
for n=1:Ninputs
    VindexInput(n)=find(strcmp(Xobj.Xinput.RandomVariableNames,Xobj.Cinputnames{n}));
end

opencossan.OpenCossan.cossanDisp(['Total number of model evaluations required: ' num2str(Xobj.Nsamples)],2)

%% Estimate sensitivity indices

% According to Tarantola 2006
Vs0=-pi:2*pi/(Xobj.Nsamples-1):pi;

Ms=zeros(Xobj.Nsamples,Ninputs); % Preallocate memory

for n=1:Ninputs
    
    Ms(:,n)=Vs0(randperm(Xobj.Nsamples)); % Perform a random permutation of the 
                                     % interfers from 1 to Nsamples
end

% Constract the input samples
Mx=0.5+asin(sin(1*Ms))/pi; % 1=\omega 

% Order the elements of Mx in ascending order
%[~, Mindex]=sort(Ms,1); % each input factor are reorder

%% Evaluate the model
opencossan.OpenCossan.cossanDisp('Creating Samples object',4)

% Preallocate memory
XinputRBD=Xobj.Xinput.sample('Nsamples',Xobj.Nsamples);
Msamples=XinputRBD.Samples.MsamplesHyperCube;
% Keep only the components required by the sensitivity analysis
Msamples(:,VindexInput)=Mx;

Xsamples=opencossan.common.Samples('Xinput',XinputRBD,'MsamplesHyperCube',Msamples);

% Evaluate the model 
opencossan.OpenCossan.cossanDisp('Evaluating the model ' ,4)
Xout=Xobj.Xtarget.apply(Xsamples); % y_A=f(A)
if ~isempty(opencossan.OpenCossan.getDatabaseDriver)
    insertRecord(opencossan.OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
        'Nid',getNextPrimaryID(opencossan.OpenCossan.getDatabaseDriver,'Simulation'),...
        'XsimulationData',Xout,'Nbatchnumber',1)  
end

% values of the output variables
opencossan.OpenCossan.cossanDisp('Extract quantity of interest from SimulationData ' ,4)
Mout=Xout.getValues('Cnames',Xobj.Coutputnames);

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
hcomputeindices=@(Vx,Vout)computeMainEffect(Vx,Vout,Xobj.Nharmonics);

MfirstOrder=zeros(Ninputs,Noutputs);
MfirstOrderCoV=zeros(Ninputs,Noutputs);
MfirstOrderCI=zeros(2,Ninputs,Noutputs);

for nout=1:Noutputs
    
    for nin=1:Ninputs
        % Compute main effects
        MfirstOrder(nin,nout)=hcomputeindices(Mx(:,nin),Mout(:,nout));
        
        % Compute CoV
        Dybs=bootstrp(Xobj.Nbootstrap,hcomputeindices,Mx(:,nin),Mout(:,nout));
        MfirstOrderCoV(nin,nout)=std(Dybs)./MfirstOrder(nin,nout);
        
        % Compute CI
        MfirstOrderCI(:,nin,nout)=bootci(Xobj.Nbootstrap,{hcomputeindices,Mx(:,nin),Mout(:,nout)},'type','per');
    end
end



%% Finalizing timer
opencossan.OpenCossan.getTimer().lap('description','[Sensitivity:randomBalanceDesign] end sensitivity analysis')

end

function mainEffect=computeMainEffect(Vin,Vout,Nharmonics)
    [~, Mindex]=sort(Vin,1);  % Sort inputs
    VoutSorted=Vout(Mindex); % Sort outputs
    
    % Compute the spectrum using the fft
    spectrum=(abs(fft(VoutSorted))).^2/length(Vin);
    mainEffect=2*sum(spectrum(2:Nharmonics+1))/sum(spectrum(2:length(Vin)));
end

