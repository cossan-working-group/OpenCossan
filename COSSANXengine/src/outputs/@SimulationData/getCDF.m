function [Vsupport,Vcdf] = getCDF(Xobj,varargin)
%GETPDF This method computes the empirical CDF of the samples stored in the SimulationData object.
%
%  USAGE: [Vsupport,Vcdf]=XsimulationData.getCDF(varargin)
%
%  The method returns the vector of the support points (Vsupport) and the vector
%  of values of the CDF (Vcdf).
%
%  Valid input arguments: Nbins, Sname, Cnames, Vsuppport
%
%  See Also: http://cossan.co.uk/wiki/index.php/getCDF@SimulationData
%
% $Copyright~1993-2016,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$

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


%% Set default values
Nbins=[];
CrequestedVariables=Xobj.Cnames; %

try
    [Vsupport,Vpdf]=Xobj.getPDF(varargin{:});
catch exception
    throwAsCaller(exception)
end

%% Evaluate CDF
Vcdf=cumsum(Vpdf,1);





