function Xobj=checkDistribution(Xobj)   
% Private function of RandomVariable
%
%  See Also: http://cossan.co.uk/wiki/index.php/@RandomVariable
%
% $Copyright~1993-2020,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% Author: Edoardo Patelli and Pierre Beaurepiere
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

assert(~isempty(Xobj.Sdistribution), ...
    'openCOSSAN:RandomVariable:noDefinedDistribution', ...
    'Distribution name must be defined');

%% Compute the missing values if possible
    switch lower(Xobj.Sdistribution)
        case {'ln','lognormal'}
            Xobj=lognormal(Xobj);
         case {'norm','normal'}
             Xobj=normal(Xobj);
        case {'exp','exponential'}
            Xobj=exponential(Xobj);
        case {'uni','uniform'}
            Xobj=uniform(Xobj);
        case {'rayleigh'}
            Xobj=rayleigh(Xobj);
        case {'small-i','sml','small1'}
            Xobj=small_I(Xobj);
        case {'large-i','gumbel','lar','gumbel-i','gumbeli','gumbel-max'}
            Xobj=large_I(Xobj);
        case {'large-ii','frechet'}
            Xobj=large_II(Xobj);
        case {'weibull'}
            Xobj=weibull(Xobj);
        case {'gp','generalizedpareto'}
            Xobj=generalizedPareto(Xobj);
        case {'uniform discrete','unid','uniformdiscrete'}
            Xobj=uniformdiscrete(Xobj);
        case {'student','t'}
            Xobj=student(Xobj);
        case {'gamma'}
            Xobj=gammaDistribution(Xobj);
        case {'chi2'}
            Xobj=chi2(Xobj);
        case {'normt','truncnormal','normal truncated','truncated normal'}
            Xobj=normt(Xobj);
        case {'f','fisher-snedecor'}
            Xobj=fisherSnedecor(Xobj);
        case {'beta'}
            Xobj=betaDistribution(Xobj);
        case {'logistic'}
            Xobj=logistic(Xobj);
        case {'poisson'}
            Xobj=poisson(Xobj);
        case {'binomial'}
            Xobj=binomial(Xobj);
        case {'geometric'}
            Xobj=geometric(Xobj);
        case {'hypergeometric'}
            Xobj=hypergeometric(Xobj);
        case {'negative binomial','negativebinomial'}
            Xobj=negativeBinomial(Xobj);            
        otherwise
            error('openCOSSAN:RandomVariable:noSupportedDistribution', ...
                'distribution type %s not available.\n Please check the documentation for a list of supported distributions.',Xobj.Sdistribution );
    end
    
end
