function [ varargout ] = subsrefDot(Xobj,Tsubstruct)
% subsrefDot
% private method to do subsref when the first sub is a dot.
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


fieldName = Tsubstruct(1).subs;

switch fieldName
    case{'Vdata','Mdata'}
        Ctemp={Xobj.Mdata};
        
        if length(Tsubstruct)==1
            varargout = Ctemp;
        else
            switch(Tsubstruct(2).type)
                case '()'
                    varargout =cellfun(@(x) subsref(x,Tsubstruct(2)),Ctemp, 'UniformOutput', false);
                otherwise
                    error('Not possible')
                    
            end
        end
        
        
    case{'Sdescription'}
        varargout={Xobj.Sdescription};
    case{'Mcoord'}
        Ctemp={Xobj.Mcoord};
        if length(Tsubstruct)==1
            varargout = Ctemp;
        else
            switch(Tsubstruct(2).type)
                case '()'
                    varargout =cellfun(@(x) subsref(x,Tsubstruct(2)),Ctemp, 'UniformOutput', false);
                otherwise
                    error('Not possible')                    
            end
        end
    case {'SindexUnit','SindexName'}
        % read only the first element of the corresponding cell array
        fieldName = ['C' fieldName];
        Cnames = Xobj.(fieldName);
        if length(Cnames)>1
            % give a warning if more than one dimension
            warning('OpenCossan:Dataseries:subsref',['The coordinates of the ' ...
                'Dataseries object have dimension ' num2str(length(Cnames)) '. '...
                'Only the first entry ' fieldName ' has been returned.\n' ....
                'Call the property ' fieldName ' to retrieve all the values.'])
        end
        varargout=Cnames(1);
    case properties(Xobj)
        varargout={Xobj.(fieldName)};
    case methods(Xobj)
        if length(Tsubstruct)==1
            % the method has been called with no inputs.
            varargout={Xobj.(fieldName)};
        else
            varargout={Xobj.(fieldName)(Tsubstruct(end).subs{:})};
        end
    otherwise
        error(['No appropriate method, property, or field '...
            Tsubstruct(1).subs ' for class Dataseries.'])
end



end

