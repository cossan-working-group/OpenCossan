function MX = getSampleMatrix(Xinput,varargin)
%GETSAMPLEMATRIX Get samples in a matrix format of the variables defined in the
%Input object
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

OpenCossan.validateCossanInputs(varargin{:});

if ~isempty(fieldnames(Xinput.Xsp))
    warning('openCOSSAN:Input:getSampleMatrix',...
        'the sample of StochasticProcess objects are not in the matrix');
    
end

if isa(Xinput.Xsamples,'Samples')
    Msamples  = Xinput.Xsamples.MsamplesPhysicalSpace;
    Mdoe      = Xinput.Xsamples.MdoeDesignVariables;
    
    if isempty(Msamples)
        MX      = Mdoe;
    elseif isempty(Mdoe)
        MX      = Msamples;
    else
        assert(size(Msamples,1)==size(Mdoe,1), ...
        'openCOSSAN:Input:getSampleMatrix', ...
        'Number of samples of the random variables (%i) does not agree with the number of samples of the design variables (%i)', ...
        size(Msamples,2),size(Mdoe,2))
    MX = [Msamples Mdoe];
    end
 
end


return
