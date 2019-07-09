function [Xlsm varargout]= localMonteCarlo(varargin)
% FUNCTION localMonteCarlo
% This method estimates the LocalSensitivityMeasures by means of the Monte Carlo
% method described in the following papers:
%
%   1) E.Patelli and H.J.Pradlwarter
%   Monte Carlo gradient estimation in High Dimension
%   Int.J.Numer.Meth Engng, 2009 (DOI:10.10002/nme)
%
%   2) H.J.Pradlwarter
%   Relative importance of uncertain structural prameters
%   Comput. Mech (2007) 40:627-635 (DOI: 10.1007/s00466-006-0127-9)
%
% If the vector of important direction is not provided the gradient is
% computed in the original space and not in a transformed space.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/LocalMonteCarlo@Sensitivity
%
% ==============================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% ==============================================================================      
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli

%% Convenction
% The matricies  use the following convenction: (Ndimension,Nsimulation)

warning('OpenCossan:Sensitivity',...
    strcat('DEPRECATED METHOD!!!!',...
    '\n This static method will be remove soon!!!',...
    '\n More info:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@Sensitivity'))

    % Lap time for each batch
    OpenCossan.setAnalysisID;
    if ~isdeployed && isempty(OpenCossan.getAnalysisName)
    OpenCossan.setAnalysisName('localMonteCarlo');
end
OpenCossan.setLaptime('description', ...
    '[Sensitivity:localMonteCarlo] Start estimator of the LocalSensitivityMeasures');

varargin{end+1}='Lgradient';
varargin{end+1}=false;

[Xlsm varargout{1}]=Sensitivity.coreMonteCarlo(varargin{:});

OpenCossan.setLaptime('description', ...
    '[Sensitivity:localMonteCarlo] Estimation of the LocalSensitivityMeasures completed');
