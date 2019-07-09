function Xsamples  = sample(Xobj,varargin)
%SAMPLE
% This method generate a Samples object for the LineSampling.
%
% See also: https://cossan.co.uk/wiki/index.php/sample@LineSampling
%
% Author: Edoardo Patelli and Marco de Angelis
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

import opencossan.common.Samples 

%% Validate input arguments
opencossan.OpenCossan.validateCossanInputs(varargin{:})

%% Initialize variables
Nlines=Xobj.Nlines;

assert(logical(~isempty(Xobj.Valpha)), ...
    'openCOSSAN:LineSampling:sample',...
    'Please define an important direction before applying LineSampling')

Valpha=Xobj.Valpha;
Valpha=Valpha(:); % make sure "Valpha" is not a row vector

Nvars=length(Valpha);

Vset=Xobj.Vset; % support points

Npoints=length(Xobj.Vset); % Number of support points (along each line)

%% Process Inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'nlines'}
            Nlines=varargin{k+1};
        case {'xinput'}
            Xinput=varargin{k+1};
        case {'vset'}
            Vset=varargin{k+1};
        otherwise
            error('openCOSSAN:LineSampling:sample',...
                ['Input parameter ' varargin{k} ' not allowed '])
    end
end

assert(logical(exist('Xinput','var')), ...
    'openCOSSAN:LineSampling:sample',...
    'An Input object is required to generate samples for LineSampling')


% Check if the gradient is compatible with the Input object
% check the Gradient object (check if the components defined in the
% Gradient object (Cnames) correspond to the variables defined in the Input
% object
Cnameinput=Xinput.RandomVariableNames;

if isempty(Xobj.CalphaNames)
    VmapImportantDirection=true(1,length(Cnameinput));
else
    VmapImportantDirection=ismember(Xobj.CalphaNames,Cnameinput);
    assert(sum(VmapImportantDirection)==length(Cnameinput), ...
    'openCOSSAN:LineSampling:sample',...
    ['The Gradient object define in the Linesampling can not be used with the Input defiened in the target object \n' ...
    '* Variable Names defined for important direction : ' sprintf('"%s" ',Xobj.CalphaNames{:})  ' \n' ...
    '* Variable Names present in the Input object     : ' sprintf('"%s" ',Cnameinput{:})])
end



%% Check number of variables
assert(Nvars==Xinput.NrandomVariables, ...
    'openCOSSAN:LineSampling:sample', ...
    ['Number of random variable in the Input (%i)', ...
    'does not match with the size of the important direction (%i)'], ...
    Xinput.NrandomVariables,Nvars)

%% Generate samples
% sample points in a plane orthogonal to the important direction
% (Xobj.Valpha) in a Standard Normal Space
%
% Generate random vector in the Standard Normal Space
MrandomPoints           = randn(Nvars,Nlines);
% Compute the orthogonal vectors
MhyperPlanePoints       = MrandomPoints - Valpha*(Valpha'*MrandomPoints);
% Compute the distances from origin of the points on the hyperplane
VhpDistances            = sqrt(sum(MhyperPlanePoints.^2,1));
% Sort the lines. This step is not mandatory. However it improves the
% efficiency of the LineSampling adopting the adaptive option.
% Furthermore it improves the stability of the CoV.
[~, s2]                 = sort(VhpDistances);
MhyperPlanePoints       = MhyperPlanePoints(:,s2);

opencossan.OpenCossan.cossanDisp([num2str(Nlines) ' lines created '],3)

% Define the mesh. Points along the lines where the performance
% function is evaluated
MhyperPlanePoints       = repmat(MhyperPlanePoints,Npoints,1);
MalphaSet               = repmat(Valpha*Vset,1,Nlines);
MlineSamplingPoints     = reshape(MhyperPlanePoints(:)+MalphaSet(:),...
    Nvars,Npoints*Nlines);

% Create the sample set
Xsamples = Samples('MsamplesStandardNormalSpace',MlineSamplingPoints',...
    'Xinput',Xinput);

