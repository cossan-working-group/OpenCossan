function Xsamples  = sample(Xobj,varargin)
import opencossan.common.Samples
%SAMPLE
% This method generate a Samples object for the LineSampling.
%
% See also: https://cossan.co.uk/wiki/index.php/sample@AdvancedLineSampling
%
% Author: Marco De Angelis
% Institute for Risk and Uncertainty, University of Liverpool, UK
%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%% Initialize variables
Nlines=Xobj.Nlines;
Nvars=Xobj.Nvars;

%% Process Inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xinput'}
            Xinput=varargin{k+1};
        case {'nlines'}
            Nlines=varargin{k+1};
        otherwise
            error('openCOSSAN:LineSampling:sample',...
                ['Input parameter ' varargin{k} ' not allowed '])
    end
end

%% Generate samples
radialDeviation=1;
%Generate random points in the reduced space
Msamples = radialDeviation*randn(Nvars,Nlines);
% %Calculate density functions
% VoriginalPDF=prod(normpdf(Msamples,0,1),1);
% VimportancePDF=prod(normpdf(Msamples,0,radialDeviation),1);
% %Compute the weights; note that if radialDeviation=1 this
% %weights must be all ones.
% VimportanceWeights=exp((log(VoriginalPDF)-log(VimportancePDF)));



% Create the sample set
Xsamples = Samples('MsamplesStandardNormalSpace',Msamples',...
    'Xinput',Xinput);

