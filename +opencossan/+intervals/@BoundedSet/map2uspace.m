function MU=map2uspace(Xbset,MX)
%MAP2USPACE maps a value from the space of the bounded variables included
%in the bounded set object to the u space
%
%  MANDATORY ARGUMENTS
%    - MX:   Matrix of samples of Intervals in Physical Space
%
%  OUTPUT ARGUMENTS:
%    - MU:   Matrix of samples of Intervals in Standard Space 
%
%  Usage: MU = map2uspace(Xbset,MX) 
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

if not(size(MX,2)==length(Xbset.Cmembers))
    error('openCOSSAN:RVSET:map2physical','Number of columns of MX must be equal to # of bv''s in convexset');
end

Nint = length(Xbset.Cmembers);
Nsamples = size(MX,1);
MY = zeros(Nsamples,Nint); 
for i=1:Nint
    MY(:,i) = map2uspace(Xbset.CXint{i}, MX(:,i));                                                                                
end
MU  = MY;
end