function Xobj = set(Xobj,varargin)
%SET Set properties of the RandomVariable object
%
% See also:
% https://cossan.co.uk/wiki/index.php/set@Parameter
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

OpenCossan.validateCossanInputs(varargin{:});

for k=1:2:length(varargin);
    switch lower(varargin{k})
        case {'std'}
            Xobj.std = (varargin{k+1});
            % Reset the parameter definition if the RandomVarible is
            % defined by means of std and mean
            Xobj.Cpar=cell(4,2);
            if strcmp(Xobj.Sdistribution,'UNIFORM')
                Xobj.upperBound=Inf;
                Xobj.lowerBound=-Inf;
            end
        case {'mean'}
            Xobj=shift(Xobj,varargin{k+1});
            % Reset the parameter definition if the RandomVarible is
            % defined by means of std and mean
            Xobj.Cpar=cell(4,2);
            if strcmp(Xobj.Sdistribution,'UNIFORM')
                Xobj.upperBound=Inf;
                Xobj.lowerBound=-Inf;
            end
        case {'sdescription'}
            Xobj.Sdescription=varargin{k+1};
        case {'sdistribution'}
            Xobj.Sdistribution=varargin{k+1};
        case {'variance'}
            % Reset the parameter definition if the RandomVarible is
            % defined by means of std and mean
            Xobj.Cpar=cell(4,2);
            Xobj.std = sqrt(varargin{k+1});
            if strcmp(Xobj.Sdistribution,'UNIFORM')
                Xobj.upperBound=Inf;
                Xobj.lowerBound=-Inf;
            end
        case {'parameter1','par1'}
            Xobj.Cpar{1,1}='par1';
            Xobj.Cpar{1,2}=varargin{k+1};
        case {'parameter2','par2'}
            Xobj.Cpar{2,1}='par2';
            Xobj.Cpar{2,2}=varargin{k+1};
        case {'parameter3','par3'}
            Xobj.Cpar{3,1}='par3';
            Xobj.Cpar{3,2}=varargin{k+1};
        case {'parameter4','par4'}
            Xobj.Cpar{4,1}='par4';
            Xobj.Cpar{4,2}=varargin{k+1};
        otherwise
            error('openCOSSAN:RandomVariable:set',...
                ['The field ''' varargin{k} ''' can not be changed with set']);
    end
end

% Reupdate the distribution 
Xobj=checkDistribution(Xobj);