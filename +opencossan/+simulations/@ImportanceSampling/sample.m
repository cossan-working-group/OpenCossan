function [samples, weights] = sample(obj,varargin)
    %SAMPLE
    % This method generate a Samples object.
    % The samples are generated according the IS distribution.
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/sample@ImportanceSampling
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs("input", varargin{:});
    optional = opencossan.common.utilities.parseOptionalNameValuePairs("samples", {obj.NumberOfSamples}, varargin{:});
    
    validateattributes(required.input, {'opencossan.common.inputs.Input'}, {'scalar'});
    validateattributes(optional.samples, {'numeric'}, {'scalar', 'integer'});
    
    assert(all(contains(obj.ProposalDistribution.Names, required.input.RandomInputNames)), ...
        'OpenCossan:ImportanceSampling:sample', ...
        'Variables from the proposal distribution not found in the input.');
    
    % Build the "Original distribution" including all random variables from the input. 
    % 1. Process individual rvs
    n = required.input.NumberOfRandomVariables;
    members = required.input.RandomVariables;
    names = required.input.RandomVariableNames;
    correlation = eye(numel(members));
    
    % 2. Process rvsets
    for rvset = required.input.RandomVariableSets
        m = rvset.Nrv;
   
        members = [members, rvset.Members]; %#ok<AGROW>
        names = [names, rvset.Names]; %#ok<AGROW>
        
        if m == 1
            correlation(n+m, n+m) = 1;
        else
            correlation(:, n+1:n+m) = rvset.Correlation;
            correlation(n+1:n+m, :) = rvset.Correlation;
        end
        
        n = n + m;
    end
    
    originalDistribution = opencossan.common.inputs.random.RandomVariableSet(...
            'members', members, 'names', names, 'correlation', correlation);
    
    % Generate the samples from the "Proposal distribution"
    proposalSamples = obj.ProposalDistribution.sample(optional.samples);
    samplesInStd = obj.ProposalDistribution.map2stdnorm(proposalSamples);
    hPdf = log(pdf(obj.ProposalDistribution, proposalSamples));
    
    % Compute the pdf of the unmapped random variables and the correction factor
    unmappedDistribution = originalDistribution.remove(obj.ProposalDistribution.Names);
    if unmappedDistribution.Nrv > 0
        unmappedIndices = ismember(originalDistribution.Names, unmappedDistribution.Names);
        sigma11 = originalDistribution.NatafModel.Correlation(unmappedIndices, unmappedIndices);
        sigma12 = originalDistribution.NatafModel.Correlation(unmappedIndices, ~unmappedIndices);
        sigma22 = originalDistribution.NatafModel.Correlation(~unmappedIndices, ~unmappedIndices);
        
        means = samplesInStd{:, :} * (sigma12 / sigma22)';
        covariance = sigma11 - sigma12 / sigma22 * sigma12';
        
        samplesInStd{:, unmappedDistribution.Names} = mvnrnd(means, covariance);
        % The correction factor is the ratio between the pdf of the correlated normal and the
        % uncorrelated normal (eq. 11 paper on nataf transformation)
        correctionFactor = log(mvnpdf(samplesInStd{:, unmappedDistribution.Names}, ...
            means, covariance)) - sum(log(normpdf(samplesInStd{:, unmappedDistribution.Names})), 2);
        
        samples = table();
        % Map samples to physical space manually to avoid correlating again through the rvset.
        for rv = 1:unmappedDistribution.Nrv
            samples.(unmappedDistribution.Names(rv)) = ...
                unmappedDistribution.Members(rv).map2physical(samplesInStd.(unmappedDistribution.Names(rv)));
        end
        unmappedPdf = log(pdf(unmappedDistribution, samples));
    else
        correctionFactor = 0;
        unmappedPdf = 0;
        samples = table();
    end
    
    samples = [proposalSamples samples];
    fPdf = log(pdf(originalDistribution, samples));
    
    weights = exp(fPdf - hPdf - unmappedPdf - correctionFactor);
    
    samples = required.input.completeSamples(samples);
end