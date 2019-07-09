function [Xgradient varargout]= gradientFiniteDifferences(varargin)
% FUNCTION gradientFiniteDifferences. Estimate the gradient of the Model
% and ProbabilisticModel with respect to the input random variables.
% The finite differences method is used to estimate the gradient
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/GradientFiniteDifferences@Sensitivity
%
% ==============================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% ==============================================================================
%
% $Copyright~1993-2012,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
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

warning('OpenCossan:Sensitivity',...
    strcat('DEPRECATED METHOD!!!!',...
    '\n This static method will be remove soon!!!',...
    '\n More info:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@Sensitivity'))

    % Lap time for each batch
    OpenCossan.setAnalysisID;
    if ~isdeployed && isempty(OpenCossan.getAnalysisName)
    OpenCossan.setAnalysisName('gradientFiniteDifferences');
end
OpenCossan.setLaptime('description', ...
    '[Sensitivity:gradientFiniteDifferences] Start estimator of the Gradinet');
    
varargin{end+1}='Lgradient';
varargin{end+1}=true;

[Xgradient varargout{1}]=Sensitivity.coreFiniteDifferences(varargin{:});

OpenCossan.setLaptime('description', ...
    '[Sensitivity:gradientFiniteDifferences] Estimation of the Gradient completed');
