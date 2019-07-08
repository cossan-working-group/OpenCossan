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
%% Read the MATRIX

% NOTE: following if clauses are inserted, because force vector is always
% output in these files, however these are not read always. Similarly, in
% certain cases we only want to read the force vectors and skip the
% stiffness.

if  strcmp((lower(Xte.Soutputname)),'stiffness')
    
    % Convert the Harwell-Boeing format Matrix into MATLAB format
    system(['sparse_matrix_converter ' Xte.Sworkingdirectory Xte.Srelativepath filesep Xte.Sfile ' HB Mstiffness ML ']);
    
    % load the converted matrix into MATLAB memory
    load Mstiffness;
    
    % convert the matrix K0 into appropriate sparse format
    max_row_index             = max(Mstiffness(:,1)); %#ok<*NODEF>
    max_column_index          = max(Mstiffness(:,2));
    size_of_K                 = max(max_row_index,max_column_index);
    Tout.(Xte.Soutputname)    = sparse(Mstiffness(:,1),Mstiffness(:,2),Mstiffness(:,3),size_of_K,size_of_K);
    
    % NOTE-HMP: it is necessary to clean these, because if they are left, the
    % function reads the same matrix over and over and you never realize
    % that the matrix sparse converter never worked in the first place
    delete('Mstiffness');
    
elseif  strcmp((lower(Xte.Soutputname)),'mass')
    
    % Convert the Harwell-Boeing format Matrix into MATLAB format
    system(['sparse_matrix_converter ' Xte.Sworkingdirectory Xte.Srelativepath filesep Xte.Sfile ' HB Mmass ML ']);
    
    % load the converted matrix into MATLAB memory
    load Mmass;
    
    % convert the matrix K0 into appropriate sparse format
    max_row_index             = max(Mmass(:,1)); %#ok<*NODEF>
    max_column_index          = max(Mmass(:,2));
    size_of_K                 = max(max_row_index,max_column_index);
    Tout.(Xte.Soutputname)    = sparse(Mmass(:,1),Mmass(:,2),Mmass(:,3),size_of_K,size_of_K);
    
    % NOTE-HMP: it is necessary to clean these, because if they are left, the
    % function reads the same matrix over and over and you never realize
    % that the matrix sparse converter never worked in the first place
    delete('Mmass');
end

%% Read the Right Hand Side

if  strcmp((lower(Xte.Soutputname)),'force')
    
    fid = fopen(fullfile(Xte.Sworkingdirectory,Xte.Srelativepath,Xte.Sfile));
    
    if fid == -1
        error( 'HBExtractor:extract',' The file %s could not be found', fullfile(Xte.Sworkingdirectory,Xte.Srelativepath,Xte.Sfile));
    else
        OpenCossan.cossanDisp(['[HBExtractor.extract] ' Xte.Sfile ' opened successfully'],3);
    end
    
    tline      = fgetl(fid); %#ok<*NASGU>
    tline      = fgetl(fid);
    Nlines     = sscanf(tline, ' %d %d %d %d %d ');
    Nlines     = Nlines(1) + 5;
    tline      = fgetl(fid);
    tline      = fgetl(fid);
    tline      = fgetl(fid);
    length_f   = sscanf(tline, '%s %d %d ');
    length_f   = length_f(3);
    start_line = Nlines - length_f + 1;
    
    fclose(fid);
    
    fid     = fopen(fullfile(Xte.Sworkingdirectory,Xte.Srelativepath,Xte.Sfile));
    line_no = 0;
    while 1
        tline   = fgetl(fid);
        line_no = line_no + 1;
        if ( line_no == (start_line-1) ), break, end
    end
    
    f=zeros(length_f,1);
    for i = 1:length_f
        tline = fgetl(fid);
        f(i) = str2num(sscanf(tline, '%s')); %#ok<*ST2NM>
    end
    
    fclose(fid);
    
    Tout.force = f;
    
end

OpenCossan.cossanDisp(['[HBExtractor.extract] Completed reading from ' Xte.Sfile ],3);



return

