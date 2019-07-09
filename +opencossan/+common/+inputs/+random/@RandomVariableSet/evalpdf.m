function varargout = evalpdf(obj,varargin)
%EVALPDF Evaluates the multidimensional probability density of a set of
%points in the physiscal space.
%
% See also: https://cossan.co.uk/wiki/index.php/evalpdf@RandomVariableSet
%
% Author: Edoardo Patelli
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


import opencossan.OpenCossan

%% Process inputs
Nrv = obj.Nrv;                          % Number of Random Variables

p = inputParser;
p.FunctionName = 'opencossan.common.inputs.random.RandomVariableSet.pdfRatio';

p.addParameter('MXSamples',[]);         % 'mxsamples','mx','msamplesphysicalspace'
p.addParameter('MUSamples',[]);         % 'musamples','mu','msamplesstandardnormalspace'
p.addParameter('MHSamples',[]);         % 'mhsamples','mh','msampleshypercube'
p.addParameter('CXSamples',[]);         % 'cxsamples','xsamples'
p.addParameter('Llog',false);

p.parse(varargin{:});

MX      = p.Results.MXSamples;
MU      = p.Results.MUSamples;
MH      = p.Results.MHSamples;
Llog    = p.Results.Llog;

if (~isempty(p.Results.CXSamples))
    if (iscell(p.Results.CXSamples))
        MX = p.Results.CXSamples{1}.MsamplesPhysicalSpace;
    else
        MX = p.Results.CXSamples.MsamplesPhysicalSpace;
    end
end

%% Check Input
assert(isempty(MX) || size(MX,2) == Nrv, ...
    'openCOSSAN:RandomVariableSet:evalpdf', ...
    'Wrong no. of columns (%i) of MX - must be equal to the number of Random Variables defined in the set (%i)',size(MX,2),Nrv);

assert(isempty(MU) || size(MU,2) == Nrv, ...
    'openCOSSAN:RandomVariableSet:evalpdf', ...
    'Wrong no. of columns (%i) of MU - must be equal to the number of Random Variables defined in the set (%i)',size(MU,2),Nrv);

assert(~isempty(MX) + ~isempty(MU) + ~isempty(MH) == 1, ...
    'openCOSSAN:RandomVariableSet:evalpdf',...
    'one and only one of the fields MX/MU/MH must be defined')


%% Calculation
if (~isempty(MX))
    Nsim = size(MX,1);
    Vpdfrv = zeros(Nsim,Nrv);
    
    for j = 1:Nrv
        Vpdfrv(:,j) = evalpdf(obj.Members(j),MX(:,j));
    end
    
    %in case rv's are not independent, calculate correction coefficient for pdf
    %this correction factor accounts
    %for the correlations between random variables;
    %for details on the theory, please see P. Liu & A. Der
    %Kiureghian. Multivariate distribution models with
    %prescribed marginals and covariances. Probabilistic
    %Engineering Mechanics 1(2),105-112
    
    if (~obj.isIndependent())
        MY = zeros(size(MX));
        
        for k = 1:Nrv
            MY(:,k) = map2stdnorm(obj.Members(k), MX(:,k));
        end
        
        correction  = mvnpdf(MY,zeros(1,Nrv),obj.NatafModel.Correlation)./...
            prod(normpdf(MY),2);
    else
        correction  = 1;                %no correction is required, as the rv's are independent
    end
    
    if (Llog)
        Vpdfrv = log(Vpdfrv);
        Vpdf   = sum(Vpdfrv,2) + log(correction);
    else
        Vpdf   = prod(Vpdfrv,2).* correction;
    end
    
elseif (~isempty(MU))
    Nsim   = size(MU,1);
    Vpdfrv = zeros(Nsim,Nrv);
    
    for j = 1:Nrv
        Vpdfrv(:,j) = normpdf(MU(:,j));
    end
    if Llog
        Vpdf   = sum(log((Vpdfrv)),2);
        Vpdfrv = log(Vpdfrv);
    else
        Vpdf   = prod(Vpdfrv,2);
    end
    
elseif (~isempty(MH))
    Vpdfrv  = ones(size(MH));
    Vpdf    = copulapdf('Gaussian', MH, obj.Correlation);
    
    if (Llog)
        Vpdfrv = log(Vpdfrv);
        Vpdf   = sum(Vpdf);
    end
end

% Export results
varargout{1} = Vpdf;
varargout{2} = Vpdfrv;

end
