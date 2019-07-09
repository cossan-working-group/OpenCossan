function Vbounds = intervalNodeBounds(Node, varargin)
%COMPUTEBOUNDS method of the class Node, allows to compute the
%bounds for the discretization of the node in case these are not defined by
%the user
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


p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.IntervalNode.intervalNodeBounds';

% Initialize input
p.addParameter('Nstates',3,@(s)isnumeric(s)); % number of discretized outcome states
p.parse(varargin{:});
% Assign input
Nstates      = p.Results.Nstates;

% Initialize variables
Nvs             = numel(Node.CPD);  % number of RVs/IVs in the CPD (distributions to discretize)
VlowerBound     = zeros(1,Nvs);     % vector of lower bounds of each disctribution
VupperBound     = zeros(1,Nvs);     % vector of upper bounds of each disctribution


if Node.Lroot
    VinitialCPDsize =size(Node.CPD,2);
else
    VinitialCPDsize =size(Node.CPD);
end

for ivar=1:Nvs  
    comb=num2cell(common.utilities.myind2sub(VinitialCPDsize,ivar));
    XVs=Node.CPD{comb{:}};
    % collect lower bound of the RV/BV
    VlowerBound(ivar)=XVs.lowerBound;
    VupperBound(ivar)=XVs.upperBound;
end

% Lower and upper bound of the new discrete node
lowerBound = min(VlowerBound);    % min of lower bounds of all RVs
upperBound = max(VupperBound);    % max of upper bounds of all RVs

interval   = (upperBound-lowerBound)/(Nstates);  % interval between two bounds
Vbounds    = (lowerBound:interval:upperBound);   % Bounds of the discretization

end

