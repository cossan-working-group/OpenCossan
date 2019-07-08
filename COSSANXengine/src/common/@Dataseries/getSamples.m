function XobjOut = getSamples(Xobj,Pindex)
%GETSAMPLES  get user selected samples from a Dataseries array
%
%  Xds=getSamples(Xds,Pindex) retrieve the samples from the Dataseries
%  object corresponding to the indeces  specified in Pindex
%
%  EXAMPLES:
%
%  Xds = getSamples(Xds,[2 7]) % returna a Dataseries containing the
%  samples no. 2 and 7 from the Dataseries object
%
% See also: https://cossan.co.uk/wiki/index.php/getSamples@Dataseries
%
% Author: Matteo Broggi, Edoardo Patelli
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

if (ischar(Pindex) && strcmp(Pindex,':'))
    Pindex = 1:Xobj(1).Nsamples;
elseif islogical(Pindex) % logical indexing
    assert((isrow(Pindex) || icolumn(Pindex)) && length(Pindex)<=Xobj(1).Nsamples,...
        'OpenCossan:Dataseries:getSamples','Index exceeds number of samples.')
elseif isnumeric(Pindex) % numerical indexing
    assert((isrow(Pindex) || icolumn(Pindex)) && max(Pindex)<=Xobj(1).Nsamples,...
        'OpenCossan:Dataseries:getSamples','Index exceeds number of samples.')
else
    error('OpenCossan:Dataseries:getSamples','Subscript indices must either be real positive integers or logicals.')
end

XobjOut = Xobj;
for icol=1:length(Xobj)
    XobjOut(icol).Mdata = Xobj(icol).Mdata(Pindex,:);
end

end