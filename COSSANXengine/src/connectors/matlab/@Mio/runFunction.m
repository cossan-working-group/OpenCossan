function [Poutput]=runFunction(Xmio,Psamples)
% RUNFUNCTION This is a private method to evaluate the function.
% This method is called by the method run@Mio
% It returns a SimulationData and what is returned by the user script
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Run@Mio
%
% ==============================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% ==============================================================================      
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli Matteo Broggi

if Xmio.Liomatrix
    %% Function with Matrix

    % I am supposing that the matrix passed to runFunction is already in the
    % right format
    if isa(Psamples,'double')
        Minput=Psamples; %#ok<*NASGU>
    else
        % Convert the Psamples into a Matrix
        Minput = checkPinput(Xmio,Psamples);
    end
    % save the input data
    save(fullfile(OpenCossan.getCossanWorkingPath,'functioninput.mat'),'Minput')
elseif Xmio.Liostructure
    %% Function with Structure
    Tinput = checkPinput(Xmio,Psamples);    %check input
    % save the input data
    save(fullfile(OpenCossan.getCossanWorkingPath,'functioninput.mat'),'Tinput')
else
    %% Function with multiple vectors
    Cinput = checkPinput(Xmio,Psamples);
    % save the input data
    save(fullfile(OpenCossan.getCossanWorkingPath,'functioninput.mat'),'Cinput')
end
OpenCossan.cossanDisp(['[OpenCossan.connector.mio.run] .mat file with input for function ' ...
    fullfile(OpenCossan.getCossanWorkingPath,'functioninput.mat') ' successfully created'],4);

%% Create the function-wrapping script
OpenCossan.cossanDisp(['[OpenCossan.connector.mio.run] Creating the "function wrapping" script '...
    fullfile(OpenCossan.getCossanWorkingPath,['run_',Xmio.Sfile,'.m'])],4);
Nfid = fopen(fullfile(OpenCossan.getCossanWorkingPath,['run_',Xmio.Sfile]),'w');
%%
fprintf(Nfid,'%%%% Wrapping script. DO NOT EDIT!\n');

% assemble the string used to call the main function in a try-catch block
fprintf(Nfid,'%% initialize error variable\n');
fprintf(Nfid,'ME = [];\n');
fprintf(Nfid,'%% Add the location of the function to the path\n');
fprintf(Nfid,'addpath(''%s'');\n',Xmio.Spath);
fprintf(Nfid,'try\n');
fprintf(Nfid,'    load functioninput.mat\n');
if Xmio.Liomatrix
    Sfunctioncall = '    Moutput = ';
elseif Xmio.Liostructure
    Sfunctioncall = '    Toutput = ';
else
    Sfunctioncall = '    [';
    for iout = 1:length(Xmio.Coutputnames)-1
        Sfunctioncall = [Sfunctioncall, 'Moutput(:,' num2str(iout) '), ']; %#ok<AGROW>
    end
    Sfunctioncall=[Sfunctioncall 'Moutput(:,' num2str(length(Xmio.Coutputnames)) ')] ='];
end
Sfunctioncall = [Sfunctioncall,strrep(Xmio.Sfile,'.m','') '(']; % remove .m from the filename if present
if Xmio.Liomatrix
    Sfunctioncall = [Sfunctioncall,'Minput'];
elseif Xmio.Liostructure
    Sfunctioncall = [Sfunctioncall,'Tinput'];
else
    Sfunctioncall = [Sfunctioncall,'Cinput{:}'];
end
Sfunctioncall = [Sfunctioncall, ');\n'];
fprintf(Nfid,Sfunctioncall);
fprintf(Nfid,'catch ME\n');
fprintf(Nfid,'    display(''Error in function execution'');\n');
fprintf(Nfid,'end\n');
if Xmio.Liostructure 
    fprintf(Nfid,'save functionoutput.mat Toutput ME\n');
else
    fprintf(Nfid,'save functionoutput.mat Moutput ME\n');
end
fprintf(Nfid,'exit;\n');
%%
fclose(Nfid);
%% Call matlab to execute the function
if isunix
    Ssystemcall = ['cd ' OpenCossan.getCossanWorkingPath '; '...
        strrep(fullfile(OpenCossan.getMatlabPath,'bin','matlab'),' ','\\ ') ...
        ' -r ' ['run_',strrep(Xmio.Sfile,'.m','')] ' -nosplash -nodesktop'];
elseif ispc
    SworkPath = OpenCossan.getCossanWorkingPath; 
    Ssystemcall=[SworkPath(1:2) ' && cd "' SworkPath '" && "'...
        fullfile(OpenCossan.getMatlabPath,'bin','matlab') '" -r ' ...
        ['run_',strrep(Xmio.Sfile,'.m','')] ' -nosplash -nodesktop -wait'];
end
OpenCossan.cossanDisp('[OpenCossan.connector.mio.run] MATLAB invocation command: ',4);
OpenCossan.cossanDisp(Ssystemcall,4);
status = system(Ssystemcall);
OpenCossan.cossanDisp(['[OpenCossan.connector.mio.run] MATLAB executed wih exit status: ' num2str(status)],4);
assert(status==0,'OpenCossan:connector:mio:run',...
    'Error calling matlab for the execution of the Mio Function')

try
    load(fullfile(OpenCossan.getCossanWorkingPath,'functionoutput.mat'))
    delete(fullfile(OpenCossan.getCossanWorkingPath,'functionoutput.mat'));
catch message
    error('openCOSSAN:connectors:mio:run',...
        'Error loading outputs from .mat');
end

% clean the files
delete(fullfile(OpenCossan.getCossanWorkingPath,'functioninput.mat'));
delete(fullfile(OpenCossan.getCossanWorkingPath,['run_',Xmio.Sfile]));

if ~isempty(ME) 
    % if there was an error in the function execution, rethrow it
    error('openCOSSAN:connectors:mio:run',...
        strcat('The user define function can not be evaluate.! \n', ...
        'Please check your function or script!!!\n ',...
        '* Error msg: %s\n* Filename : %s\n* Line num : %i'), ...
        ME.message,ME.stack(1).name,ME.stack(1).line)
else
    % delete the unused ME variable if empty
    clear('ME');
end


%% Prepare the output

if Xmio.Liomatrix || ~Xmio.Liostructure
    Poutput = Moutput;
else
    Poutput = Toutput;
end

