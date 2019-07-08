function exportResults(Xobj,varargin)
%EXPORTRESULTS  This private methods of the class simulations is used
%to store the results of the simulation, i.e. the batches, on the
%disk
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================


% Mesure the time required to store the output file
ndelta=OpenCossan.setLaptime('Sdescription','Store results on file system');

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%% Process optional parameters
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'xsimulationoutput'
            assert(isa(varargin{k+1},'SimulationData'), ...
                'openCOSSAN:simulation:exportResults',...
                'A simulation output is required after the property PropertyField %s', ...
                varargin{k});
            XOut=varargin{k+1};
        case 'xlinesamplingoutput'
            assert(isa(varargin{k+1},'LineSamplingOutput'), ...
                'openCOSSAN:simulation:exportResults',...
                'A LineSamplingOutput is required after the property PropertyField %s', ...
                varargin{k});
            XOut=varargin{k+1};
        case 'xlinesamplingdata'
            assert(isa(varargin{k+1},'LineSamplingData'), ...
                'openCOSSAN:simulation:exportResults',...
                'A LineSamplingData object is required after the property PropertyField %s', ...
                varargin{k});
            XOut=varargin{k+1};
        case 'xsubsetoutput'
            assert(isa(varargin{k+1},'SubsetOutput'), ...
                'openCOSSAN:simulation:exportResults',...
                'A LineSamplingOutput is required after the property PropertyField %s', ...
                varargin{k});
            XOut=varargin{k+1};
        case 'sbatchname'
            SbatchName=varargin{k+1};
        case 'cadditionalobject'
            Cadditional=varargin{k+1};
        otherwise
            error('openCOSSAN:simulation:exportResults',...
                'PropertyName %s is not allowed',varargin{k})
    end
end

if isempty(Xobj.SbatchFolder)
    Xobj.SbatchFolder=datestr(now,30);
end

if ~exist('SbatchName','var')
    SbatchName=Xobj.SbatchName;
end

Sfullpath=fullfile(OpenCossan.getCossanWorkingPath,Xobj.SbatchFolder);

OpenCossan.cossanDisp(['[Simulation:exportResults] Writing partial results (' SbatchName ') on the folder: ' Sfullpath],3)


%% Export results

% Create a folder to store the partial results
if ~exist([OpenCossan.getCossanWorkingPath 'Xobj.SbatchFolder'],'dir')
    [status,mess] = mkdir(Sfullpath);
    if ~status
        warning('openCOSSAN:simulations:savePartialResults',mess)
    end
end

% Store SimulationData object
% Each component is saved separetly in order to avoid the matlab bug of the
% memory preallocation

% Store the status of the RandomStream
%SimOutReserved_RStream=RandStream.getGlobalStream; %#ok<NASGU>
SimOutReserved_RStream=OpenCossan.getRandomStream; %#ok<NASGU>


Sfullname=fullfile(Sfullpath,SbatchName);
%% Append all the optional arguments
if exist('XOut','var')
    XOut.save('SfileName',Sfullname);
    save(Sfullname,'-append','SimOutReserved_RStream');
else
    save(Sfullname,'SimOutReserved_RStream');
end

if exist('Cadditional','var')
    save(Sfullname,'-append',Cadditional);
end

OpenCossan.cossanDisp(['[Simulation:exportResults] Batch #' num2str(Xobj.ibatch) ' written in ' num2str(OpenCossan.getDeltaTime(ndelta))],4)
OpenCossan.cossanDisp(['[Simulation:exportResults] Results stored in the folder: ' Sfullname],4);


if ~isempty(OpenCossan.getDatabaseDriver)   % Add record to the Database
    if isempty(Xobj.Sdescription)
        Xobj.Sdescription='Not available';
    end
    %% Add record
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
        'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
        'XsimulationData',XOut,'Nbatchnumber',Xobj.ibatch)    
    
end


% Mesure the time required to store the output file
OpenCossan.setLaptime('Sdescription','End storing results on file system');
