function XS = sample(Xbset,varargin)
%SAMPLE   produce samples of a set of interval variables
%  
% The method returns a a Samples object containing the samples of the
% interval variable set
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Sample@BoundedSet
%
% Author: Marco de Angelis
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
if nargin==1
    Nsample=1;
else
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case {'nsample','nsamples'} % Define the number of samples
                Nsample = varargin{k+1};
            otherwise
                error('openCOSSAN:BoundedSet',...
                    'Option %s is not valid',varargin{k})
        end
    end
end

%% Sampling

MH=rand(Nsample,Xbset.Niv);
XS = Samples('Xbset',Xbset,'MsamplesUnitHypercube',MH);


% 
% if isempty(Xrvs.McorrelationNataf)
%     VX = rand(Nsim,Xrvs.Nrv);
% else
%     VX = copularnd(Xrvs.Scopulatype, full(Xrvs.McorrelationNataf),Nsim);
% end
% 
% XS = Samples('Xrvset',Xrvs,'MsamplesHyperCube',VX);

end
