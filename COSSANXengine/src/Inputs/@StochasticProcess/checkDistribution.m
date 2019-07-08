function Xobj=checkDistribution(Xobj)   
%CHECKDISTRIBUTION  Private function for StochasticProcess
%
% Copyright 1993-2011, COSSAN Working Group, University of Innsbruck, Austria

if isempty(Xobj.Sdistribution), return, end
%% Compute the missing values if possible
    switch lower(Xobj.Sdistribution)
         case {'norm','normal','whitenoise'}
%             Xobj=normal(Xobj);
        otherwise
            error('openCOSSAN:StochasticProcess:checkDistribution',...
                'Distribution %s not yet implemented',Xobj.Sdistribution);
    end
    
end
