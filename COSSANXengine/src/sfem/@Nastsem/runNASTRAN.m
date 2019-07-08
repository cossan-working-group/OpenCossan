function runNASTRAN(Xobj)
%RUNNASTRAN   Calls NASTRAN to perform the analysis for the prepared SFEM problem
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/runNASTRAN@Nastsem
%
% =========================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =========================================================================

%% Retrieve input data

Xconnector = Xobj.Xmodel.Xevaluator.CXsolvers{1};                % Obtain Connector object
XsfemGrid  = Xobj.Xmodel.Xevaluator.getJobManager(...            % Obtain the Grid
             'SsolverName',Xobj.Xmodel.Xevaluator.CSnames{1});   
         
   
%% Execute NASTRAN
Xconnector.Ltimestamp=false; % Force the connector to not create a time-stamped folder!!!! DEPRECATED!!!!
% This is an hack because this code sucks!
Xconnector.Sworkingdirectory=OpenCossan.getCossanWorkingPath;
Xconnector.Smaininputfile='maininput.dat';
% on the local PC
if isempty(XsfemGrid)
    OpenCossan.cossanDisp('[Nastsem.runNASTRAN] Local execution of the maininput.dat file started ',1);
    % perform analysis for the nominal model (This is done without Xgrid)
    [~,~,LerrorFound]=Xconnector.deterministicAnalysis;
    assert(~LerrorFound,'CossanX:SFEM','Failed to execute FE solver.')
    % using Xgrid
else
    XsfemGrid.Sfoldername        = datestr(now,30);
    XsfemGrid.Sworkingdirectory  = Xconnector.Sworkingdirectory;
    XsfemGrid.Smaininputpath     = OpenCossan.getCossanWorkingPath;
    Xconnector.Sworkingdirectory = fullfile(OpenCossan.getCossanWorkingPath,[XsfemGrid.Sfoldername '_sfem' ]);
    XsfemGrid.Sexecmd            = Xconnector.SexecutionCommand;   
    Xobj                         = fileManagementXgrid(Xobj,Xconnector.Sworkingdirectory,...
                                                               Xconnector.Smaininputfile);
    % Submit the job
    CSjobID(1) = XsfemGrid.submitJob('nsimulationnumber',1,'Sfoldername',[XsfemGrid.Sfoldername '_sfem']);
    Lcompleted=false(size(CSjobID,1),1);
    while ~all(Lcompleted==1)
        pause(Xconnector.sleepTime);
        Cstatus(~Lcompleted,:) = XsfemGrid.getJobStatus('CSjobID',CSjobID(~Lcompleted)); %#ok<AGROW>
        Lcompleted = ~(strcmp('running',Cstatus(:,1))|strcmp('pending',Cstatus(:,1)));
    end
    % Check for errors
    Cstatus = XsfemGrid.getJobStatus('CSjobID',CSjobID);
    % check for completed status
    Lcheck = strcmp('completed',Cstatus(:,1));
    if all(Lcheck==1)
        OpenCossan.cossanDisp('[Nastsem.runNASTRAN] job completed',2);
        OpenCossan.cossanDisp(' ',2);
    else
        OpenCossan.cossanDisp('[Nastsem.runNASTRAN] job returned with error',2);
        OpenCossan.cossanDisp(' ',2);
    end
    [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,[XsfemGrid.Sfoldername '_sfem'],'*.op4'),OpenCossan.getCossanWorkingPath);
    if status == 0
        error('openCOSSAN:NASTSEM','[Nastsem.runNASTRAN] OP4 file could not be copied');
    elseif status == 1
        OpenCossan.cossanDisp('[Nastsem.runNASTRAN] OP4 file copied successfully',3);
    end
    [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,[XsfemGrid.Sfoldername '_sfem'],'*.PCH'),OpenCossan.getCossanWorkingPath);
    if status == 0
        error('openCOSSAN:NASTSEM','[Nastsem.runNASTRAN] PCH file could not be copied');
    elseif status == 1
        OpenCossan.cossanDisp('[Nastsem.runNASTRAN] PCH file copied successfully',3);
    end
end

%%  clean files

if Xobj.Lcleanfiles
    warning('openCOSSAN:NASTSEM','Cleaning the working directory without carying about other important files (thanks to HMP)')
    [~,Sfilename] = fileparts(Xconnector.Smaininputfile);
    delete(fullfile(OpenCossan.getCossanWorkingPath,[Sfilename '.f06']));
    delete(fullfile(OpenCossan.getCossanWorkingPath,[Sfilename '.f04']));
    delete(fullfile(OpenCossan.getCossanWorkingPath,[Sfilename '.log']));
    delete(fullfile(OpenCossan.getCossanWorkingPath, 'runJob*.sh'));
end

return
