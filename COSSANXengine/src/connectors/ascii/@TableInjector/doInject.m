function doInject(Xobj,Tinput)
%REPLACE_VALUES replace values in the open file
%
%
%       '-mat'                        Binary MAT-file format (default).
%       '-ascii'                      8-digit ASCII format.
%       '-ascii', '-tabs'             Tab-delimited 8-digit ASCII format.
%       '-ascii', '-double'           16-digit ASCII format.
%       '-ascii', '-double', '-tabs'  Tab-delimited 16-digit ASCII format.
%%

SfullName=fullfile(Xobj.Sworkingdirectory,Xobj.Srelativepath,Xobj.Sfile);

OpenCossan.cossanDisp(['[OpenCossan.TableIdentifier.doInject] Filename:' SfullName],4);

CavailableInputs=fieldnames(Tinput);
assert(all(ismember(Xobj.Cinputnames,CavailableInputs)),...
    'OpenCossan:TableIdentifier.doInject:checkInput', ...
    'Variable(s) not present in the input structure!\n Required variables: %s\nAvailable variables: %s',...
    sprintf('"%s" ',Xobj.Cinputnames{:}),sprintf('"%s" ',CavailableInputs{:}))

%% Assemble data
% If LinjectCoordinates is true the data (for stochastic process) are
% written in the following format
% Coordinate (x,y,z,...) Value 
% If more than 1 dataserie needs to be written they need to have the same
% length and share the same coordinates

Mcoord = [];
Mdata=[];
for nvar=1:Xobj.Nvariable
    Xdata=Tinput.(Xobj.Cinputnames{nvar});
    % get the value to be injected
    switch class(Xdata)
        case 'Dataseries'
            % if an index is specified, assign to value the content of
            % the property Mdata of the Dataseries object at the
            % specified index
            
            if isempty(Xobj.Vindices)
                Vindx=[1:size(Xdata.Xcoord.Mcoord,2)];
            else
                Vindx=Xobj.Vindices;
            end
            
            VdataInject=Xdata.Vdata(Vindx);
            
            if ~iscolumn(VdataInject)
                VdataInject=transpose(VdataInject);
            end
            
            if nvar==1 && Xobj.LinjectCoordinates
                Mdata(:,1)=Xdata.Mcoord(Vindx);
            end
            
            assert(size(Mdata,1)==size(VdataInject,1),...
                'Lenght of the coordinates (%i) is not compatible with the length of data (%i)',...
                size(Mdata,1),size(VdataInject,1))
            
            Mdata= [Mdata VdataInject];             %#ok<AGROW>

        case {'double','single','logical'}
            Mdata = [Mdata Xdata]; %#ok<AGROW>
        otherwise
            error('OpenCossan:TableIdentifier:doInject:wrongClass',['It is not possible '...
                'to inject values from object of class %s'], ...
                class(Xdata))
    end
end

%% Write header
Nfid = fopen(SfullName,'w');    
% Write headers
[nrows,~] = size(Xobj.Cheaderlines);
for row = 1:nrows
    fprintf(Nfid,'%s\n',Xobj.Cheaderlines{row,:});
end
fclose(Nfid);


switch lower(Xobj.Stype)
    case {'.mat'}
        save(SfullName,'Mdata');
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
        
        
    case {'userdefined'}
        Nfid = fopen(SfullName,'a');
        
        [nrows,~] = size(Mdata);
        
        for row = 1:nrows
            fprintf(fileID,Xobj.Sformat,Mdata(row,:));
        end        
        fclose(Nfid);

    otherwise
        error('OpenCossan:TableInjector:doInject',...
            'Injector Type (%s) is not a valid. ', Xobj.Stype)
end


