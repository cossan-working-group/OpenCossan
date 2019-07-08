function  [Xopt, varargout]  = optimizeDirectApproach(Xobj,varargin)
%OPTIMIZEDIRECTAPPROACH This function perform RBO optimization using a direct
%approach 
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/OptimizeDirectApproach@RBOproblem

% Copyright  1993-2011 University of Innsbruck,
% Author: Edoardo Patelli


%% Default values
Carguments{1}='XOptimizationProblem';
Carguments{2}=Xobj;

%% Process inputs
% validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

% Process arguments
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'xoptimizer'
            Xoptimizer=varargin{k+1};
        case 'cxoptimizer'
            Xoptimizer=varargin{k+1}{1};
        otherwise
            Carguments{end+1}=varargin{k}; %#ok<AGROW>
            Carguments{end+1}=varargin{k+1}; %#ok<AGROW>
    end
end

%% Perform optimization
% If the metamodel has not been created the direct approach is used
[Xopt, XSimOutput]  = Xoptimizer.apply('XOptimizationProblem',Xobj,Carguments{:});

if nargout>1
    varargout{1}=XSimOutput;
end

