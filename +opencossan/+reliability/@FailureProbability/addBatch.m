function Xobj = addBatch(Xobj,varargin)
%addBatch method of FailureProbability class
% This method add a new estimation of the failure probability (i.e. a batch)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/addBatch@FailureProbability
%
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli

import opencossan.*

%% Validate input arguments

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case ('pf')
            pf=varargin{k+1};
        case ('variancepf')
            variancePf=varargin{k+1};
        case ('secondmoment')
            secondMoment=varargin{k+1};
        case ('nsamples')
            Nsamples=varargin{k+1};
        case {'xsimulationdata','xsimulationoutput'}
            Xsimout=varargin{k+1};
            assert(isa(Xsimout,'opencossan.common.outputs.SimulationData'), ...
                'openCOSSAN:FailureProbability',...
                'The object of class %s is not valid after the argument %s',...
                class(Xsimout),varargin{k})
        otherwise
            error('openCOSSAN:outputs:FailureProbability:addBatch',...
                ['Input argument (' varargin{k} ') not allowed'])
    end
end


% Increse the number of batches
ibatch=Xobj.Nbatches+1;

if exist('Xsimout','var')
    % Retrive performancefunction
    Vg=Xsimout.getValues('Sname',Xobj.SperformanceFunction);
    
    % Retrive weigths
    if strcmp(Xobj.Smethod,'ImportanceSampling')
        if isempty(Xobj.SweigthsName)
            error('openCOSSAN:outputs:FailureProbability:addBatch',...
                'The name of the weights of the samples must be provided')
        end
        Vweights=Xsimout.getValues('Sname',Xobj.SweigthsName);
    else
        Vweights=ones(Xsimout.Nsamples,1);
    end
    
    % keep track of the number of samples
    Xobj.Vsamples(ibatch) = Xsimout.Nsamples;
    
    
    % Molpiply the weight for the Indicator Function
    if ~isempty(Xobj.stdDeviationIndicatorFunction)
        % In case the Heaviside indicator function is replaced by a smooth one
        Vweights=Vweights.*(normcdf(-Vg,0,Xobj.stdDeviationIndicatorFunction));
    else
        % The weights are zeros when the performace function is negative
        Vweights=Vweights.*(Vg<0);
    end
    
    % Compute pfhat
    Xobj.Vpf(ibatch) = sum(Vweights) /Xobj.Vsamples(ibatch);
    
    % Compute the variance of the estimator
    Xobj.VvariancePf(ibatch) =var(Vweights.*(Vg<0))/Xobj.Vsamples(ibatch);
    
    % Compute the variance of the quantity of interest (secondMoment)
    Xobj.VsecondMoment(ibatch) =var(Vweights.*(Vg<0));
    
else
    % Check if all the parameters exist
    if ~exist('pf','var')
        error('openCOSSAN:outputs:FailureProbability:addBatch',...
            'I can not add a new batch: pf must be provided')
    end
    
    if ~exist('variancePf','var')
        error('openCOSSAN:outputs:FailureProbability:addBatch',...
            'I can not add a new batch: variance of the failure probability must be provided')
    end
    
    if ~exist('Nsamples','var')
        error('openCOSSAN:outputs:FailureProbability:addBatch',...
            'I can not add a new batch: Nsamples must be provided')
    end
    
    if exist('secondMoment','var')
        Xobj.VsecondMoment(ibatch)=secondMoment;
    else
        Xobj.VsecondMoment(ibatch)=NaN;
    end
    
    Xobj.Vsamples(ibatch)=Nsamples;
    Xobj.Vpf(ibatch)=pf;
    Xobj.VvariancePf(ibatch)=variancePf;
    
    
end


