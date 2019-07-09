function [Mconvex] = defineMconvex(Xbset)
%DEFINEMCONVEX compute the characteristic matrix of the Convex Set object in
%the u-space. The characteristic matrix results to be identical to the
%covariance and correlation matrix in the same space, according to (Jiang et al. 2011)
%
%  MANDATORY ARGUMENTS
%    - Xbset:   Bounded Set Object
%
%  OUTPUT ARGUMENTS:
%    - McharacteristicUspace:   Characteristic matrix/ Covariance matrix/
%                                   Correlation matrix in u-space
%
%  Usage: McharacteristicUspace = defineMconvex(Xcs) 
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

Vvar=Xbset.Vradia.^2;
Mcov=Xbset.Mcovariance;
Nintervals=length(Xbset.Cmembers);
McharacteristicUspace=zeros(size(Mcov));
for j=1:Nintervals
    for i=1:Nintervals
    McharacteristicUspace(i,j)= Mcov(i,j)./(sqrt(Vvar(i))*(sqrt(Vvar(j))));
    end
end
Mconvex=inv(McharacteristicUspace);
end