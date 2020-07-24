function inject(obj,TableInput)
%%
%  Inject the input values into INPUT ASCII FILE
%
%   Arguments:
%   ==========
%   Xi                  Injector object
%   Pinput          Input Object/Structure
%   varargin       optional parameters
%   varargout     Log results
%
%   Usage:  Clog  = inject(Xi,Xinput)
%
%   see also: connector, extractor, injector
%
import opencossan.OpenCossan
%%. Processing Inputs

% Process all the optional arguments and assign them the corresponding
% default value if not passed as argument

assert(isa(TableInput,'table'),'openCOSSAN:Injector:Inject', ...
    'The input values must be passed in a table');
fieldNames = TableInput.Properties.VariableNames;
for i = 1:length(fieldNames)
   assert(length(TableInput.(fieldNames{i}))==1,'openCOSSAN:Injector:InjectTooManySamples', ...
    'Only one realization of the input parameters can be injected at a time'); 
end


%% Check open files

VfIDs = fopen('all');
for ifid=1:length(VfIDs)
    [SfilenameDB, SpermissionDB] = fopen(VfIDs(ifid));
    OpenCossan.cossanDisp(['[openCOSSAN.Injector.inject] Open filename: ' SfilenameDB ' permission: ' SpermissionDB ],3 )
end

if isempty(VfIDs)
    OpenCossan.cossanDisp('[openCOSSAN.Injector.inject] No currently open files: ;)',4 )
end



%% 2.  Update input files

OpenCossan.cossanDisp(['[openCOSSAN.Injector.inject] Current directory: ' pwd ],4 )
OpenCossan.cossanDisp('[openCOSSAN.Injector.inject] Current directory using system commands: ' ,4 )
if OpenCossan.getVerbosityLevel>3
    if isunix
        system('pwd');
    else
        system('cd');
    end
end

%% Replace values in the FE input file
SfullName=fullfile(opencossan.OpenCossan.getWorkingPath,obj.RelativePath,obj.FileName);

OpenCossan.cossanDisp(['[openCOSSAN.Injector.inject] Replacing value in the file: ' SfullName ],2)

OpenCossan.cossanDisp('[openCOSSAN.Injector.inject] File content before injecting values',4)

if OpenCossan.getVerbosityLevel>3
    type(SfullName)
end

if isa(obj,'opencossan.workers.ascii.TableInjector')
    obj.doInject(TableInput);
else
    
    [Nfid,Serror] = fopen(SfullName,'r+'); % open ASCII file
    
    OpenCossan.cossanDisp(['[openCOSSAN.Injector.inject] Open file (relative path): ' ...
        SfullName],3)
    if Nfid~=-1
        OpenCossan.cossanDisp(['[openCOSSAN.Injector.inject] Fid: ' num2str(Nfid)],4)
    end
    
    assert(isempty(Serror),'openCOSSAN:Injector:InjectFileOpenError',...
            'Error opening file %s \nError: %s', SfullName, Serror );
    
    if ~isempty(obj.Identifiers)
        obj.Identifiers.replaceValues('FileID',Nfid,'TableInput',TableInput);
    else
        warning('openCOSSAN:Injector:inject',['No identifiers defined in input file.\n'...
            'Consider put your input file in CadditionalFiles of Connector instead']);
    end
    %% Close open files
    fclose(Nfid);
end


OpenCossan.cossanDisp('[openCOSSAN.Injector.inject] File contents after injecting values',4)
if OpenCossan.getVerbosityLevel>3
    type(SfullName)
end

OpenCossan.cossanDisp('[openCOSSAN.Injector.inject] Show folder contents',4)
if OpenCossan.getVerbosityLevel>3
    if ispc
        system('dir /A')
    else
        system('dir -all')
    end
end
OpenCossan.cossanDisp('[openCOSSAN.Injector.inject] Inject completed',4)

