function Xobj = fileManagementXgrid(Xobj,Sfoldername,Smaininputfile)
%fileManagementXgrid
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/fileManagementXgrid@Nastsem
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

%% Retrieve input data
Xinp            = Xobj.Xmodel.Xinput;                                 % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in Nastsem.')

Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Xconnector      = Xobj.Xmodel.Xevaluator.CXsolvers{1};                % Obtain Connector object
Sfesolver       = Xconnector.Stype;                                   % Obtain FE solver type
[~,~]           = mkdir(Sfoldername);

if isa(Xobj,'Nastsem')
    if strcmpi(Xobj.Smethod,'perturbation')
        [~, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'dmap_perturbation.dat'),Sfoldername);
        for i = 1:(Nrvs+1)
           [~, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,['se' num2str(i) '.dat']),Sfoldername);
        end
    elseif strcmpi(Xobj.Smethod,'neumann')
        [~, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'dmap_neumann.dat'),Sfoldername);
        for i = 1:(Xobj.Nsimulations+1)
           [~, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,['se' num2str(i) '.dat']),Sfoldername);
        end
    end
    % Copy the input file to the directory
    [~, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,Smaininputfile),Sfoldername);
    [~, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'residual.dat'),Sfoldername);
    return
end

if strcmpi(Sfesolver(1:5),'nastr')
    % Copy the DMAP codes to the directory
    for i=1:length(Xobj.CdmapFileNames)
        [status, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,Xobj.CdmapFileNames{i}),Sfoldername);
        if status == 0
            error('openCOSSAN:SFEM:fileManagementXgrid','[SFEM.runFESolverParallel] DMAP code could not be copied');
        elseif status == 1
            OpenCossan.cossanDisp(['[SFEM.fileManagementXgrid] ' Xobj.CdmapFileNames{i} ' copied successfully'],3);
        end
    end
    [~, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,'constant.dat'),Sfoldername);

end

% Copy the input file to the directory
[~, ~] = copyfile(fullfile(OpenCossan.getCossanWorkingPath,Smaininputfile),Sfoldername);

return
