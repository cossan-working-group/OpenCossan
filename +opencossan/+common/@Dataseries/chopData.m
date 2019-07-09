function Xobj = chopData(Xobj, idx)
%CHOPDATA  remove data from a Dataseries array
%
%  Xds=chopData(Xds,VchopData) eliminates the data points and the
%  coordinates from the Dataseries object corresponding to the indeces
%  specified in VchopData
%
%  EXAMPLES:
%
%  Xds = chopData(Xds,[2 7]) % removes the data point no. 2 and 7 from the
%  Dataseries object
%
% See also: https://cossan.co.uk/wiki/index.php/chopData@Dataseries
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
%% Object Check
assert(length(Xobj)==1,'OpenCossan:Dataseries:chopData',...
    'Cannot execute method chopData on an array of Dataseries. Call each element one by one.')

Ldestroy = false;
if (ischar(idx) && strcmp(idx,':'))
    Ldestroy = true;
elseif islogical(idx) % logical indexing
    assert((isrow(idx) || icolumn(idx)) && length(idx)<=Xobj.VdataLength,...
        'OpenCossan:Dataseries:chopData','Index exceeds data length.')
elseif isnumeric(idx) % numerical indexing
    assert((isrow(idx) || icolumn(idx)) && max(idx)<=Xobj.VdataLength,...
        'OpenCossan:Dataseries:chopData','Index exceeds data length.')
else
    error('OpenCossan:Dataseries:chopData','Subscript indices must either be real positive integers or logicals.')
end

if Ldestroy
    % if ":" was passed, remove Mcoord and MData completely. If the next
    % command was used, something strange happens (Mdata becomes an 8x0
    % and the size command fails afterwards)
    Xobj.Mdata = [];
    Xobj.Mcoord = [];
else
    % delete only the selected columns from the data
    Xobj.Mdata(:,idx) = [];
    Xobj.Mcoord(:,idx) = [];
end

end