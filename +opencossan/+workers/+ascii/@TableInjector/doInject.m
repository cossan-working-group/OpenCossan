function doInject(Xobj,Tinput)
%DOINJECT This method write a the input values provided in the structures
%Tinput in a Table format.  
% 
% A new file is created or the only one is overwritten. 
%
%
%       '-mat'                        Binary MAT-file format (default).
%       '-ascii'                      8-digit ASCII format.
%       '-ascii', '-tabs'             Tab-delimited 8-digit ASCII format.
%       '-ascii', '-double'           16-digit ASCII format.
%       '-ascii', '-double', '-tabs'  Tab-delimited 16-digit ASCII format.
%%

% Copyright~1993-2013,~COSSAN~Working~Group
%
% Author: Matteo Broggi and Edoardo Patelli
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

SfullName=fullfile(Xobj.Sworkingdirectory,Xobj.Srelativepath,Xobj.Sfile);

OpenCossan.cossanDisp(['[COSSAN-X.TableIdentifier.doInject] Filename:' SfullName],4);

CavailableInputs=fieldnames(Tinput);
assert(all(ismember(Xobj.Cinputnames,CavailableInputs)),...
    'openCOSSAN:TableIdentifier.doInject:checkInput', ...
    'Variable(s) not present in the input structure!\n Required variables: %s\nAvailable variables: %s',...
    sprintf('"%s" ',Xobj.Cinputnames{:}),sprintf('"%s" ',CavailableInputs{:}))


Mcoord = [];
Mdata=[];
for n=1:Xobj.Nvariable
    % get the value to be injected
    switch class(Tinput.(Xobj.Cinputnames{n}))
        case 'Dataseries'
            assert(Xobj.Nvariable==1,'openCOSSAN:TableIdentifier.doInject:DataseriesInjection',...
                'Only a single Dataseries can be injected in a TableInjector!')
            % if an index is specified, assign to value the content of
            % the property Mdata of the Dataseries object at the
            % specified index
            Mcoord = Tinput.(Xobj.Cinputnames{n}).Mcoord;
            Vdata = Tinput.(Xobj.Cinputnames{n}).Vdata;
            if Xobj.LinjectCoordinates
                Mdata = [Mcoord; Vdata];
            else
                Mdata = Vdata;
            end
            if ~isempty(Xobj.Vindices)
                Mdata = Mdata(:,Xobj.Vindices); 
            end
        case {'double','single','logical'}
            Mdata = [Mdata Tinput.(Xobj.Cinputnames{n})]; %#ok<AGROW>
        otherwise
            error('openCOSSAN:TableIdentifier:doInject:wrongClass',['It is not possible '...
                'to inject values from object of class %s'], ...
                class(Tinput.(Xobj.Cinputnames{n})))
    end
end


% Vfield=ismember(Xobj.Cinputnames,CavailableInputs);
% %% Convert structure to cell
% Cout=struct2cell(Tvalues);
% % removed unrequested values
% Cout(~Vfield,:)=[];
% % removed unrequested names
% Mout=cell2mat(Cout)'; %#ok<NASGU>

switch lower(Xobj.Stype)
    case {'matlab8'}
        save(SfullName,'Mdata', '-ascii', '-tabs');
    case {'matlab16'}
        save(SfullName,'Mdata', '-ascii','-double','-tabs');
    case {'nastran16_table'}
        if ~isempty(Mcoord)
            % you are injecting a Dataseries
            assert(size(Mcoord,1)==1,...
                'openCOSSAN:TableIdentifier:doInject:wrongDataSeriesFormat',...
                'Cannot inject a Dataseries with coordinates dimensions greater than 1.')
        end
        
        Vdatatime = Mdata(:);
        ncols = 4;
        nrows = floor(length(Vdatatime)/ncols);
        nremaining = rem(length(Vdatatime),ncols);
        Mvalueinject = reshape(Vdatatime(1:end-nremaining),ncols,nrows);
        
        Nfid = fopen(SfullName,'w');
        fprintf(Nfid, '*      %16.7e%16.7e%16.7e%16.7e\n', Mvalueinject);
        if nremaining ~= 0
            fprintf(Nfid, '*      %16.7e%16.7e   ENDT\n', Vdatatime(end-1:end));
        else
            fprintf(Nfid, '*         ENDT\n');
        end
        fclose(Nfid);
        
    case {'abaqus_table'}
        if ~isempty(Mcoord)
            % you are injecting a Dataseries
            assert(size(Mcoord,1)==1,...
                'openCOSSAN:TableIdentifier:doInject:wrongDataSeriesFormat',...
                'Cannot inject a Dataseries with coordinates dimensions greater than 1.')
        end
        
        Vdatatime = Mdata(:);
        ncols = 8;
        nrows = floor(length(Vdatatime)/ncols);
        nremaining = rem(length(Vdatatime),ncols);
        Mvalueinject = reshape(Vdatatime(1:end-nremaining),ncols,nrows);
        
        Nfid = fopen(SfullName,'w');
        fprintf(Nfid, '%16.7e,%16.7e,%16.7e,%16.7e,%16.7e,%16.7e,%16.7e,%16.7e,\n', Mvalueinject);
        if nremaining == 2
            fprintf(Nfid, '%16.7e,%16.7e,', Vdatatime(end-1:end));
        end
        if nremaining == 4
            fprintf(Nfid, '%16.7e,%16.7e,%16.7e,%16.7e,', Vdatatime(end-3:end));
        end
        if nremaining == 6
            fprintf(Nfid, '%16.7e,%16.7e,%16.7e,%16.7e,%16.7e,%16.7e,', Vdatatime(end-5:end));
        end
        fclose(Nfid);
        
    case {'userdefined'}
        error('TO BE IMPLEMENTED')
    otherwise
        error('openCOSSAN:TableInjector:doInject',...
            'Injector Type (%s) is not a valid format', Xobj.Stype)
end


