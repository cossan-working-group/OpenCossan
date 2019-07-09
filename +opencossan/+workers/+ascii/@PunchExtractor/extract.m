function [Tout, LsuccessfullExtract] = extract(Xte,varargin)
%EXTRACTOR  extract values form punch file output file and create
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
[fid,~] = fopen(Sfilename,'r');

if fid == -1
   error([ 'COSSAN:punchExtractor: The file ' Sfilename ' could not be found' ]); 
else
    OpenCossan.cossanDisp(['[SFEM.PunchExtractor] ' Sfilename ' opened successfully'],3);
end

%% Read the file

while 1
    tline = fgetl(fid);
    if ~ischar(tline),   break,   end
    if strcmp ('DMIG*',tline(1:5)) == 1;
        input  = textscan(fid, '%*s %d %d %*f');
        DOFs  = [input{1},input{2}]; 
    end
end

OpenCossan.cossanDisp(['[SFEM.PunchExtractor] Completed reading ' num2str(length(DOFs)) ' DOFs from ' Sfilename],2);

Tout.(Xte.Soutputname)=DOFs;

return

