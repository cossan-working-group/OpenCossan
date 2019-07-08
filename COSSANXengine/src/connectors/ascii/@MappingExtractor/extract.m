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
%% 1. Processing Inputs

Xte.Lverbose=true;
for iopt=1:2:length(varargin)
	switch lower(varargin{iopt})
        case {'lverbose'}
			Xte.Lverbose=varargin{iopt+1};	
        otherwise
            warning('openCOSSAN:Mappingextractor','Field name not allowed');
	end
end

%% Read the DOF info

fid = fopen([Xte.Sworkingdirectory Xte.Srelativepath filesep Xte.Sfile]);

tline = fgetl(fid); %#ok<*NASGU>
input = textscan(fid,'%d %d %s');

% following part is necessary since ANSYS does not output DOFs as numbers
% but as text like UX, UY, etc. So a conversion was necessary
Vuxindices   = find(ismember(input{3},'UX'));
Vuyindices   = find(ismember(input{3},'UY'));
Vuzindices   = find(ismember(input{3},'UZ'));
Vrotxindices = find(ismember(input{3},'ROTX'));
Vrotyindices = find(ismember(input{3},'ROTY'));
Vrotzindices = find(ismember(input{3},'ROTZ'));

Vdofs  = zeros(length(input{2}),1);
Vdofs(Vuxindices)   = 1;
Vdofs(Vuyindices)   = 2;
Vdofs(Vuzindices)   = 3;
Vdofs(Vrotxindices) = 4; %#ok<*FNDSB>
Vdofs(Vrotyindices) = 5;
Vdofs(Vrotzindices) = 6;

DOFs  = [input{2},Vdofs];

fclose(fid);

Tout.(Xte.Soutputname)  = DOFs;

%% Display 

if Xte.Lverbose
    display(['Completed reading from ' Xte.Sfile ])
end

return

