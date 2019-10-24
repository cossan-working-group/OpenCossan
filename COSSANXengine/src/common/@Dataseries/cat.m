function Xobj = cat(Ndim,varargin)
%CAT Concatenate Dataseries arrays.
%   CAT(DIM,A,B) concatenates the Dataseries arrays A and B along
%   the dimension DIM.  
%   CAT(2,A,B) is the same as [A,B].
%   CAT(1,A,B) is the same as [A;B].
%
% See also: https://cossan.co.uk/wiki/index.php/cat@Dataseries
%
% Author: Matteo Broggi
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

assert(nargin>=2,'openCOSSAN:Dataseries:cat',...
    'Not enough input arguments')

assert(all(ismember(cellfun(@class,varargin,'UniformOutput',false),{'Dataseries'})),...
    'openCOSSAN:Dataseries:cat',...
    'Not all the inputs are of class Dataseries');

switch Ndim
    case 1
        % Concatenate matrices in rows (i.e. [XobjA;XobjB])
        % Check that all the arrays have the same number of colums
        Msizes=cellfun(@(x)size(x,2),varargin);
        assert(all(Msizes == Msizes(1)),'openCOSSAN:Dataseries:vertcat',...
            'CAT arguments dimensions are not consistent')
        % Check that all the arrays have the consistent Mcoord, SindexName,
        % SindexUnit
        for iargin = 1:length(varargin)-1
            Mcoord1 = varargin{iargin}.Mcoord;
            Mcoord2 = varargin{iargin+1}.Mcoord;
            CSindexName1 = varargin{iargin}.CSindexName;
            CSindexName2 = varargin{iargin+1}.CSindexName;
            CSindexUnit1 = varargin{iargin}.CSindexUnit;
            CSindexUnit2 = varargin{iargin+1}.CSindexUnit;
                assert(size(Mcoord1,2)==size(Mcoord2,2) &&...
                    isequal(Mcoord1,Mcoord2),...
                    'openCOSSAN:Dataseries:vertcat',...
                    'All the Dataseries array must have the same Mcoord')
%                 assert(strcmpi(CSindexName1,CSindexName2),...
%                     'openCOSSAN:Dataseries:vertcat',...
%                     'All the Dataseries array must have the same SindexName')
%                 assert(strcmpi(CSindexUnit1,CSindexUnit2),...
%                     'openCOSSAN:Dataseries:vertcat',...
%                     'All the Dataseries array must have the same SindexUnit')
        end
        % Create empty output arrey and concatenate the prperties of the
        % input arrays accordingly.
        Xobj = Dataseries;
        Xobj.CSindexName = varargin{1}.CSindexName;
        Xobj.CSindexUnit = varargin{1}.CSindexUnit;
        Xobj.Mcoord = varargin{1}.Mcoord;
        Xobj.Mdata = repmat(varargin{1}.Mdata,length(varargin),1);
        for iargin = 2:length(varargin)
            Xobj.Mdata(iargin,:) = varargin{iargin}.Mdata;
        end
    case 2
        % Concatenate matrices in columns (i.e. [XobjA,XobjB])
        % Check that all the Mdata in the objects have the same number of
        % rows
        Msizes=cellfun(@(x)size(x.Mdata,1),varargin);
        assert(all(Msizes == Msizes(1)),'openCOSSAN:Dataseries:vertcat',...
            'CAT arguments dimensions are not consistent')
        % Concatenate objects directly
        Xobj = builtin('horzcat',varargin{:});
    otherwise
        % no support for dataseries matrices of dimension higher than 2
        error('openCOSSAN:Dataseries:cat',...
            'No support for Dataseries matrices of dimension higher than 2.')
end

end

