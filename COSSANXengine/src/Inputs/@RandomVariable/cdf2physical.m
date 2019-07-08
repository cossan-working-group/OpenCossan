function VX = cdf2physical(Xrv,VU)
%CDF2PHYSICAL Maps the the specified RandomVariable to the physical space
%when the value(s) of the cdf is provided
%
%  MANDATORY ARGUMENTS:
%    - Xrv: the RandomVariable object
%    - VU: array containing the values of the cdf to be
%          mapped in the physical space
%
%  OUTPUT ARGUMENTS
%    - VX: array containing the values mapped in the physical space
%
%  Usage: VX = cdf2physical(Xrv,VU)
%
%  See also: RandomVariable, physical2cdf
%
% See also: https://cossan.co.uk/wiki/index.php/@RandomVariable
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

assert(nargin==2,'OpenCossan:RandomVariable:cdf2physical:wrongArgumentNumber',...
    'This method requires 2 inputs. Provided inputs %n',nargin)

%% argument check (0 <= cdf <=1)
res  =(VU <0) | (VU >1);

assert(sum(res)== 0,'openCOSSAN:RandomVariable:cdf2physical:wrongCDF',...
        'the value of the cdf has to be in the range [0 1]');

switch lower(Xrv.Sdistribution)
    case {'ln','lognormal'}
        VX = logninv(VU,Xrv.Cpar{1,2},Xrv.Cpar{2,2})+Xrv.shift;
    case {'norm','normal'}
        VX = norminv(VU, Xrv.mean, Xrv.std );
    case {'exp','exponential'}
        VX = expinv(VU,Xrv.Cpar{1,2})+Xrv.Cpar{2,2};
    case {'uni','uniform'}
        VX = unifinv(VU,Xrv.lowerBound,Xrv.upperBound);
    case {'rayleigh'}
        VX = raylinv(VU,Xrv.Cpar{1,2})+Xrv.shift;
    case {'small-i','sml','small1'}
        small_alpha = pi/(sqrt(6)*Xrv.std);
        small_u = Xrv.mean+0.5772156/small_alpha;
        VX = small_u+log(-log(1-VU))/small_alpha+Xrv.shift;
    case {'large-i','lar','gumbel-i','gumbeli'}
        large_alpha = pi/(sqrt(6)*Xrv.std);
        large_u = Xrv.mean-0.5772156/large_alpha;
        VX = large_u-log(-log(VU))/large_alpha+Xrv.shift;
    case {'large-ii','frechet'}
        VX = Xrv.shift + Xrv.Cpar{2,2}*(-log(VU)).^(-1/Xrv.Cpar{1,2});
    case {'student','t'}
        VX =tinv(VU,Xrv.Cpar{1,2})+Xrv.shift;
    case {'gamma'}
        VX =gaminv(VU,Xrv.Cpar{1,2},Xrv.Cpar{2,2})+Xrv.shift;
    case {'f'}
        VX =finv(VU,Xrv.Cpar{1,2},Xrv.Cpar{2,2})+Xrv.shift;
    case {'beta'}
        VX =betainv(VU,Xrv.Cpar{1,2},Xrv.Cpar{2,2})+Xrv.shift;
    case {'logistic'}
        VX = Xrv.Cpar{1,2} + Xrv.Cpar{2,2} * log(VU./(1-VU))+ Xrv.shift;
    case {'generalizedpareto'}
        VX =gpinv(VU,Xrv.Cpar{1,2},Xrv.Cpar{2,2},Xrv.Cpar{3,2})+Xrv.shift;
    case {'chi2'}
        VX =chi2inv(VU,Xrv.Cpar{1,2})+Xrv.shift;
    case {'weibull'}
        VX =wblinv(VU,Xrv.Cpar{1,2},Xrv.Cpar{2,2})+Xrv.shift;
    case {'normt','truncnormal','normal truncated','truncated normal'}
        m=Xrv.Cpar{1,2};
        s=Xrv.Cpar{2,2};
        a=Xrv.lowerBound;
        b=Xrv.upperBound;
        %invert CDF of normal truncated distribution
        clft=normcdf(a,m,s);
        crgt=normcdf(b,m,s);
        
        VX = norminv((crgt - clft) * VU + clft, m, s);
    case {'unid'}
        VX = Xrv.lowerBound + icdf('unid', VU,Xrv.upperBound-Xrv.lowerBound);
    case {'poisson','geometric'}
        VX = icdf(Xrv.Sdistribution, VU,Xrv.Cpar{1,2})+Xrv.shift;
    case {'binomial','negative binomial'}
        VX = icdf(Xrv.Sdistribution, VU,Xrv.Cpar{1,2},Xrv.Cpar{2,2})+Xrv.shift;
    case {'hypergeometric'}
        VX = icdf(Xrv.Sdistribution, VU(VU>0),Xrv.Cpar{1,2},Xrv.Cpar{2,2},Xrv.Cpar{3,2})+Xrv.shift;
    otherwise
        error('openCOSSAN:RandomVariable:cdf2physical:wrongDistribution',...
            ['Distribution ' Trv.Sdistribution ' not implemented,yet']);
end
