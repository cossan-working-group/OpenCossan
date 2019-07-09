function [ varargout ] = subsrefParens( Xobj,Tsubstruct )
% subsrefParens
% private method to do subsref when the first sub is a parentesys.
% If no subscripting follows, return the subarray.  Only dot subscripting
% may follow.
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

rows = Tsubstruct(1).subs{1};

if numel(Tsubstruct(1).subs) == 1
        XobjOut=Xobj(:,rows);
        
%         switch fieldName
%             case{'Vdata'}
%                 XobjOut.Mdata=XobjOut.Mdata(rows,:);   
%             otherwise
%                 
%         end
          

elseif numel(Tsubstruct(1).subs) == 2
    colums = Tsubstruct(1).subs{2};
    XobjOut=Xobj(:,colums);
    for icol = 1:size(XobjOut,2)
        XobjOut(icol).Mdata=XobjOut(icol).Mdata(rows,:); 
    end
else
    error('Write something')
end

% if isscalar(Tsubstruct) && nargout > 1
%     % Simple parenthesis indexing can only return a single thing.
%     error('OpenCossan:Dataseries:subsref','Too many outputs.');
% end
% 
% % This case will always return a Dataseries matrix
% XobjOut = Dataseries;
% XobjOut.Sdescription = Xobj.Sdescription;
% % create a Dataseries sub-matrix out of the selected indices
% 
% if ischar(rows) && strcmpi(rows,':')
%     % convert : for rows
%     rows = 1:size(Xobj,1);
% end
% cols = Tsubstruct(1).subs{2};
% if ischar(cols) && strcmpi(cols,':')
%     cols = 1:size(Xobj,2);
% end
% if ~isempty(Xobj.CSindexName)
%     XobjOut.CSindexName = Xobj.CSindexName(cols);
% end
% if ~isempty(Xobj.CSindexUnit)
%     XobjOut.CSindexUnit = Xobj.CSindexUnit(cols);
% end
% XobjOut.CMcoord = Xobj.CMcoord(cols);
% XobjOut.CVdata = Xobj.CVdata(rows,cols);

if isscalar(Tsubstruct)
    % If there's no additional subscripting, return the subarray.
    varargout{1} = XobjOut;
else
    switch Tsubstruct(2).type
        case {'()','{}'}
            % this is the same error thrown by matlab Dataset...
            error('OpenCossan:Dataseries:subsref',...
                '()-indexing must appear last in an index expression.')
        case '.'
            [varargout{1:nargout}] = subsrefDot(XobjOut,Tsubstruct(2:end));
    end
end

end

