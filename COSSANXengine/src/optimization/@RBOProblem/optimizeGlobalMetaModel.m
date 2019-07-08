function  [Xopt, varargout]  = optimizeGlobalMetaModel(Xobj,varargin)
%OPTIMIZEGLOBALMETAMODEL This function overwrite the optimization method of the
%OptimizationProblem.
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/OptimizeGlobalMetaModel@RBOproblem
%
% Copyright  1993-2011 University of Innsbruck,
% Author: Edoardo Patelli


%% Default values
CargumentsMetaModel=Xobj.CmetamodelProperties;
CargumentsOptimizer={};

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
        case 'smetamodeltype'
            Xobj.SmetamodelType=varargin{k+1};
        case 'xsimulator'
            Xobj.Xsimulator=varargin{k+1};
        case 'cxsimulator'
            Xobj.Xsimulator=varargin{k+1}{1};
        case 'vperturbation'
            Xobj.VperturbationSize=varargin{k+1};
        case {'vinitialsolution','xoptimum','minitialsolutions'}
            CargumentsOptimizer{end+1}=varargin{k}; %#ok<AGROW>
            CargumentsOptimizer{end+1}=varargin{k+1}; %#ok<AGROW>
        otherwise
            CargumentsMetaModel{end+1}=varargin{k}; %#ok<AGROW>
            CargumentsMetaModel{end+1}=varargin{k+1}; %#ok<AGROW>
    end
end

assert(logical(~isempty(Xobj.SmetamodelType)),...
    'openCOSSAN:RBOproblem:optimizeGlobalMetaModel',...
    'It is necessry to define a metamodel type to perform an optimization using global metamodel')


%% Perform Optimization Using global Meta-Model
assert(logical(~isempty(Xobj.Xsimulator)),...
    'openCOSSAN:RBOproblem:optimizeGlobalMetaModel',...
    strcat('It is necessary to specify a Simulation object of a ', ...
    'DesignOfExperiments in order to train the metamodel'))

%% Global MetaModel
CargumentsMetaModel{end+1}='SmetamodelType';
CargumentsMetaModel{end+1}=Xobj.SmetamodelType;
CargumentsMetaModel{end+1}='Xsimulator';
CargumentsMetaModel{end+1}=Xobj.Xsimulator;
CargumentsMetaModel{end+1}='XFullModel';
CargumentsMetaModel{end+1}=Xobj.Xmodel;

%% Check if the DV are unbounded
Xobj=Xobj.calibrateMetaModel(CargumentsMetaModel{:});

CargumentsOptimizer{end+1}='XOptimizationProblem';
CargumentsOptimizer{end+1}=Xobj;


%% Perform optimization
% If the metamodel has not been created the direct approach is used
[Xopt, XSimOutput]  = Xoptimizer.apply(CargumentsOptimizer{:});

if nargout>1
    varargout{1}=XSimOutput;
end

