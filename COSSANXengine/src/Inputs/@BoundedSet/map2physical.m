function MY = map2physical(Xbset,varargin)
%MAP2PHYSICAL   maps values from the unitary hypercube to the physical
%space
%  
% The method returns a matrix array with the mapped values
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

if nargin==2
    MH=varargin{1};
else
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case {'mh','msampleshypercube'} % Define the number of samples
                MH = varargin{k+1};
            otherwise
                error('openCOSSAN:BoundedSet',...
                    'Option %s is not valid',varargin{k})
        end
    end
end

if Xbset.Lindependence
    MY=repmat(Xbset.VlowerBounds,size(MH,1),1)+2*repmat(Xbset.Vradia,size(MH,1),1).*MH;
else
    switch Xbset.ScorrelationFlag
        case '1' % box
            %todo
        case '2' % ellipse
            %todo
        case '3' % polytope
            %todo
    end
end









