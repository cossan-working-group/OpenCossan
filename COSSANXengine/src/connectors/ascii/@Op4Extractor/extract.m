function [Tout, LsuccessfullExtract] = extract(Xte,varargin)
%EXTRACTOR  extract values form op4 output file and create
%                       a structure Tout 
%
%   Arguments:
%   ==========
%   Xe          Extractor_timeseries object (mandatory)
%   Tout        Structure that containt the extracted values 
%
%   Usage:  Tout  = extrac(Xte)
%
%   see also: apply_evaluator, connector, extractor
%

Tout = struct;
LsuccessfullExtract = true;
%% Opening the file
Sfilename = fullfile(Xte.Sworkingdirectory,Xte.Srelativepath,Xte.Sfile);
if exist(Sfilename,'file') ~= 2
    error('openCOSSAN:OP4Extractor:extract', ['Please make sure that the input file ' Sfilename ' exists']);
end
fid=fopen(Sfilename,'r');

if fid == -1
   error('openCOSSAN:Op4Extractor:extract',['The file ' Sfilename ' could not be found' ]); 
else
   OpenCossan.cossanDisp(['[openCOSSAN.Op4Extractor.extract] ' Sfilename ' opened successfully'],3);
end

%% get the matrix type (vector or square matrix)
 
% Reading the information about the matrix
NCOL  = fscanf(fid,'%i',1);
NROW  = fscanf(fid,'%i',1);
NROW  = abs(NROW);
NF    = fscanf(fid,'%i',1);
NTYPE = fscanf(fid,'%i',1);

%% Check whether or not the file is empty
%
% NOTE: this can happen, e.g. NASTRAN creates the file lets say to output
% force vector, however there if no force applied, so the file is just
% emypt. And this causes error in this function

if isempty(NCOL)
   OpenCossan.cossanDisp(['[openCOSSAN.Op4Extractor.extract] The file ' Sfilename ' is empty'],0);
   Tout = NaN;
   LsuccessfullExtract = false;
   return
end

%% Start reading matrices & vectors
if NF == 6
    OpenCossan.cossanDisp(['[openCOSSAN.Op4Extractor.extract] Reading ' num2str(NCOL) 'x' num2str(NROW) ' matrix '],2);
    fscanf(fid,'%s',2);
    out=spalloc(NCOL,NROW,2000000);
    ICOL=0;
    % following part is to handle the special case where we read only 1x1
    % matrix. I had to account for this here in order to not to check it
    % within the WHILE loop (it would be much slower)
    if NCOL == 1
        ICOL   =fscanf(fid,'%i',1);
        UNUSED =fscanf(fid,'%i',1);
        NW     =fscanf(fid,'%i',1);
        L      =fscanf(fid,'%i',1);
        IROW   =fscanf(fid,'%i',1);
        % There is a slight difference in the format if the file to be read
        % is PA or K. This is just a quick and dirty solution
        if isempty(IROW)
            position = ftell(fid);
            % going back to before that position in the text file
            position = position - 1;
            % setting the position for further writing
            fseek(fid, position,'bof');
            tline = fgetl(fid);
            out(1)=str2num(tline); %#ok<*ST2NM>
        else
            out(1)=fscanf(fid,'%f',(L-1)/NTYPE);  
        end
        % assign the matrix to the requested name
        Tout.(Xte.Soutputname)=out;
        fclose(fid);
        OpenCossan.cossanDisp(['[openCOSSAN.Op4Extractor.extract] Completed reading from ' Xte.Sfile],2);
        return
    end
    % Reading the data of SPARSE SYMMETRIC matrices
    while ICOL<=NCOL
        ICOL=fscanf(fid,'%i',1);
        UNUSED=fscanf(fid,'%i',1);
        NW=fscanf(fid,'%i',1);
        count=0;
        % The loop to read the elements of the matrix 
        while count<NW && UNUSED == 0
            L=fscanf(fid,'%i',1);
            IROW=fscanf(fid,'%i',1);
            out(IROW:IROW-1 + (L-1)/NTYPE,ICOL)=fscanf(fid,'%f',(L-1)/NTYPE);
            count=count + 2 + (L-1);
        end 
    end
    % assign the matrix to the requested name
    Tout.(Xte.Soutputname)=out;
elseif NF == 1 || NF == 2
    frewind(fid)
    % Read header
    line =fgets(fid);  % Matrix header
    if (line==-1)
        OpenCossan.cossanDisp(['[openCOSSAN.Op4Extractor.extract] Completed reading from ' Xte.Sfile],2);
        return
    end
    ncol = sscanf(line(1:8), '%d');             % Number of columns in matrix
    nrowtemp = sscanf(line(9:16), '%d');        % Number of rows in matrix
    nrow  = abs(nrowtemp);
    form  = sscanf(line(17:24), '%d');          % Matrix form
    type  = sscanf(line(25:32), '%d');          % Matrix type
    name  = sscanf(line(33:40), '%s');          % Matrix name
    i1    = find(line(41:end)==',');
    i2    = find(line(41:end)=='E');
    i3    = find(line(41:end)=='.');
    nr    = sscanf(line(41+i1:39+i2),'%d');     % Number of elements per line
    nl    = sscanf(line(41+i2:39+i3),'%d');     % Number of bytes per element
    nd    = sscanf(line(41+i3:end),'%d');       % Number of bytes after decimal place
    line  = fgets(fid);                         % Read column header
    icol  = sscanf(line(1:8), '%d');            % Column number
    temp1 = sscanf(line(9:16), '%d');           % Zero means Sparse matrix
    nw    = sscanf(line(17:24), '%d');          % Number of words in column data block
    OpenCossan.cossanDisp(['[openCOSSAN.Op4Extractor.extract] Reading ' num2str(NCOL) 'x' num2str(NROW) ' matrix ' name],2);
    if temp1==0                                            % Determine if matrix is sparse
        error('[openCOSSAN.Op4Extractor.extract] This function can read only nonsparse vectors');
    end
    out = zeros(nrow, ncol);         % Initialize a real matrix
    col = zeros(nrow, 1);            % Initialize a column of length nrow
    while (icol <= ncol)
        irow1 = sscanf(line(9:16), '%d');                  % 1st non-zero row in column
        mrow  = sscanf(line(17:24), '%d');                 % Number of non-zero words in column
        irow2 = irow1 + mrow -1;                           % Last non-zero word in column
        nline = ceil(mrow/nr);                             % Number of lines of real data for current column
        irow  = irow1;                                     % Initilize row counter
        if rem(icol,100)==0                                % Display file read progress 
            OpenCossan.cossanDisp(['reading column ',num2str(icol)])
        end
        for iline = 1:nline                                % Loop over number of lines of data for current column
            line  = fgets(fid);                            % Read next line
            for ir = 1:nr                                  % Loop over number of elements on this line
                if (irow > irow2)                          % If row is greater than last non-zero row break out of loop
                    break
                end
                i1 = nl*(ir-1) + 1;                        % First column of line for current matrix element
                i2 = nl*(ir);                              % Last column of line of current matrix element
                col(irow) = sscanf(line(i1:i2),'%f');      % Read matrix element
                irow = irow + 1;                           % Increment row number
            end
        end
        out(:,icol) = col;                                 % Copy column into matrix
        col = zeros(nrow,1);                               % Reinitialize column to zero
        line  = fgets(fid);                                % Read next line
        icol  = sscanf(line(1:8), '%d');                   % Column number
    end
    % assign the vector to the requested name
    Tout.(Xte.Soutputname)=out;
else
    error('[openCOSSAN.Op4Extractor.extract] This matrix type is not supported');
end
  
fclose(fid);

OpenCossan.cossanDisp(['[openCOSSAN.Op4Extractor.extract] Completed reading from ' Xte.Sfile],2);

return

