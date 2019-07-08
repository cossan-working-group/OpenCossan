function Xobj = addSamples(Xobj,varargin)
%ADDSAMPLES add new samples to a dataseries object
%
%  Xds = addSamples(Xds,PropertyName, PropertyValue, ...) add new samples
%  to a Dataseries object.
%
%
% See also: https://cossan.co.uk/wiki/index.php/addSamples@Dataseries
%
% Author: Matteo Broggi
% Revised by: Edoardo Patelli
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


%% Argument Check
OpenCossan.validateCossanInputs(varargin{:})

%% Process input options
for k=1:2:length(varargin)
    switch lower(varargin{k}),
        case {'vdata'}
            Mdata = varargin{k+1};
        case {'mdata'}
            Mdata = varargin{k+1};
        case {'csamples'}
            for n=1:length(varargin{k+1})
                Xobj(:,n)=Xobj(:,n).addData('Mdata',varargin{k+1}{n});
            end
        otherwise
            error('openCOSSAN:Dataseries:addData:wrongargument', ...
                'PropertyName %s not allowed. ',varargin{k})
    end
end


%% Add data to a single Dataseries only
assert(size(Xobj,2)==1,'openCOSSAN:Dataseries:addSamples:multipleDataseries',...
    strcat('It is not possible to add samples to a vector of Dataseries\n', ...
    'Samples can be added to a vector of Dataseries passing the samples as new dataseries'))
    
if ~exist('Mdata','var')
    error('openCOSSAN:Dataseries:addData', ...
        'No samples to be added are defined.');
end

if size(Xobj(1).Xcoord.Mcoord,2) ~= size(Mdata,2)
    error('openCOSSAN:Dataseries:addData',['The no. of columns of Mcoord and of Mdata to be added are not compatible.\n'...
        ' no. of columns of Mcoord: ' num2str(size(Mcoord,2))...
        '\n no. of columns of Vdata : ' num2str(size(Mdata,2))])
end

NsamplesAdd = size(Mdata,1);
NsamplesOriginal = size(Xobj,1);
for n = 1:NsamplesAdd
    Xobj(NsamplesOriginal+n) = Xobj(1);
    Xobj(NsamplesOriginal+n).Vdata = Mdata(n,:);
end
end
