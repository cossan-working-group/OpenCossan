function [exit, flag] = checkTermination(obj, varargin)
    % checkTermination Protected method of simulation used to check the termination criteria of the
    % simulation.
    % Copyright 1993-2017, COSSAN Working Group Author: Edoardo-Patelli
    
    import opencossan.OpenCossan
    
    optional = opencossan.common.utilities.parseOptionalNameValuePairs(...
        "cov", {[]}, varargin{:});
    
    exit = false;
    flag = "";
    
    % Termination criteria KILL (from GUI). Check if the file name KILL exists in the working 
    % directory.
    if isfile(fullfile(OpenCossan.getWorkingPath,OpenCossan.getInstance().KillFileName))
        flag = 'Analysis terminated by the user.';
        exit = true;
        OpenCossan.cossanDisp(flag, 1);
        return
    elseif obj.Timeout > 0 && toc(obj.StartTime) > obj.Timeout
        % Timeout reached
        flag = 'Maximum execution time reached.';
        exit = true;
        OpenCossan.cossanDisp(flag, 1);
    elseif optional.cov > 0 && optional.cov <= obj.CoV
        % Cov reached
        flag = 'Target CoV reached.';
        exit = true;
        
    end
    
    if exit
        classname = split(metaclass(obj).Name, '.');
        classname = classname{end};
        OpenCossan.cossanDisp(sprintf("[%s] %s\n", classname, flag), 1);
    end
end