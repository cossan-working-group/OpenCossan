function Xobj=computeCDF(Xobj)
% This private function is used to compute the CDF of UNCORRELATED samples

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

% Compute experimental correlation
Msamples=Xobj.generatePhysicalSamples(Xobj.NsamplesMapping);
Xobj.Mcorrelation = corr(Msamples);
Xobj.Vsigma=std(Msamples);
Mcov = cov(Msamples);
Vvar=diag(Mcov);
% Preallocate Memory
Xobj.Mcdfs=zeros(Xobj.NsamplesMapping+1,Xobj.Nrv); % CDF of the uncorrelated  data
Xobj.McdfsValues=zeros(size(Xobj.Mcdfs));


for j=1:size(Xobj.MdataSet,2) % loop over the variables
    [Xobj.McdfsValues(:,j), Xobj.Mcdfs(:,j)]=ecdf(Msamples(:,j));
    Xobj.Mcdfs(1,j)=min(Msamples(:,j))-10*Vvar(j);

    %% Peacewise linear interpolation
    % This piecewise linear function provides a nonparametric estimate of the CDF
    % that is continuous and symmetric.  Evaluating it at points other than the
    % original data is just a matter of linear interpolation, and it can be
    % convenient to define an anonymous function to do that.
    
    % due to a Matlab bug introduced in R2015b the handle function need to
    % be initialised
    mcdfs = Xobj.Mcdfs(:, j);
    mcdfsValues = Xobj.McdfsValues(:, j);
    
    Xobj.Hcdf{j} = @(y)interp1(mcdfs, mcdfsValues, y, 'linear');
    Xobj.Hicdf{j} = @(y)interp1(mcdfsValues, mcdfs, y, 'linear');
end

return
