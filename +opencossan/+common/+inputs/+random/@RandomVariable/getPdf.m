function [support, pdf] = getPdf(obj,varargin)

%% process input
p = inputParser;
p.FunctionName  = 'opencossan.common.inputs.random.RandomVariable.getPdf';
p.KeepUnmatched = true;
p.addParameter('samples',10000);
p.addParameter('bins',100);
p.addParameter('analytical',true);
p.addParameter('support',[]);

p.parse(varargin{:});

if nargin > 0
    samples    = p.Results.samples;
    bins       = p.Results.bins;
    analytical = p.Results.analytical;
    support    = p.Results.support;
end

if ~isempty(support)
    bins = length(support);
end

%%  Compute support points
if isempty(support)
    %Try to compute the pdf and support analytically
    Vcdf = 0:1/bins:1;
    support = obj.cdf2physical(Vcdf);
    % Remove +Inf / -Inf
    support = support(~isinf(support));
    % Rescaling support points
    switch lower(class(obj))
        case {'opencossan.common.inputs.random.binomialrandomvariable',...
                'opencossan.common.inputs.random.negativebinomialrandomvariable',...
                'opencossan.common.inputs.random.hypergeometricrandomvariable',...
                'opencossan.common.inputs.random.poissonrandomvariable',...
                'opencossan.common.inputs.random.geometricrandomvariable'}
            support = support(1):support(end);
        otherwise
            support = support(1):abs(support(end) - support(1))/bins:support(end);
    end
end
%% Evaluate PDF
if ~analytical
    samples = obj.sample('samples',samples);
    [pdf, support] = hist(samples,bins);
    delta = support(2) - support(1);
    % Normalize the pdf
    pdf = pdf/(samples*delta);
else
    pdf = obj.evalpdf(support);
end
end