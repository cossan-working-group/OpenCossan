function insertRecord(Xobj,varargin)
%INSERTRECORD  This method is used to add a new record into the current database
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/InsertRecord@DatabaseDrive
%
% Author: Matteo Broggi
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


%% Default inputs
StableType='';
Nsimulation=[];
LsuccessfullExecution=false;
SanalysisMATFile='';

%% Process inputs
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        % Common arguments
        case 'nid'
            Nid = varargin{k+1};
        case 'stabletype'
            assert(ismember(varargin{k+1},Xobj.CtableTypes), ...
                'openCOSSAN:DatabaseDriver:insertRecord',...
                'Not valid table type %s', varargin{k+1})
            StableType=varargin{k+1};        
        % Arguments for Solver DB
        case 'xsimulationdata'
            assert (isa(varargin{k+1},'SimulationData'), ...
                'openCOSSAN:DatabaseDriver:insertRecord',...
                'Simulation Data object is required after property name %s, provided object type: %s',...
                varargin{k},class(varargin{k+1}))
            XSimData=varargin{k+1};
        case 'lsuccessfullextract'
            LsuccessfullExtract=varargin{k+1};
        case 'lsuccessfullexecution'
            LsuccessfullExecution=varargin{k+1};
        case 'ssimulationfolder'
            SsimulationFolder=varargin{k+1};
            assert(logical(exist(SsimulationFolder,'dir')),...
                'openCOSSAN:DatabaseDriver:insertRecord',...
                'The simulation folder %s does not exist', SsimulationFolder)
        case 'ssimulationzip'
            SsimulationZip=varargin{k+1};
            assert(logical(exist(SsimulationZip,'file')),...
                'openCOSSAN:DatabaseDriver:insertRecord',...
                'The simulation zip file %s does not exist', SsimulationZip)
        case 'nsimulation'
            Nsimulation=varargin{k+1};
        % Arguments for Simulation DB
        case 'nbatchnumber'
            NbatchNumber=varargin{k+1};
        % Arguments for Simulation and Result DB
        case 'ccossanobjects'
            CcossanObjects=varargin{k+1};
        case 'ccossanobjectsnames'
            CcossanObjectsNames=varargin{k+1};
        % Arguments for Results DB
        case 'sanalysismatfile'
            SanalysisMATFile = varargin{k+1};
        otherwise
            error('openCOSSAN:DatabaseDriver:insertRecord',...
                'The property name %s is not valid', varargin{k})
    end
end

% check mandatory inputs
assert(~isempty(StableType),'openCOSSAN:DatabaseDriver:insertRecord',...
    'Mandatory input StableTypes missing.')

Cdata{1}=Nid; CdataType{1}='"{Si}"';
switch StableType
    case ('Analysis')
        Cdata{2}=OpenCossan.getProjectName; CdataType{2}='"{S}"';      
        Cdata{3}=OpenCossan.getAnalysisName; CdataType{3}='"{S}"';        
        Cdata{4}=OpenCossan.getUserName; CdataType{4}='"{S}"';
        Cdata{5}=OpenCossan.getDescription; CdataType{5}='"{S}"';
        Cdata{6}=datestr(now,'yyyy-mm-dd HH:MM:SS'); CdataType{6}='"{S}"';
        Ccolnames=Xobj.CcolnamesAnalysis;
        Squery = sprintf(['INSERT INTO %s (%s,%s,%s,%s,%s,%s) '...
            'VALUES(%s,%s,%s,%s,%s,%s);'],...
            StableType,Ccolnames{:},CdataType{:});
    case ('Result')    
        Cdata{2}=OpenCossan.getAnalysisID; CdataType{2}='"{Si}"';
        
        if isempty(SanalysisMATFile)
            assert(~isempty(CcossanObjects) && ~isempty(CcossanObjectsNames),...
                'openCOSSAN:DatabaseDriver:insertRecord',...
                ['Either a mat-file or Cossan objects with the analysis '...
                'results must be passed\nto insert an entry in the analysis '...
                'table.']);
            tmpfile1 = [tempname '.mat'];
            createMatlabfile(CcossanObjectsNames,CcossanObjects,tmpfile1);
            
            SanalysisMATFile=tmpfile1;
        end
        
        Cdata{3}=SanalysisMATFile; CdataType{3}='"{F}"';
        Cdata{4}=datestr(now,'yyyy-mm-dd HH:MM:SS'); CdataType{4}='"{S}"';
        
        Ccolnames=Xobj.CcolnamesResult;
        Squery = sprintf(['INSERT INTO %s (%s,%s,%s,%s) '...
            'VALUES(%s,%s,%s,%s);'],...
            StableType,Ccolnames{:},CdataType{:});
    case ('Simulation')    
        Cdata{2}=OpenCossan.getAnalysisID; CdataType{2}='"{Si}"';
        
        if exist('NbatchNumber','var')
            
            assert(logical(exist('XSimData','var')),...
                'openCOSSAN:DatabaseDriver:insertRecord',...
                'It is mandatory to pass a SimulationData object if the batch number is defined')
            
            %% Create a binary file of the SimulationData object
            tmpfile1 = [tempname '.mat'];
            XSimData.save('SfileName',tmpfile1);
            
            Cdata{3}=NbatchNumber; CdataType{3}='"{Si}"';
            Cdata{4}=tmpfile1; CdataType{4}='"{F}"';
        else
            Cdata{3}=[]; CdataType{3}='"{Si}"';
            Cdata{4}=''; CdataType{4}='"{S}"';
        end
        
        %% Create a binary file of the Cossan object
        if exist('CcossanObjects','var')
            tmpfile2 = [tempname '.mat'];
            createMatlabfile(CcossanObjectsNames,CcossanObjects,tmpfile2);
            
            Cdata{5}=tmpfile2; CdataType{5}='"{F}"';
        else
            Cdata{5}=''; CdataType{5}='"{S}"';
        end
        
        Cdata{6}=datestr(now,'yyyy-mm-dd HH:MM:SS'); CdataType{6}='"{S}"';
        Ccolnames=Xobj.CcolnamesSimulation;
        
        Squery = sprintf(['INSERT INTO %s (%s,%s,%s,%s,%s,%s) '...
            'VALUES(%s,%s,%s,%s,%s,%s);'],...
            StableType,Ccolnames{:},CdataType{:});
    case ('Solver')
        Cdata{2}=OpenCossan.getAnalysisID; CdataType{2}='"{Si}"';
        
        assert(logical(exist('XSimData','var')),...
            'openCOSSAN:DatabaseDriver:insertRecord',...
            'It is mandatory to pass a SimulationData object')
        
        %% Create a binary file of the SimulationData object
        tmpfile1 = [tempname '.mat'];
        XSimData.save('SfileName',tmpfile1);
        
        if exist('SsimulationFolder','var')
            % compress the folder with the simulation files ...
            SsimulationZip=[SsimulationFolder '.tgz'];
            tar(SsimulationZip,SsimulationFolder);
            
            % ... and delete old folder
            rmdir(SsimulationFolder,'s');
        end
        
        % It assumes that the columns of the table are always the same, as agreed...
        Cdata{3} = Nsimulation; CdataType{3}='"{Si}"';
        Cdata{4}=tmpfile1; CdataType{4}='"{F}"';
        Cdata{5}=LsuccessfullExecution; CdataType{5}='"{Si}"';
        Cdata{6}=LsuccessfullExtract; CdataType{6}='"{Si}"';
        Cdata{7}=SsimulationZip; CdataType{7}='"{F}"';
        Cdata{8}=datestr(now,'yyyy-mm-dd HH:MM:SS'); CdataType{8}='"{S}"';
        
        Ccolnames=Xobj.CcolnamesSolver;
        
        Squery = sprintf(['INSERT INTO %s (%s,%s,%s,%s,%s,%s,%s,%s) '...
            'VALUES(%s,%s,%s,%s,%s,%s,%s,%s);'],...
            StableType,Ccolnames{:},CdataType{:});
end

% add the entry into the database
OpenCossan.cossanDisp('[OpenCossan.DatabaseDriver.insertRecord] Executing insert query:',4);
OpenCossan.cossanDisp(Squery,4);
OpenCossan.cossanDisp('with the following inputs:',4);
if OpenCossan.getVerbosityLevel>=4
    for idebug=1:length(Cdata)
        display([Ccolnames{idebug} '  = ']);
        display(Cdata{idebug});
    end
end
Xobj.XdatabaseConnection.prepareStatement(Squery,Cdata{:});
Xobj.XdatabaseConnection.query();

% clean temporary files
if (exist('tmpfile1','var'))
    delete(tmpfile1);
end
if (exist('tmpfile2','var'))
    delete(tmpfile2)
end

end



function createMatlabfile(CcossanObjectsNames,CcossanObjects,SmatlabBinaryName)
% Save object into a matlab file
for n=1:length(CcossanObjectsNames)
    renameVariable(CcossanObjectsNames{n},CcossanObjects{n})
end
save(SmatlabBinaryName,CcossanObjectsNames{:});
end

