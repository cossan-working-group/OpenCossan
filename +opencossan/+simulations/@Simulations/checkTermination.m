function [exit, flag] = checkTermination(obj, data)
    % checkTermination Protected method of simulation used to check the termination criteria of the
    % simulation. The method requires as input argument an object of type SimulationObject or
    % FailureProbability and a string that is not empty if the termination criteria is reached.
    %
    % Copyright 1993-2017, COSSAN Working Group Author: Edoardo-Patelli
    
    import opencossan.OpenCossan
    
    exit = false;
    flag = "";
    
    %% Termination criteria KILL (from GUI)
    % Check if the file name KILL exists in the working directory
    if exist(fullfile(OpenCossan.getWorkingPath,OpenCossan.getInstance().KillFileName),'file')
        flag = 'Analysis terminated by the user.';
        exit = true;
        OpenCossan.cossanDisp(flag, 1);
        return
    end
    
    % Check number of batches
    if max(data.Samples.Batch) == obj.Nbatches
        flag = 'Maximum number of batches reached.';
        exit = true;
        OpenCossan.cossanDisp(flag, 1);
    end
    
    %
    % %% Termination criteria TIMEOUT % Exide maximum computational time if ~isempty(obj.timeout) &&
    % obj.timeout>0
    %     timer = OpenCossan.getTimer(); if timer.delta(obj.initialLaptime) > obj.timeout
    %         SexitFlag=['Maximum execution time reached. Enlapsed time ' ...
    %             num2str(timer.delta(obj.initialLaptime)) ... ' from lap # '
    %             num2str(obj.initialLaptime) ... '; Maximum allowed time: ' num2str(obj.timeout)];
    %         OpenCossan.cossanDisp(SexitFlag,3); return
    %     end
    % end
    %
    % %% Termination criteria MAXIMUM SAMPLES % Exceed maximum number of samples if
    % ~isempty(obj.Nsamples)
    %     if obj.Nsamples>0
    %         if obj.isamples >= obj.Nsamples
    %             SexitFlag=['Maximum no. of samples reached. ' ...
    %                 'Samples computed ' num2str(obj.isamples) ... '; Maximum allowed samples: '
    %                 num2str( obj.Nsamples)];
    %             OpenCossan.cossanDisp(SexitFlag,3); return
    %         end
    %     end
    % end
    %
    % %% Termination criteria ACCURACY if isa(data,'opencossan.reliability.FailureProbability')
    %     % Convergernce criteria for the coefficient of variation (CoV) reached. if
    %     ~isempty(obj.CoV)
    %         if data.cov~=0 && data.cov <= obj.CoV,
    %             SexitFlag=['Target CoV level reached. ' ...
    %                 'Coefficient of Variation computed ' num2str(data.cov) ... '; Target
    %                 threshold: ' num2str(obj.CoV)];
    %             OpenCossan.cossanDisp(SexitFlag,3); return
    %         end
    %     end
    %
    %     %% Check maximum number of Lines if isa(obj,'opencossan.simulations.LineSampling') ||
    %     isa(obj,'opencossan.simulations.AdaptiveLineSampling')
    %         if ~isempty(obj.Nlines)
    %             if obj.Nlines>0
    %                 if data.Nlines>= obj.Nlines
    %                     SexitFlag=['Maximum no. of lines reached. ' ...
    %                         'Lines computed ' num2str(data.Nlines) ... '; Max Lines : '
    %                         num2str(obj.Nlines)];
    %                     OpenCossan.cossanDisp(SexitFlag,3);
    %                 end
    %             end
    %         end
    %     end
    % end
    %
    % %% Check maximum number of batches (SubSet only) if
    % isa(obj,'opencossan.simulations.SubsetOriginal') ||
    % isa(obj,'opencossan.simulations.SubsetInfinite')
    %     if ~isempty(data.Nbatches)
    %         if data.Nbatches>0
    %             if data.Nbatches>= obj.Nbatches
    %                 SexitFlag=['Maximum no. of batches reached. ' ...
    %                     'Batches computed ' num2str(data.Nbatches) ... '; Max batches : '
    %                     num2str(obj.Nbatches)];
    %                 OpenCossan.cossanDisp(SexitFlag,3);
    %             end
    %         end
    %     end
    % end
    
    
end