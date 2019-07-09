function Vpdf = pdfRatio(obj,varargin)
%UEVALPDF Evaluates the ratio between the pdf.
%  the Nvar-dimensional STANDARD NORMAL SPACE MU, where Nvar is the # of
%  columns of MU  and the # of rows of MU is the number of samples
%
%
%   MANDATORY ARGUMENTS:
%    - obj              RandomvariableSet object
%    - Numerator        Numerator of the fraction
%    - Denominator      Denominator of the fraction
%
%   OPTIONAL ARGUMENTS:
%    - PhysicalSpace    Flag for defining if the matrixes are in
%                       PhysicalSpace (default = false)
%
%   OUTPUT:
%   -  Vpdf             Vector of the pdf
%
%  Vratio = pdfRatio(rvset,'Numerator',MU1,'Denominator',MU2)
%

%% Process inputs
p = inputParser;
p.FunctionName = 'opencossan.common.inputs.random.RandomVariableSet.pdfRatio';

p.addParameter('Denominator',[]);
p.addParameter('Numerator',[]);
p.addParameter('PhysicalSpace',false);

p.parse(varargin{:});

Denominator     = p.Results.Denominator;
Numerator       = p.Results.Numerator;
PhysicalSpace   = p.Results.PhysicalSpace;


%% checks inputs
assert(size(Denominator,1) == size(Numerator,1)&& ...
       size(Denominator,2) == size(Numerator,2),...
    'openCOSSAN:RandomVariableSet:pdfRatio',...
    'The Denominator and Numerator must have the same size')

assert(size(Denominator,2) == obj.Nrv,...
    'openCOSSAN:RandomVariableSet:pdfRatio',...
    'Wrong no. of columns of the inputs matrixes - must be equal to length RandomVariableSet.Members');

if (PhysicalSpace)
    Denominator = map2stdnorm(obj,Denominator);
    Numerator   = map2stdnorm(obj,Numerator);
end

Nsim              = size(Denominator,1);
VpdfrvNumerator   = zeros(Nsim,obj.Nrv);
VpdfrvDenominator = zeros(Nsim,obj.Nrv);

for j = 1:length(obj.Names)
    VpdfrvNumerator(:,j)   = normpdf(Numerator(:,j));
    VpdfrvDenominator(:,j) = normpdf(Denominator(:,j));
end

Vpdf = exp(sum(log(VpdfrvNumerator),2) - sum(log(VpdfrvDenominator),2));
end

