function varargout = evalpdf(Xobj,varargin)
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

%% Argument Verification
OpenCossan.validateCossanInputs(varargin{:});

% initialize variables
Nrv=Xobj.Nrv; % Number of Random Variables
Llog=false;

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'mxsamples','mx','msamplesphysicalspace'}
            MX=varargin{k+1};
            
            assert(size(MX,2)==Nrv, ...
                'openCOSSAN:RandomVariableSet:evalpdf', ...
                'Wrong no. of columns (%i) of MX - must be equal to the number of Random Variables defined in the set (%i)',size(MX,2),Nrv);
            
            
            %                 MU=map2stdnorm(Xrvset,'mxsamples',MX);
        case {'musamples','mu','msamplesstandardnormalspace'}
            MU=varargin{k+1};
            %                 MX=map2physical(Xrvset,'ms',MU);
            
            assert(size(MU,2)==Nrv, ...
                'openCOSSAN:RandomVariableSet:evalpdf', ...
                'Wrong no. of columns (%i) of MU - must be equal to the number of Random Variables defined in the set (%i)',size(MU,2),Nrv);
            
        case {'mhsamples','mh','msampleshypercube'}
            MH=varargin{k+1};
            %                 MX=map2physical(Xrvset,'ms',MU);
            
            assert(size(MU,2)==Nrv, ...
                'openCOSSAN:RandomVariableSet:evalpdf', ...
                'Wrong no. of columns (%i) of MH - must be equal to the number of Random Variables defined in the set (%i)',size(MH,2),Nrv);
            
        case {'cxsamples','xsamples'}
            if iscell(varargin{k+1})
                MX=varargin{k+1}{1}.MsamplesPhysicalSpace;
            else
                MX=varargin{k+1}.MsamplesPhysicalSpace;
            end
        case {'llog'}
            Llog=varargin{k+1};
        otherwise
            error('openCOSSAN:RandomVariableSet:evalpdf',...
                'PropertyName %s not allowed',varargin{k})
    end
end

% check about
if exist('MU','var')+ exist('MX','var') + exist('MH','var')~=1
    error('openCOSSAN:RandomVariableSet:evalpdf',...
        'one and only one of the fields MX/MU/MH must be defined')
end

if exist('MX','var')
    Nsim = size(MX,1);
    Vpdfrv = zeros(Nsim,Nrv);
    
    
    for j=1:Nrv
        Vpdfrv(:,j) =evalpdf(Xobj.Xrv{j},MX(:,j));
    end
    
    %in case rv's are not independent, calculate correction coefficient for pdf
    %this correction factor accounts
    %for the correlations between random variables;
    %for details on the theory, please see P. Liu & A. Der
    %Kiureghian. Multivariate distribution models with
    %prescribed marginals and covariances. Probabilistic
    %Engineering Mechanics 1(2),105-112
    
    if ~Xobj.Lindependence,
        MY      = zeros(size(MX));
        for ii=1:Nrv,
            MY(:,ii)    = map2stdnorm(Xobj.Xrv{ii}, MX(:,ii));
        end
        correction  = mvnpdf(MY,zeros(1,Nrv),Xobj.McorrelationNataf)./...
            prod(normpdf(MY),2);
    else
        correction  = 1;    %no correction is required, as the rv's are independent
    end
    if Llog
        Vpdfrv=log(Vpdfrv);
        Vpdf=sum(Vpdfrv,2)+log(correction);
    else
        Vpdf=prod(Vpdfrv,2).*correction;
    end
    
elseif exist('MU','var')
    
    Nsim = size(MU,1);
    Vpdfrv = zeros(Nsim,Nrv);
    
    for j=1:Nrv
        Vpdfrv(:,j) =normpdf(MU(:,j));
    end
    if Llog
        Vpdf=sum(log((Vpdfrv)),2);
        Vpdfrv=log(Vpdfrv);
    else
        Vpdf=prod(Vpdfrv,2);
    end
elseif exist('MH','var')
    
    Vpdfrv  = ones(size(MH));
    
    Vpdf = copulapdf('Gaussian',MH,Xobj.Mcorrelation);
    
    if Llog
        Vpdfrv=log(Vpdfrv);
        Vpdf=sum(Vpdf);
    end
end


% Export results
varargout{1}=Vpdf;
varargout{2}=Vpdfrv;

