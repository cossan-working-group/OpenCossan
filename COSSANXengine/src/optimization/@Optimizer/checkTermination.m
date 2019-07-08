function [Lstop,SexitFlag]=checkTermination(Xobj,Xresults)
% checkTermination This protected method of the Optimizer object is used to
% check the termination criteria of the optimization procedure. 

% Initialize variables
global OPENCOSSAN

SexitFlag=[];
Lstop=false;

%% Termination criteria KILL (from GUI)
% Check if the file name KILL exists in the working directory
if exist(fullfile(OpenCossan.getCossanWorkingPath,OPENCOSSAN.Skillfilename),'file')
    Lstop=true;
    delete(fullfile(OpenCossan.getCossanWorkingPath,OPENCOSSAN.Skillfilename))
    SexitFlag='Analysis terminated by the user';
    OpenCossan.cossanDisp(SexitFlag,1);
    return
end

%% Termination criteria TIMEOUT
% Excide maximum computational time
if ~isempty(Xobj.timeout)
    if Xobj.timeout>0
        if OpenCossan.getDeltaTime(Xobj.initialLaptime) > Xobj.timeout
            Lstop=true;
            SexitFlag=['Maximum execution time reached. Enlapsed time ' ...
            num2str(OpenCossan.getDeltaTime(Xobj.initialLaptime)) ...
                ' from lap # ' num2str(Xobj.initialLaptime) ...
                '; Maximum allowed time: ' num2str(Xobj.timeout)];
            return
        end
    end
end

%% Termination criteria MAXIMUM Iteration
% Exceed maximum number of samples
if ~isempty(Xobj.NmaxIterations)
    if Xobj.NmaxIterations>0
        if Xresults.Niterations >= Xobj.NmaxIterations
            SexitFlag='Maximum number of iterations reached';
            Lstop=true;
            return
        end
    end
end

%% Termination criteria MAXIMUM model evaluation
% Exceed maximum number of samples
if ~isempty(Xobj.Nmax)
    if Xobj.Nmax>0
        if Xresults.NevaluationsModel >= Xobj.Nmax
            SexitFlag='Maximum number of Model evaluations reached';
            Lstop=true;
            return
        end
    end
end

%% Termination criteria MAXIMUM function evaluation
% Exceed maximum number of samples
if ~isempty(Xobj.Nmax)
    if Xobj.Nmax>0
        if (Xresults.NevaluationsObjectiveFunctions+Xresults.NevaluationsConstraints) >= Xobj.NmaxFunctions
            SexitFlag='Maximum number of Function evaluations reached';
            Lstop=true;
            return
        end
    end
end

