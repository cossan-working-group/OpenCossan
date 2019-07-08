function Xobj = shift(Xobj,mean)
%SHIFT   Shift rv, by changing its mean
%
%  Usage: Xrv1 = shift(Xrv1,mean)
%   mean ... new mean value
%
% See also: https://cossan.co.uk/wiki/index.php/shift@RandomVariable
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

switch lower(Xobj.Sdistribution)
    case {'ln','lognormal'}
        Xobj.mean = mean;
        Xobj.Cpar{1,2} = log( Xobj.mean^2 / sqrt(Xobj.std^2 + Xobj.mean^2));
        Xobj.Cpar{2,2} = sqrt( log(Xobj.std^2 / Xobj.mean^2 + 1));
    case {'norm','normal'}
        Xobj.mean = mean;
    case {'exp','exponential'}
        Xobj.mean = mean;
        Xobj.Cpar{1,2} = Xobj.std;
        Xobj.Cpar{2,2} = Xobj.mean-Xobj.Cpar{1,2};
    case {'uni','uniform','uniform discrete','unid','uniformdiscrete'}
        Xobj.mean = mean;
        Xobj.lowerBound    = Xobj.mean-sqrt(3)*Xobj.std;
        Xobj.upperBound    = Xobj.mean+sqrt(3)*Xobj.std;
    case {'rayleigh'}
        error('openCOSSAN:rv',['Distribution ' Trv.Sdistribution ' not yet implemented']);
    case {'small-i','sml','small1'}
        error('openCOSSAN:rv',['Distribution ' Trv.Sdistribution ' not yet implemented']);
    case {'large-i','lar','gumbel-i','gumbeli','gumbel'}
        Xobj.mean = mean;
    case {'weibull'}
        Xobj.mean = mean;
        %         case {'uniform discrete','unid','uniformdiscrete'}
        %             error('openCOSSAN:rv',['Distribution ' Trv.Sdistribution ' not yet implemented']);
    case {'student','t'}
        error('openCOSSAN:rv',['Distribution ' Trv.Sdistribution ' not yet implemented']);
    case {'gamma'}
        error('openCOSSAN:rv',['Distribution ' Trv.Sdistribution ' not yet implemented']);
    case {'f','fisher'}
        error('openCOSSAN:rv',['Distribution ' Trv.Sdistribution ' not yet implemented']);
    case {'chi2'}
        error('openCOSSAN:rv',['Distribution ' Trv.Sdistribution ' not yet implemented']);
    otherwise
        error('openCOSSAN:rv',['Distribution ' Trv.Sdistribution ' not yet implemented']);
end







