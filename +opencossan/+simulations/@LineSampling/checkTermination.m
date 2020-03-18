function [exit, flag] = checkTermination(obj, varargin)
    % checkTermination Protected method of simulation used to check the termination criteria of the
    % simulation.
    %
    % Copyright 1993-2017, COSSAN Working Group Author: Edoardo-Patelli
    
    import opencossan.OpenCossan
    
    [exit, flag] = checkTermination@opencossan.simulations.Simulations(obj, varargin{:});
    
    if exit
        return
    end
    
    optional = opencossan.common.utilities.parseOptionalNameValuePairs(...
        "batch", {[]}, varargin{:});
    
    if optional.batch >= obj.NumberOfBatches
        flag = 'Maximum number of batches reached.';
        exit = true;
    end
    
    if exit
        classes = metaclass(obj);
        classname = split(classes.Name, '.');
        classname = classname{end};
        OpenCossan.cossanDisp(sprintf("[%s] %s\n", classname, flag), 1);
    end
end