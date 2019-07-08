function Xobj = add(Xobj,varargin)
%ADD This method adds a Response object to the extract object. 
%
%   Arguments:
%   ==========
%
%   MANDATORY ARGUMENTS:
%      - 'Xresponse' Response object to be added
%
%   OPTIONAL ARGUMENTS:
%   - Nposition: Specify the position of the Response object
%
%   EXAMPLES:
%   Usage:  Xe  =add(Xe,'Xresponse','Xresponse2','Nposition',2)
%
% See Also: https://cossan.co.uk/wiki/index.php/@Extractor
%
% $Copyright~2006-2018,~COSSAN~Working~Group$
% $Author: Edoardo Patelli$

% =====================================================================
% This file is part of OpenCossan.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% OpenCossan is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% OpenCossan is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================


%% 1. Processing Inputs

%% Processing Inputs
OpenCossan.validateCossanInputs(varargin{:});
for iopt=1:2:length(varargin)
    switch lower(varargin{iopt})
        case {'xresponse'}
            Xresponse = varargin{iopt+1};
        case {'nposition'}
            Nposition = varargin{iopt+1};
        otherwise
            warning('OpenCossan:Extractor:add:wrongOption',...
                ['Optional parameter ' varargin{iopt} ' not allowed']);
    end
end

assert(logical(exist('Xresponse','var')),...
        'OpenCossan:Extractor:add:NoResponseDefined',...
        'It is necessary to provide and object of type Response!')

assert(isa(Xresponse,'Response'),...
        'OpenCossan:Extractor:add:wrongObject',...
        ['It is necessary to provide and object of type Response!\n' ...
        'Provided object of class %s is not valid'],class(Xresponse))
    
% Check if the output is already present in the connector
assert(~ismember(Xresponse.Sname,Xobj.Coutputnames),...
        'OpenCossan:Extractor:add:ResponseAlreadyPresent',...
        ['Response %s is already available in the Extractor object.\n (%s)' ... 
        'List of response defined in the Extractor: %s'],Xresponse.Sname, ...
        sprintf(' "%s" ',Xobj.Coutputnames{:}))

    
if logical(exist('Nposition','var'))
    Xobj.Xresponse = [Xobj.Xresponse(1:Nposition-1) Xresponse Xobj.Xresponse(Nposition:end)];
else
    Xobj.Xresponse(end+1) = Xresponse;
end

end
