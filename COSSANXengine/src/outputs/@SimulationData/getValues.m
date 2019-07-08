function [Mout,varargout] = getValues(Xobj,varargin)
%getValues Retrieve the values of a variable present in the
%           SimulationData Object
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/getValues@SimulationData
%
% $Copyright~1993-2015,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$

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
%% Validate input arguments

if OpenCossan.getChecks
    OpenCossan.validateCossanInputs(varargin{:})
end

if Xobj.Nsamples>1e5
    warning('openCOSSAN:outputs:SimulationData:getValues',...
        'Please use Batches... this operation may become very slow')
end

Vsize=[];
Sname='';
Cnames=Xobj.Cnames;

for k=1:2:nargin-1,
    switch lower(varargin{k})
        case 'sname'
            %check input
            Sname = varargin{k+1};
        case {'cnames','csnames'}
            %check input
            Cnames = varargin{k+1};
        otherwise
            error('openCOSSAN:outputs:SimulationData:getValues', ...
                'PropertyName %s is not valid',varargin{k})
    end
end

if isempty(Sname)
    assert(all(ismember(Cnames,Xobj.Cnames)),...
        'openCOSSAN:outputs:SimulationData:getValues', ...
        'Variable(s) not present in the SimulationData object!\n Required variables: %s\nAvailable variables: %s',...
        sprintf('"%s" ',Cnames{:}),sprintf('"%s" ',Xobj.Cnames{:}))
    
    Vfield=ismember(Xobj.Cnames,Cnames);
    
    Nout=length(Cnames);
    
    %% Check if the values are also store in a Matrix format
    if isempty(Xobj.Mvalues)
        %% Convert structure to cell
        Cout=struct2cell(Xobj.Tvalues);
        % removed unrequested values
        Cout(~Vfield,:)=[];
        % removed unrequested names
        CnamesKept = Xobj.Cnames;
        CnamesKept(~Vfield,:)=[];
        
        % determine in which order the names have been requested
        Vorder = zeros(size(Cnames));
        for idx = 1:Nout
            Vorder(idx) = find(strcmp(CnamesKept,Cnames{idx}));
        end
        % reorder Cout to the correct order (note: the values are stored on
        % ROWS)
        
        Cout = Cout(Vorder,:);
        
        Vindex=false(Nout,1);
        for n=1:Nout
            if isa(Cout{n,1},'Dataseries')
                warning('openCOSSAN:SimulationData:getValues', ...
                    'Variable %s is a Dataseries!\nPlease used the method getDataseries ',Xobj.Cnames{Vorder(n)})
                Vindex(n)=true;
            end
        end
        
        Cout(Vindex,:)=[];
        
        if ~isempty(Cout)
            Vsize=size(Cout{1});
            
            if ~isvector(Cout{1})
                for n=1:length(Cout)
                    Cout{n}=Cout{n}(:);
                end
            end
            %Mout=myCell2Mat(Cout)';
            Mout=cell2mat(Cout)';
            
            
        else
            Mout=[];
        end
        
        
    else
        % determine in which order the names have been requested
        Vorder = zeros(size(Cnames));
        for idx = 1:length(Cnames)
            Vorder(idx) = find(strcmpi(Xobj.Cnames,Cnames{idx}));
        end
        Mout=Xobj.Mvalues(:,Vorder);
    end
    
    varargout{1}=Vsize;
else
    if OpenCossan.getChecks
    assert(all(ismember(Sname,Xobj.Cnames)),...
        'openCOSSAN:outputs:SimulationData:getValues', ...
        'Variable(s) not present in the SimulationData object!\n Required variables: %s\nAvailable variables: %s',...
        Sname,sprintf('"%s" ',Xobj.Cnames{:}))
    end
    

    if isempty(Xobj.Mvalues)
        Mout=cat(1,Xobj.Tvalues.(Sname));
    else
        Vfield=ismember(Xobj.Cnames,Sname);
        Mout = Xobj.Mvalues(:,Vfield);
    end
    
end