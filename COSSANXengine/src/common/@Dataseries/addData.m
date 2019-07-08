function Xobj = addData(Xobj,varargin)
%ADDDATA add new data points to a dataseries object
%
%  Xds = addData(Xds,PropertyName, PropertyValue, ...) add new data points to a
%  Dataseries object.
%
%   MANDATORY ARGUMENTS
%   - Mcoord: vector with the coordinate of the points to be added
%   - Vdata: matrix with the data points to be added to the Dataseries
%            object
%
%   EXAMPLES
%   Xds = addData(Xds,'Mcoord',[5 6 7],'Vdata',[1.1 1.2 1.3])
%
% See also: https://cossan.co.uk/wiki/index.php/addData@Dataseries
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
% assert(size(Xobj,2)==1,'openCOSSAN:Dataseries:addData', ...
%     'addData method can only be applied to a single Dataseries object or to a Dataseries array');

%% Argument Check
OpenCossan.validateCossanInputs(varargin{:})
Mcoord=[];
%% Process input options
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'mcoord','vindex'}
            Mcoord = varargin{k+1};
        case {'vdata'}
            Mdata = varargin{k+1};
        case {'mdata'}
            Mdata = varargin{k+1};
        case {'csamples'}
            for n=1:length(varargin{k+1})
                Xobj(:,n)=Xobj(:,n).addData('Mdata',varargin{k+1}{n});
            end
        otherwise
            error('openCOSSAN:Dataseries:addData', ...
                ['PropertyName:  ' varargin{k} ' not available.'])
    end
end

assert(logical(exist('Mdata','var')),'openCOSSAN:Dataseries:addData:noData', ...
            'No data provided! \n Pass your data using the PropertyField Mdata or Vdata.');
        
%% Add data to a single Dataseries only
if size(Xobj,2)>1
    
    %% TODO
    % Add check on the number of samples of each dataseries   
    
else
    if isempty(Mcoord)
        Mcoord = 1:length(Mdata(1,:));
    else
        assert(size(Mcoord,2) == size(Mdata,2),...
            'openCOSSAN:Dataseries:addData',['The no. of columns of Mcoord and of Mdata to be added are not compatible.\n'...
            ' no. of columns of Mcoord: ' num2str(size(Mcoord,2))...
            '\n no. of columns of Vdata : ' num2str(size(Mdata,2))])
        
    end
    
    if ~isempty(Xobj(1).Xcoord.Mcoord)
        assert(size(Mcoord,1)== size(Xobj(1).Xcoord.Mcoord,1),...
            'openCOSSAN:Dataseries:addData', ...
                'The size of Mcoord to be added is not consistent with Xcoord present in the object.');
        Xobj(1).Xcoord.Mcoord=[Xobj(1).Xcoord.Mcoord, Mcoord];
    else
        Xobj(1).Xcoord.Mcoord=Mcoord;
    end
    
    for n = 1:size(Xobj,1)
        Xobj(n).Vdata=[Xobj(n).Vdata, Mdata(n,:)];
    end
end
