function  [Xresults, varargout]  = extremize(Xobj,varargin)
%OPTIMIZE This method is a common interface for different reliability based
%optimization approaches. 
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Optimize@ExtremeCase



%% Process inputs
% validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

global NiterationsEC NevaluationsEC MstatePointsEC MfailurePointsEC

%% Process inputs
% validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

% Process agreements
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'xoptimizer'
            Xoptimizer=varargin{k+1};
        otherwise
            error('openCOSSAN:ExtremeCase:optimize', ...
                            ['The PropertyName ' varargin{k} ' is not valid']);
    end
end

%% Perform many optimizations
if isa(Xoptimizer,'LatinHypercubeSampling') || isa(Xoptimizer,'MonteCarlo')
    Xinput=Xoptimizer.sample('Xinput',Xobj.Xinput);
    Xresults  = Xobj.Xmodel.apply(Xinput);
else
    Xresults  = Xoptimizer.apply('XOptimizationProblem',Xobj);
end


% Assign the outputs as requested
Coutputs={MstatePointsExtremeCase,MfailurePointsExtremeCase,NiterationsExtremeCase,NevaluationsExtremeCase};
for n=1:nargout-1
    varargout{n}=Coutputs{n};
end

clear('global','MstatePointsExtremeCase','MfailurePointsExtremeCase','NiterationsExtremeCase','NevaluationsExtremeCase')
end % of optimize
