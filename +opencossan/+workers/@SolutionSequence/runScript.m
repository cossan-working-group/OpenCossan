function COSSANoutput=runScript(XobjSolutionSequence,varargin)    %#ok<STOUT>
% BE SURE ALL VARIABLES IN THE SCRIPT HAVE UNIQUE NAME

% The required inputs are passed using the matlab convenction varargin and the
% output returned via varargout. 

%% Check inputs
assert(length(varargin)==length(XobjSolutionSequence.Cinputnames), ...
    'openCOSSAN:SolutionSequence:runScript',...
    'Input length (%i) does not match with the expected input length (%i)',...
     length(varargin),length(XobjSolutionSequence.Cinputnames))
 
 for n=1:length(XobjSolutionSequence.CobjectsNames)

     assert(isa(XobjSolutionSequence.Cxobjects{n},XobjSolutionSequence.CobjectsTypes{n}), ...
         'openCOSSAN:SolutionSequence:runScript', ...
         ['The provided object does not correspond to the expected object ' ...
         'type  \n Expected Type %s; Available type %s; Name %s'], ...
         XobjSolutionSequence.CobjectsTypes{n}, ...
         class(XobjSolutionSequence.Cxobjects{n}),XobjSolutionSequence.CobjectsNames{n})
     
         eval([XobjSolutionSequence.CobjectsNames{n} '=XobjSolutionSequence.Cxobjects{' num2str(n) '};']);
 end
 
%% Execute the script
    if isempty(XobjSolutionSequence.Sscript),   %checks how the script was defined
        try
            OpenCossan.cossanDisp('[SolutionSequence:apply] Running user defined script defined in the file',3)
            run(fullfile(XobjSolutionSequence.Spath,XobjSolutionSequence.Sfile));  %runs script contained in a file line by line
            OpenCossan.cossanDisp('[SolutionSequence:apply] Execution of user defined script completed',3)
        catch ME
            error('openCOSSAN:SolutionSequence:apply',...
                strcat(' The user define function can not be evaluated! \n', ...
                ' Please check your script \n %s'),ME.message)
        end
    else
        try
            OpenCossan.cossanDisp('[SolutionSequence:runScript] Evaluate Script',4)
            eval(XobjSolutionSequence.Sscript);   %evaluates directly commands contained in the field Xobj.Sscript
        catch ME
            error('openCOSSAN:SolutionSequence:runScriptError',...
                strcat(' The user define script can not be evaluated! \n',...
                ' Please check your script! \n %s'),ME.message)
        end
    end

    
%% Check outputs
if ~isempty(XobjSolutionSequence.Coutputnames)
    assert(logical(exist('COSSANoutput','var')), ...
    'openCOSSAN:SolutionSequence:runScript:NoExpectedOutput',...
    'COSSANoutput variable does not exist. Expected output length (%i)',...
     length(COSSANoutput),length(XobjSolutionSequence.Coutputnames))  
    
    
    assert(length(COSSANoutput)==length(XobjSolutionSequence.Coutputnames), ...
    'openCOSSAN:SolutionSequence:runScript:OutputLengthMismatch',...
    'Output length (%i) does not match with the expected output length (%i)',...
     length(COSSANoutput),length(XobjSolutionSequence.Coutputnames))  
end
 
%% Check output objects
for iout=1:length(XobjSolutionSequence.Coutputnames)
    if ~isempty(XobjSolutionSequence.CprovidedObjectTypes{iout})
        assert(isa(COSSANoutput{iout},XobjSolutionSequence.CprovidedObjectTypes{iout}), ...
              'openCOSSAN:SolutionSequence:runScript',...
              'Output at position (%i) is of type %s, expected type %s',...
               iout,class(COSSANoutput{iout}),XobjSolutionSequence.CprovidedObjectTypes{iout})
    end
end


