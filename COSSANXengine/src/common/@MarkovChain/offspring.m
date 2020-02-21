function Xs  = offspring(Xmkv)
%OFFSPRING   Generate offspring for Markov chains
%  Xs = OFFSPRING(XMKV),
%            where XMKV ... MarkovChain array
%            and Xs is a Samples object
%
% See also: https://cossan.co.uk/wiki/index.php/offspring@MarkovChain
%
% ==================================================================
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

%% Generate samples from the proposal distribution

% Generate samples for each RandomVariableSet
Xs=Samples;

NinitialRVindex=1;
for n=1:Xmkv.Nsets
    NendRVindex=Xmkv.XoffSprings(n).Nrv+NinitialRVindex-1;
    
    MX_pert = sample(Xmkv.XoffSprings(n),Xmkv.Xsamples(1).Nsamples);   
     
    % Calculate the point in the SNS
    % Point from the last ring of the chain + the sample generated from the
    % proposal distribution
    MUlast=Xmkv.Mlast(:,NinitialRVindex:NendRVindex); % Retrive matrix for speed up (1 call instead of 3 calls)
    
    Mxi = MX_pert.MsamplesPhysicalSpace + MUlast;
    
    % [EP] evaluate the log of the pdf
    [~, Mrvi]=evalpdf(Xmkv.Xbase(n),'Musamples', Mxi);
    [~, Mrv0]=evalpdf(Xmkv.Xbase(n),'Musamples', MUlast);
    
    Mrv=Mrvi./Mrv0;
    
    %% Perturb each component of w/ probability Mrv
    
    %% Sample the component to be perturbed
    MU_index=(rand(size(Mrv)) < min(Mrv,1));    
    
    MU =MUlast + MX_pert.MsamplesPhysicalSpace.*MU_index;
    
    NinitialRVindex=NendRVindex+1;
    
    %% Export the Samples Object    
    XsTmp=Samples('Msamplesstandardnormalspace',MU,'Xrvset',Xmkv.Xbase(n));
    Xs=Xs.add('Xsamples',XsTmp);
end





