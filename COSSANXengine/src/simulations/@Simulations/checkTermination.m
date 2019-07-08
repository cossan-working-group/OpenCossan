function SexitFlag=checkTermination(Xobj,Xresults)
% checkTermination Protected method of simulation used to check the termination criteria of
% the simulation. The method requires as input argument an object of type
% SimulationObject or FailureProbability and a string that
% is not empty if the termination criteria is reached.
%
% Copyright 1993-2011, COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo-Patelli

% Initialize variables
SexitFlag=[];

%% Termination criteria KILL (from GUI)
% Check if the file name KILL exists in the working directory
if exist(fullfile(OpenCossan.getCossanWorkingPath,OpenCossan.getKillFilename),'file')
    SexitFlag='Analysis terminated by the user';
    OpenCossan.cossanDisp(SexitFlag,1);
    return
end

%% Termination criteria TIMEOUT
% Exide maximum computational time
if ~isempty(Xobj.timeout) && Xobj.timeout>0
    if OpenCossan.getDeltaTime(Xobj.initialLaptime) > Xobj.timeout
        SexitFlag=['Maximum execution time reached. Enlapsed time ' ...
            num2str(OpenCossan.getDeltaTime(Xobj.initialLaptime)) ...
            ' from lap # ' num2str(Xobj.initialLaptime) ...
            '; Maximum allowed time: ' num2str(Xobj.timeout)];
        OpenCossan.cossanDisp(SexitFlag,3);
        return
    end
end

%% Termination criteria MAXIMUM SAMPLES
% Exceed maximum number of samples
if ~isempty(Xobj.Nsamples)
    if Xobj.Nsamples>0
        if Xobj.isamples >= Xobj.Nsamples
            SexitFlag=['Maximum no. of samples reached. ' ...
                'Samples computed ' num2str(Xobj.isamples) ...
                '; Maximum allowed samples: ' num2str( Xobj.Nsamples)];
            OpenCossan.cossanDisp(SexitFlag,3);
            return
        end
    end
end

%% Termination criteria ACCURACY
if isa(Xresults,'FailureProbability')
    % Convergernce criteria for the coefficient of variation (CoV) reached.
    if ~isempty(Xobj.CoV)
        if Xresults.cov~=0 && Xresults.cov <= Xobj.CoV,
            SexitFlag=['Target CoV level reached. ' ...
                'Coefficient of Variation computed ' num2str(Xresults.cov) ...
                '; Target threshold: ' num2str(Xobj.CoV)];
            OpenCossan.cossanDisp(SexitFlag,3);
            return
        end
    end
    
    %% Check maximum number of Lines
    if isa(Xobj,'LineSampling') || isa(Xobj,'AdaptiveLineSampling')
        if ~isempty(Xobj.Nlines)
            if Xobj.Nlines>0
                if Xresults.Nlines>= Xobj.Nlines
                    SexitFlag=['Maximum no. of lines reached. ' ...
                        'Lines computed ' num2str(Xresults.Nlines) ...
                        '; Max Lines : ' num2str(Xobj.Nlines)];
                    OpenCossan.cossanDisp(SexitFlag,3);
                end
            end
        end
    end
end

%% Check maximum number of batches (SubSet only)
if isa(Xobj,'SubSet')
    if ~isempty(Xresults.Nbatches)
        if Xresults.Nbatches>0
            if Xresults.Nbatches>= Xobj.Nbatches
                SexitFlag=['Maximum no. of batches reached. ' ...
                    'Batches computed ' num2str(Xresults.Nbatches) ...
                    '; Max batches : ' num2str(Xobj.Nbatches)];
                OpenCossan.cossanDisp(SexitFlag,3);
            end
        end
    end
end


