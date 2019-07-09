function [Xlsm varargout]= localFiniteDifferences(varargin)
% FUNCTION localFiniteDifferences.
% Estimate the LocalSensitivityMeasures of the Model/ProbabilisticModel with respect to the input random variables.
% The finite differences method is used to estimate the the local measures.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/LocalFiniteDifferences@Sensitivity
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
    OpenCossan.setAnalysisName('localFiniteDifferences');
end
OpenCossan.setLaptime('description', ...
    '[Sensitivity:localFiniteDifferences] Start estimator of the LocalSensitivityMeasure');

varargin{end+1}='Lgradient';
varargin{end+1}=false;

[Xlsm varargout{1}]=Sensitivity.coreFiniteDifferences(varargin{:});

% Set timer
OpenCossan.setLaptime('description', ...
    '[Sensitivity:localFiniteDifferences] Estimation of the LocalSensitivityMeasure completed');
