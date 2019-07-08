function [Vsupport, Vpdf] = getPdf(Xobj,varargin)
%GETPDF This method computes the empirical PDF of the RandomVariable object.
%
%  USAGE: [Vsupport,Vpdf]=XrandomVariable.getPDF(varargin)
%
%  The method returns the vector of the support points (Vsupport) and the vector
%  of values of the pdf (Vpdf).
%
%  Valid input arguments: Nsamples, Nbins, Lanalytical
%
%  See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/getPDF@RandomVariable
%
% $Copyright~1993-2013,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$

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


%% Set default values
Nsamples=10000;
Nbins=100;
Lanalytical=true;

% Process input arguments
OpenCossan.validateCossanInputs(varargin{:});

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'nsamples'
            Nsamples=varargin{k+1};
        case 'nbins'
            Nbins=varargin{k+1};
        case 'lanalytical'
            Lanalytical=varargin{k+1};
        case 'vsupport'
            Vsupport=varargin{k+1};
            Nbins=length(Vsupport);
        otherwise
            error('openCOSSAN:RandomVariable:getPDF',...
                'PropertyName %s is not a valid input argument',varargin{k});
    end
end

%%  Compute support points
if ~exist('Vsupport','var')
    %Try to compute the pdf and support analytically
    Vcdf=0:1/Nbins:1;
    
    Vsupport=Xobj.cdf2physical(Vcdf);
    % Remove +Inf / -Inf
    Vsupport=Vsupport(~isinf(Vsupport));    
    
    % Rescaling support points
    switch lower(Xobj.Sdistribution)
        case {'binomial','negative binomial','hypergeometric','poisson','geometric'}
            Vsupport=Vsupport(1):Vsupport(end);
        otherwise
            Vsupport=Vsupport(1):abs(Vsupport(end)-Vsupport(1))/Nbins:Vsupport(end);
    end
    
end

%% Evaluate PDF
if ~Lanalytical
    Vsamples=Xobj.sample('Nsamples',Nsamples);
    [Vpdf, Vsupport] = hist(Vsamples,Nbins);
    
    delta=Vsupport(2)-Vsupport(1);
    % Normalize the pdf
    Vpdf=Vpdf/(Nsamples*delta);
else
    Vpdf = Xobj.evalpdf(Vsupport);
end


