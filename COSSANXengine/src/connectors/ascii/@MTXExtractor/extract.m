function [Tout LsuccessfullExtract Vnodes Vdofs]=extract(Xe,varargin)
%EXTRACTOR  extract values form MTX output file and create
%                       a structure Tout
%
%   Arguments:
%   ==========
%   Xe          MTXExtractor timeseries object (mandatory)
%   Tout        Structure that containt the extracted values
%
%   Usage:  Tout  = extract(Xte)
%
%   see also: extractor, connector
%

Tout = struct;
LsuccessfullExtract = true;
%% 1. Processing Inputs

OpenCossan.validateCossanInputs(varargin{:});
for iopt=1:2:length(varargin)
    switch lower(varargin{iopt})
        case {'nsimulation'}
            Nsimulation = varargin{iopt+1};
        case {'vdofs'}
            Vdofs = varargin{iopt+1};
        case {'vnodes'}
            Vnodes = varargin{iopt+1};
        otherwise
            error(['[MTXExtractor.extract] Optional parameter ' varargin{iopt} ' not allowed']);
    end
end
if ~exist('Nsimulation','var')
    Nsimulation = 1;
end

Sfilename = fullfile(Xe.Sworkingdirectory,Xe.Srelativepath,Xe.Sfile);
if exist(Sfilename,'file') ~= 2
    error(['COSSAN:MTXExtractor: Please make sure that the input file ' ...
        Sfilename ' exists']);
end

%% Load the matrix from the Abaqus file
try
    Mall = load(Sfilename); % open ASCII file
    OpenCossan.cossanDisp(['[COSSAN-X.MTXExtractor.extract] Load matrix from file : ' Sfilename],4 )
catch ME
    % Return NaN value if an error occurs in the extractor
    if strcmp(ME.identifier,'MATLAB:load:numColumnsNotSame')
        warning('openCOSSAN:MTXExtractor:extract',...
            ['The results file ' Sfilename...
            ' of simulation #' num2str(Nsimulation) ' is not in a valid table format.'])
    end
    if strcmp(ME.identifier,'MATLAB:load:couldNotReadFile')
        warning('openCOSSAN:MTXExtractor:extract',...
            ['The results file ' Sfilename...
            ' of simulation #' num2str(Nsimulation) ' does not exist.'])
    end
    Tout.(Xe.Soutputname)=NaN;
    LsuccessfullExtract = false;
    return;
end

%% FIND NUMBER OF NODES

if size(Mall,2) == 5
    % Structure of the .mtx-file:
    % Row 1 and 3: node number
    % Row 2 and 4: degree of freedom (1-6) in global coordinate system
    % Row 5: associated stiffness matrix entry
    Vindex = find(Mall(:,1)-Mall(:,3)==0 & Mall(:,2)-Mall(:,4)==0);
    Vnodes = Mall(Vindex,1);
    Vdofs = Mall(Vindex,2);
    
    Vidnewa =  Vnodes*10+Vdofs;
    [~,posa] = sort(Vidnewa);
    
    Vidnewb =  Mall(:,1)*10+Mall(:,2);
    [~,~,posb] = unique(Vidnewb);
    Vrow = posa(posb);
    
    Vidnewb =  Mall(:,3)*10+Mall(:,4);
    [~,~,posb] = unique(Vidnewb);
    Vcol = posa(posb);
    
    OpenCossan.cossanDisp(['Reading ' num2str(length(Vnodes)) ' x ' num2str(length(Vnodes)) ' matrix'],3)
    
    MK=sparse(Vrow,Vcol,Mall(:,5)); % define sparse stiffness matrix
    clear Mall Ventry Vdof2 Vdof n2 n1
    
    % Delete the rows and corresponding columns with fixed DOFs (BC)
    % row=find(Vdiag>10^35); %TODO user-defined bound for values of fixed DOFs
    % MK=removerows(MK,row);
    % MK=removerows(MK',row);
    %
    % Vnodes(row) = [];
    % Vdofs(row) = [];
    % clear Vdiag;
    
    % Convert lower triangular matrix to full matrix
    MK = MK + MK'-diag(diag(MK));
    Tout.(Xe.Soutputname)=MK;
    
    
    OpenCossan.cossanDisp('[COSSAN-X.MTXExtractor.extract] Matrix extraction finished. ',4 )
elseif size(Mall,2) == 3
    
    if ~exist('Vnodes','var') || ~exist('Vdofs','var')
        error('openCOSSAN:MTXExtractor:extract',...
            'The vectors Vnodes and Vdofs have to be passed.')
    end
    if length(Vnodes)~=length(Vdofs)
        error('openCOSSAN:MTXExtractor:extract',...
            'The vectors Vnodes and Vdofs must have the same length.')
    end
    
    Vidnewa =  Vnodes*10+Vdofs;
    Vidnewb =  Mall(:,1)*10+Mall(:,2);
    
    OpenCossan.cossanDisp(['Reading ' num2str(length(Vnodes)) ' x  1 vector'],3)
    
    Vrow = zeros(size(Mall,1),1);
    for ientry = 1:length(Vrow)
        Vrow(ientry) = find(Vidnewa==Vidnewb(ientry));
    end
    
    Vf = zeros(length(Vnodes),1);
    Vf(Vrow) = Mall(:,3);
    Tout.(Xe.Soutputname) = Vf;
    
else
    error('openCOSSAN:MTXExtractor:extract',...
        ['The results file ' Sfilename...
        ' does not contain a table of mtx-format.'])
end
return;
