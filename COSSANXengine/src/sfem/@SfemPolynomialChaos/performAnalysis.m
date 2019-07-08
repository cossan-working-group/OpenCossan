function Xoutput_SFEM=performAnalysis(Xobj)
%PERFORMANALYSIS Summary of this function goes here
%   Detailed explanation goes here

%execute everything in a subfolder please!!!
mkdir(fullfile(OpenCossan.getCossanWorkingPath,'SfemExecution'));
SoriginalWorkingPath = OpenCossan.getCossanWorkingPath;
OpenCossan.setWorkingPath(fullfile(SoriginalWorkingPath,'SfemExecution'));

% Prepare Input Files
if strcmpi(Xobj.Smethod,'Galerkin') && strcmpi(Xobj.Simplementation,'Regular')...
        && Xobj.Ltransfercompleted == false && Xobj.Lfesolverexecuted == false...
        && strcmpi(Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype(1:5),'nastr')
    Xobj=prepareInputFilesNASTRANRegular(Xobj);
elseif strcmpi(Xobj.Smethod,'Galerkin') && strcmpi(Xobj.Simplementation,'Componentwise')...
        && Xobj.Ltransfercompleted == false && Xobj.Lfesolverexecuted == false...
        && strcmpi(Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype(1:5),'nastr')
    Xobj=prepareInputFilesNASTRANComponentwise(Xobj);
elseif strcmpi(Xobj.Smethod,'Galerkin') && strcmpi(Xobj.Simplementation,'Regular')...
        && Xobj.Ltransfercompleted == false && Xobj.Lfesolverexecuted == false...
        && strcmpi(Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype,'ansys')
    Xobj=prepareInputFilesANSYS(Xobj);
elseif strcmpi(Xobj.Smethod,'Galerkin') && strcmpi(Xobj.Simplementation,'Regular')...
        && Xobj.Ltransfercompleted == false && Xobj.Lfesolverexecuted == false...
        && strcmpi(Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype,'abaqus')
    Xobj=prepareInputFilesABAQUS(Xobj);
elseif strcmpi(Xobj.Smethod,'Guyan') && Xobj.Ltransfercompleted == false && Xobj.Lfesolverexecuted == false
    Xobj=prepareInputFilesForGuyan(Xobj);
end
% run the FE solver (first check if the FE analysis is already done)
if ~strcmpi(Xobj.Smethod,'Collocation')
    if Xobj.Lfesolverexecuted == false && Xobj.Ltransfercompleted == false
        % Check if a Grid is defined
        XsfemGrid = Xobj.Xmodel.Xevaluator.getJobManager(...
            'SsolverName',Xobj.Xmodel.Xevaluator.CSnames{1});
        if isempty(XsfemGrid)
            Xobj = runFESolverSequential(Xobj);
        else
            Xobj = runFESolverParallel(Xobj);
        end
    end
end
% Transfer System Quantities to MATLAB
if ~strcmpi(Xobj.Smethod,'Collocation')
    if Xobj.Ltransfercompleted == false
        Xobj = transferSystemQuantities(Xobj);
    else
        if exist('SFEM.mat','file') ~= 2
            error('COSSAN:SfemPolynomialChaos',...
                'Please make sure that the SFEM.mat exists');
        end
        load SFEM
    end
end
if ~strcmpi(Xobj.Smethod,'Collocation')
    Xobj = calculateDerivatives(Xobj);
end
% Estimate the Response Statistics
Xoutput_SFEM = postprocess(Xobj);

% reset working path
OpenCossan.setWorkingPath(SoriginalWorkingPath)
end



