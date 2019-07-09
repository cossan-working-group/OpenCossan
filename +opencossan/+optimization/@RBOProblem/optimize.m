function  [Xopt, varargout]  = optimize(Xobj,varargin)
%OPTIMIZE This method is a common interface for different reliability based
%optimization approaches. 
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Optimize@RBOproblem
%
% Copyright  1993-2011 University of Innsbruck,
% Author: Edoardo Patelli


%% Process inputs
% validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

% Process arguments
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'smetamodeltype'
            Xobj.SmetamodelType=varargin{k+1};
        case 'xsimulator'
            Xobj.Xsimulator=varargin{k+1};
        case 'cxsimulator'
            Xobj.Xsimulator=varargin{k+1}{1};
        case 'nmaxlocalrboiterations'
            Xobj.NmaxLocalRBOIteration=varargin{k+1};
        case 'vperturbation'
            Xobj.VperturbationSize=varargin{k+1};
    end
end

if ~isempty(Xobj.VperturbationSize) || ~isempty(Xobj.NmaxLocalRBOIteration)
    %% Perform Optimization Using local Meta-Model
    [Xopt, XSimOutput]= optimizeLocalMetaModel(Xobj,varargin{:});
else
    if ~isempty(Xobj.SmetamodelType)
       %% Perform Optimization Using global Meta-Model
        [Xopt, XSimOutput]= optimizeGlobalMetaModel(Xobj,varargin{:});
    else
       %% Perform Optimization Using direct approach 
       [Xopt, XSimOutput]= optimizeDirectApproach(Xobj,varargin{:});
    end   
end

if nargout>1
    varargout{1}=XSimOutput;
end

end % of optimize
