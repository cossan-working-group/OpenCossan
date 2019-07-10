function [Lstop,SexitFlag]=checkTermination(Xobj,Xresults)
% checkTermination This protected method of the Optimizer object is used to
% check the termination criteria of the optimization procedure. 

% Initialize variables
global OPENCOSSAN

SexitFlag=[];
Lstop=false;

%% Termination criteria KILL (from GUI)
% Check if the file name KILL exists in the working directory
if opencossan.OpenCossan.isKilled()
    Lstop=true;
    delete(fullfile(OpenCossan.getWorkingPath(),OPENCOSSAN.Skillfilename))
    SexitFlag='Analysis terminated by the user';
    OpenCossan.cossanDisp(SexitFlag,1);
    return
end

%% Termination criteria TIMEOUT
% Excide maximum computational time
if ~isempty(Xobj.Timeout)
    if Xobj.Timeout>0
        if opencossan.OpenCossan.getTimer().delta(Xobj.InitialLapTime) > Xobj.Timeout
            Lstop=true;
            SexitFlag=['Maximum execution time reached. Enlapsed time ' ...
            num2str(opencossan.OpenCossan.getTimer().delta(Xobj.InitialLapTime)) ...
                ' from lap # ' num2str(Xobj.InitialLapTime) ...
                '; Maximum allowed time: ' num2str(Xobj.Timeout)];
            return
        end
    end
end

%% Termination criteria MAXIMUM Iteration
% Exceed maximum number of samples
% if ~isempty(Xobj.MaximumIterations)
%     if Xobj.MaximumIterations>0
%         if Xresults.Niterations >= Xobj.MaximumIterations
%             SexitFlag='Maximum number of iterations reached';
%             Lstop=true;
%             return
%         end
%     end
% end

%% Termination criteria MAXIMUM model evaluation
% Exceed maximum number of samples
% if ~isempty(Xobj.MaximumModelEvaluations)
%     if Xobj.MaximumModelEvaluations > 0
%         if Xresults.NevaluationsModel >= Xobj.MaximumModelEvaluations
%             SexitFlag='Maximum number of Model evaluations reached';
%             Lstop=true;
%             return
%         end
%     end
% end

%% Termination criteria MAXIMUM function evaluation
% Exceed maximum number of samples
% if ~isempty(Xobj.MaximumFunctionEvaluations)
%     if Xobj.MaximumFunctionEvaluations>0
%         if (Xresults.NevaluationsObjectiveFunctions+Xresults.NevaluationsConstraints) >= Xobj.MaximumFunctionEvaluations
%             SexitFlag='Maximum number of Function evaluations reached';
%             Lstop=true;
%             return
%         end
%     end
% end

