function [XsamplesOut, Xdataseries] = sample(Xobj,varargin)
%SAMPLE Generates samples for the specified random process
%  SAMPLE(SP1,varargin)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Sample@StochasticProcess
%
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
% Author: Barbara Goller
% Revised by: Edoado Patelli 2014
% Other contributors: Marco de Angelis, Fabrizio Scozzese
%
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

import opencossan.common.Dataseries
import opencossan.common.Samples

%% Defaul values
CSname={inputname(1)};

%% Argument Check
OpenCossan.validateCossanInputs(varargin{:})
% Process inputs
for k=1:2:length(varargin),
    switch lower(varargin{k})
        case {'nsamples'}
            nsamples = varargin{k+1};
        case {'sname'}
            CSname = varargin(k+1);
        case {'csname'}
            CSname = varargin{k+1};
        otherwise
            error('openCOSSAN:StochasticProcess:sample',...
                'Property name %s not allowed', varargin{k} );
    end
end

switch lower(Xobj.Sdistribution)
    case {'normal'}
        if isempty(Xobj.McovarianceEigenvectors) || ...
                isempty(Xobj.VcovarianceEigenvalues)
            error('openCOSSAN:StochasticProcess:sample','No KL-terms determined');
        end
        Ncoord = size(Xobj.McovarianceEigenvectors,1);
        NKL_terms = size(Xobj.McovarianceEigenvectors,2);
        MX = zeros(nsamples,Ncoord);
        MeigvecTimesSqrteigval = Xobj.McovarianceEigenvectors.*...
            repmat(sqrt(Xobj.VcovarianceEigenvalues)',Ncoord,1);
        for isim = 1:nsamples
            Vrand = randn(1,NKL_terms);
            MX(isim,:) = Xobj.Vmean +...
                sum(repmat(Vrand,Ncoord,1).*MeigvecTimesSqrteigval,2)';
        end
        
    case {'whitenoise'}
        if ~isempty(Xobj.SearthquakeModel)
            switch lower(Xobj.SearthquakeModel)
                case 'atkinsonsilva'
                    Xinput_AS_GM = Xobj.CXatkinsonSilva{1};
                    Xmio_AS_GM = Xobj.CXatkinsonSilva{2};
                    Xsmpl=Xinput_AS_GM.sample('Nsamples',nsamples);
                    XsamplesOut=run(Xmio_AS_GM,Xsmpl);
                    Xdataseries = XsamplesOut.TableValues.ground_acc;
                    MX = Xdataseries.Vdata;
                case 'shinozuka'
            end
        else
            MX = randn(nsamples,length(Xobj.Mcoord));
        end
    otherwise
        error('openCOSSAN:StochasticProcess:sample',...
            'Distribution %s not yet implemented', Xobj.Sdistribution);
end
Xdataseries=Dataseries('Mdata',MX,...
    'Mcoord',Xobj.Mcoord,...
    'Sdescription','Samples from stochastic process',...
    'CSindexName',Xobj.CScoordinateNames,...
    'CSindexUnit',Xobj.CScoordinateUnits); % comma separated units
XsamplesOut = Samples('XStochasticProcess',Xobj,...
    'Xdataseries',Xdataseries,'CnamesStochasticProcess',CSname);

