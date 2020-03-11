function samples = sample(obj, varargin)
    %SAMPLE
    % This method generate a Samples object using the LatinHypercube algorithms
    %
    % WARINING: The StochasticProcess are ALWAYS generate using plain Monte Carlo sample (i.e. using
    % function randn).
    %
    %
    %  Usage: SAMPLE(XLHS,'Nsamples',NSIM) E.g.:  [Xinput MSAMPLES]=SAMPLE(XRVS,'Nsamples',10)
    %  produces ten samples (rows)
    %
    % See Also: http://cossan.co.uk/wiki/index.php/sample@LatinHypercube
    
    % Author: Edoardo Patelli Institute for Risk and Uncertainty, University of Liverpool, UK email
    % address: openengine@cossan.co.uk Website: http://www.cossan.co.uk
    
    % ===================================================================== This file is part of
    % openCOSSAN.  The open general purpose matlab toolbox for numerical analysis, risk and
    % uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify it under the terms of the
    % GNU General Public License as published by the Free Software Foundation, either version 3 of
    % the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    % without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
    % the GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License along with openCOSSAN.  If
    %  not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs("input", varargin{:});
    optional = opencossan.common.utilities.parseOptionalNameValuePairs("samples", {obj.NumberOfSamples}, varargin{:});
    
    validateattributes(required.input, {'opencossan.common.inputs.Input'}, {'scalar'});
    
    % The Latin Hypercube Sample method generates values in uncorrelated unit hypercube Show values
    % of the variable passed to lhsdesign
    
    opencossan.OpenCossan.cossanDisp(sprintf("[LatinHypercubeSampling] Samples: (%i, %i)", ...
        optional.samples, required.input.NumberOfRandomInputs),3);
    opencossan.OpenCossan.cossanDisp(sprintf("[LatinHypercubeSampling] Iterations: %i", ...
        obj.Iterations),3);
    opencossan.OpenCossan.cossanDisp(sprintf("[LatinHypercubeSampling] Criterion: %s", ...
        obj.Criterion),3);
    opencossan.OpenCossan.cossanDisp(sprintf("[LatinHypercubeSampling] Smooth: %s", ...
        string(obj.Smooth)),3);
    
    smooth = 'on';
    if ~obj.Smooth
        smooth = 'off';
    end
    
    samples = lhsdesign(optional.samples, required.input.NumberOfRandomInputs, ...
        'iteration', obj.Iterations, 'criterion', obj.Criterion, 'smooth', smooth);
    
    samples = required.input.hypercube2physical(samples);
    samples = required.input.addParametersToSamples(samples);
    samples = required.input.evaluateFunctionsOnSamples(samples);
end



