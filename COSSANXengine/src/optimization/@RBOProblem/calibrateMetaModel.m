function Xobj=calibrateMetaModel(Xobj,varargin)
%CALIBRATEMETAMODEL This method is used to replace the model defined in the
%RBOproblem object with a metamodel.
% This method requires the same arguments required by the metamodel plus
% Smetamodeltype and Xsimulator
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/CalibrateMetaModel@RBOproblem
%
% =========================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =========================================================================


OpenCossan.validateCossanInputs(varargin{:})

Carguments=[];

%% Process inputs arguments
for k=1:2:length(varargin),
    switch lower(varargin{k}),
        case 'smetamodeltype'
            Smetamodeltype   = varargin{k+1};
        case 'xsimulator'
            Xsimulator= varargin{k+1};
        case 'xfullmodel'
            Xmodel=varargin{k+1};
        otherwise
           Carguments{end+1}=varargin{k}; %#ok<*AGROW>
           Carguments{end+1}=varargin{k+1};
    end
end

% Pass the full model
Carguments{end+1}='XfullModel';
if ~exist('Xmodel','var')
   Carguments{end+1}=Xobj.Xmodel;
else
   Carguments{end+1}=Xmodel; 
end

% Pass the output name
Carguments{end+1}='Coutputnames';
Carguments{end+1}={Xobj.SfailureProbabilityName};

switch Smetamodeltype
    case 'ResponseSurface'
        Xmetamodel  = ResponseSurface('Sdescription',...
            'Response Surface created by calibrateMetaModel@RBOproblem',...
            Carguments{:});
    case 'NeuralNetwork'
        Xmetamodel  = NeuralNetwork('Sdescription',...
            'ANN created by calibrateMetaModel@RBOproblem',...
            Carguments{:});
    otherwise
        error('openCOSSAN:RBOproblem:calibrateMetaModel',...
            'MetaModel type %s is not valid',Smetamodeltype);
end

Xmetamodel=Xmetamodel.calibrate('Xsimulator',Xsimulator);

% Replace Full model with the MetaModel
Xobj.Xmodel=Xmetamodel;
