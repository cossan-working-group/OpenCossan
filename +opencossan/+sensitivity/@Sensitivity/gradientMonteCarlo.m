function [Xgradient varargout] = gradientMonteCarlo(varargin)
% FUNCTION gradientMonteCarlo
% This method is based on the two papers:
%   1) E.Patelli and H.J.Pradlwarter
%   Monte Carlo gradient estimation in High Dimension
%   Int.J.Numer.Meth Engng, 2009 (DOI:10.10002/nme)
%   2) H.J.Pradlwarter
%   Relative importance of uncertain structural prameters
%   Comput. Mech (2007) 40:627-635 (DOI: 10.1007/s00466-006-0127-9)
%
% If the vector of important direction is not provided the gradient is
% computed in the original space and not in a transformed space.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/gradientMonteCarlo@Sensitivity
%
% ==============================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% ==============================================================================
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli

warning('OpenCossan:Sensitivity',...
    strcat('DEPRECATED METHOD!!!!',...
    '\n This static method will be remove soon!!!',...
    '\n More info:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@Sensitivity'))

% Lap time for each batch
OpenCossan.setAnalysisID;
if ~isdeployed && isempty(OpenCossan.getAnalysisName)
    OpenCossan.setAnalysisName('gradientMonteCarlo');
end
OpenCossan.setLaptime('description', ...
    '[Sensitivity:gradientMonteCarlo] Start estimator of the Gradinet');

varargin{end+1}='Lgradient';
varargin{end+1}=true;

[Xgradient varargout{1}]=Sensitivity.coreMonteCarlo(varargin{:});

% Set timer
OpenCossan.setLaptime('description', ...
    '[Sensitivity:gradientMonteCarlo] Estimation of the Gradient completed');
