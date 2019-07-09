function MY = map2physical(Xbset,varargin)
%MAP2PHYSICAL   maps points from hypercube or hypersphere into the physical
%  space of the bounded variables included in the boundedset object, according
%   to the correlation type.
%    
%
% Author: Silvia Tolo
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
MH=[];
MHS=[];
if nargin==2
    MH=varargin{1};
else
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case {'mh','msampleshypercube'} % Define the number of samples
                MH = varargin{k+1};
            case {'mhs','msampleshypersphere','mhypersphere'} % Define the number of samples
                MHS = varargin{k+1};
            otherwise
                error('openCOSSAN:BoundedSet',...
                    'Option %s is not valid',varargin{k})
        end
    end
end

if Xbset.Lindependence && ~Xbset.Lconvex
    if isempty(MHS)
        error('openCOSSAN:BoundedSet',...
            'Samples in the Hyperscube space are required to be mapped in Physical Space')
    end
    MY=repmat(Xbset.VlowerBounds,size(MH,1),1)+2*repmat(Xbset.Vradia,size(MH,1),1).*MH;
    
elseif strcmp(Xbset.ScorrelationFlag,'1')  % box
    % todo
    
elseif (~Xbset.Lindependence && strcmp(Xbset.ScorrelationFlag,'2')) || Xbset.Lconvex % correlation shape ellypse
    if isempty(MHS)
        error('openCOSSAN:BoundedSet',...
            'Samples in the Hypersphere are required to be mapped in Physical Space')
    elseif size(MHS,1)==Xbset.Niv && ~size(MHS,2)==Xbset.Niv
        MHS=MHS';
    elseif ~size(MHS,1)==Xbset.Niv && ~size(MHS,2)==Xbset.Niv
        error('openCOSSAN:BoundedSet:map2physical',...
            'No consistent number of samples for all the variables');
    end
    %% Map!
    [Phi, lambda] = eig(Xbset.defineMconvex.'); %% need left eigenvectors: Phi*Mconvex=lambda*Phi
    MU=MHS*sqrt(lambda)^-1*Phi';
    Nvar = length(Xbset.Cmembers);
    Nsim = size(MU,1);
    % preallocate memory
    MY = zeros(Nsim,Nvar);
    for i=1:Nvar
        MY(:,i) = map2physical(Xbset.CXint{i},MU(:,i));
    end
elseif strcmp(Xbset.ScorrelationFlag,'3')  % polytope
    % todo
end
end









