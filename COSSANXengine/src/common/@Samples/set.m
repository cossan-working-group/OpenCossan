function Xs = set(Xs,varargin)
%SET Set field(s) of an object of the class Samples
%
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
warning('openCOSSAN:Samples:set',...
    ['The method set with PropertyName/PropertyValue pairs is a living fossile from the "old Matlab objects" COSSAN.\n'...
    'You should set the property you want by calling it directly.\n'...
    'Please change your code, this method will be removed soon!'])

%%  Argument Check
OpenCossan.validateCossanInputs(varargin{:})

%% 2.   Define some values
Nrv     = length(Xs.CnamesRandomVariable);    %number of random variables

%% 3.   Process arguments passed by the user
for k=1:2:length(varargin)
    switch lower(varargin{k}),
        %3.1.   Samples in physical space
        case {'msamples','mx'},
            Xs.MsamplesPhysicalSpace = varargin{k+1};
            %3.2.   Samples in standard normal space
        case {'msamples_sns','mu'},
            Xs.MsamplesStandardNormalSpace = varargin{k+1};
            %3.3.   Samples in physical space including names
        case {'tsamples'},
            Xs.Tsamples = varargin{k+1};
            %3.4.   Samples in standard normal space including names
        case {'tsamples_sns'},
            error('This set property does not make any sense!!!')
            %3.5.   Case of weights
        case {'vweights'}
            Xs.Vweights=varargin{k+1};
        case {'msamplesdoedesignvariables'}
            Xs.MdoeDesignVariables=varargin{k+1};
        case {'cnamesdesignvariable','cnamesdesignvariables'}
            Xs.CnamesDesignVariables = varargin{k+1};
            %3.6.   Other cases
        otherwise
            error('openCOSSAN:Samples:set',['argument ' varargin{k} ' has been ignored']);
    end
end

return