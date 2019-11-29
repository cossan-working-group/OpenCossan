function Cout = getDataseries(Xobj,varargin)
%getDataseries Retrieve the Dataseries objects present in the SimulationData Object
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/getDataseries@SimulationData
%
% $Copyright~1983-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo Patelli$

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
OpenCossan.validateCossanInputs(varargin{:})

% Get Variable names. If no input is given, all the Dataseries are returned 
Cnames=Xobj.Cnames;

for k=1:2:nargin-1,
    switch lower(varargin{k})
        case 'sname'
            %check input
            Cnames = varargin(k+1);
        case {'cnames','csnames'}
            %check input
            Cnames = varargin{k+1};
        otherwise
            error('openCOSSAN:SimulationData:getDataseries', ...
                'PropertyName %s is not allowed ', varargin{k})
    end
end

%% parse all the names passed
assert(all(ismember(Cnames,Xobj.CnamesDataseries)),...
    'openCOSSAN:SimulationData:getDataseries', ...
    'Variable(s) requested is not a Dataseries available in the SimulationData object !\n Required variables: %s\nAvailable variables: %s',...
    sprintf('"%s" ',Cnames{:}),sprintf('"%s" ',Xobj.CnamesDataseries{:}))

Cdataseries=cell(Xobj.Nsamples,length(Cnames));
n=length(Cnames);
while n>0
    if all(cellfun(@(x) isa(x,'Dataseries')||isnan(x), {Xobj.Tvalues.(Cnames{n})})) 
        % if all the entries in the field of the structure are Dataseries
        % or NaN (failed simulation), put them in a cell array
        Cdataseries(:,n)={Xobj.Tvalues.(Cnames{n})}';
    else
        % it is just a number, skip the entry and give a warning
        warning('openCOSSAN:SimulationData:getDataseries', ...
            'The variable %s is not a Dataseries',Cnames{n})
        Cnames(n)=[];
        Cdataseries(:,n)=[];
    end
    n = n-1;
end

%% Extract the Dataseries objects from Tvalues
Cout = cell(1,length(Cnames));

% check for NaN to see if any simulation failed
Lfailed = cellfun(@isnan,Cdataseries);
if all(Lfailed(:))
    % don't assemble a matrix of Dataseries, but return the cell-array.
    error('openCOSSAN:SimulationData:getDataseries',...
        'All simulations failed. Cannot export a matrix of Dataseries.')
end

[fail_row,fail_col] = find(Lfailed); % convert logic matrix to (i,j) pairs
for n=1:length(Cnames)
    % if some of the simulation for this output has failed, convert NaN
    % to a Dataseries of NaN
    if any(fail_col==n)
        % get the first sample where the simulation was successfull to
        % retrieve the additional properties of the Dataseries
        success_row = find(~Lfailed(:,n)); success_row = success_row(1);
        % ebsure the vector with the failed simulation number is a row
        % vector, otherwise the for loop will fail
        Vfail = find(fail_col==n);
        if size(Vfail,1)~=1, Vfail = Vfail'; end 
        for ifail = Vfail
            Cdataseries{fail_row(ifail),n} = Dataseries('Sdescription',Cdataseries{success_row,n}.Sdescription,...
                'CSindexName',Cdataseries{success_row,n}.Xcoord.CSindexName,...
                'CSindexUnit',Cdataseries{success_row,n}.Xcoord.CSindexUnit,...
                'Mcoord',Cdataseries{success_row,n}.Mcoord,...
                'Vdata',nan(1,size(Cdataseries{success_row,n}.Mcoord,2)));
        end
    end
    
    % check that the sizes are constant
    Msizes = cellfun(@(x)size(x.Mcoord),Cdataseries(:,n),'UniformOutput',false);
    Msizes = cat(1,Msizes{:});
    if all(Msizes==repmat(Msizes(1,:),size(Msizes,1),1))
        % if Mcoord is the same for all the entries, convert the cell array
        % into a vector of Dataseries
        Cout{n}=cat(1,Cdataseries{:,n});
    else
        % export the Dataseries objects contained in the column to a cell 
        % array since they cannot be converted to a single dataseries
        % objects
        warning('openCOSSAN:SimulationData:getDataseries',...
            'Cannot export output %s as a Dataseries matrix. The objects don''t have constant data length.',Cnames{n})
        Cout{n} = Cdataseries(:,n);
    end
    
end

if all(cellfun(@(x) isa(x,'Dataseries'),Cout))
    % if it was possible to create a matrix of Dataseries for each entry in
    % the SimulationData, convert all the columns intoto a single
    % Dataseries matrix
    Cout = horzcat(Cout{1,:});
end

end
