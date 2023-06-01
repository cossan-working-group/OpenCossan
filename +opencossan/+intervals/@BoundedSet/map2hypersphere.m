function MsamplesHypersphere=map2hypersphere(Xbset,MX)
% MSALMPLESHYPERSPHERE maps a value from the u space of the interval variables included
% in the bounded set object to a delta space where the uncertainty set is a
% multiple sphere with a unit radius
%
%  MANDATORY ARGUMENTS
%    - MU:   Matrix of samples of Intervals in Standard Space
%
%  OUTPUT ARGUMENTS:
%    - MD:   Matrix of samples of Intervals in Delta Spac 
%
%  Usage: MD = MAP2DELTASPACE(Xbset,MU) 
%
%  See also: BoundedSet
%
% Author: Silvia Tolo
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk
%
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


Nint=length(Xbset.Cmembers);

if size(MX,1)==Nint && ~size(MX,2)==Nint 
    MX=MX';
elseif ~size(MX,1)==Nint && ~size(MX,2)==Nint 
    error('openCOSSAN:ConvexSet:map2deltaSpace',...
     'No consistent number of samples for all the variables');
end
MU=map2uspace(Xbset,MX);
% Compute eigenvalue decomposition
[Phi, lambda]= eig(Xbset.defineMconvex);
%Samples in Delta Space expressed in cartesian coords
MsamplesHypersphere=(sqrt(lambda)*Phi'*MU')';

