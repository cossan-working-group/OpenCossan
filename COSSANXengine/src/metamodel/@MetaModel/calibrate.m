function [Xobj varargout] = calibrate(Xobj,varargin)
%calibrate
%
%   This method computes the coefficients associated with the
%   MetaModel based on the information passed by the user. Once the
%   MetaModel object is calibrated, it can be used for prediction
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Calibrate@ResponseSurface
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria$

%% Argument Check

% Check varargin
OpenCossan.validateCossanInputs(varargin{:})

%% Parse varargin input
for k=1:2:length(varargin)
    switch lower(varargin{k}),
        % Number of samples to calibrate MetaModel
        case {'xsimulator','cxsimulator'}
            if isa(varargin{k+1},'cell')
                Xsimulator  = varargin{k+1}{1};
            else
                Xsimulator  = varargin{k+1};
            end
            assert(isa(Xsimulator,'Simulations'), ...
                'openCOSSAN:MetaModel:calibrate',...
                'PropertyName %s must be an object of the subclasses of Simulations',varargin{k});
            
        case{'xcalibrationinput','cxcalibrationinput'},
            
            if isa(varargin{k+1},'cell')
                Xobj.XcalibrationInput  = varargin{k+1}{1};
            else
                Xobj.XcalibrationInput  = varargin{k+1};
            end
            
            assert(isa(Xobj.XcalibrationInput,'Input'), ...
                'openCOSSAN:MetaModel:calibrate',...
                'PropertyName %s must be an object of type Input',varargin{k});
            
        case{'xcalibrationoutput','cxcalibrationoutput'}
            if isa(varargin{k+1},'cell')
                Xobj.XcalibrationOutput  = varargin{k+1}{1};
            else
                Xobj.XcalibrationOutput  = varargin{k+1};
            end
            
            assert(isa(Xobj.XcalibrationOutput,'SimulationData'), ...
                'openCOSSAN:MetaModel:calibrate',...
                'PropertyName %s must be an object of type SimulationData',varargin{k});
        case{'xsimulationdata','cxsimulationdata'}
            if isa(varargin{k+1},'cell')
                XsimData  = varargin{k+1}{1};
            else
                XsimData  = varargin{k+1};
            end
                        
            assert(isa(XsimData,'SimulationData'), ...
                'openCOSSAN:MetaModel:calibrate',...
                'Object of class %s not valid after the property name %s',class(XsimData),varargin{k});
            
            % Create calibration Input/Output
            Xobj.XcalibrationOutput=XsimData.split('Cmembers',Xobj.Coutputnames); 
            
            Xinput=Xobj.XFullmodel.Xinput;

            % Collect arguments
            Carguments={'Xinput',Xobj.XFullmodel.Xinput};
            if ~isempty(Xinput.CnamesRandomVariable)
                Carguments{end+1}='Msamplesphysicalspace'; %#ok<AGROW>
                Carguments{end+1}=XsimData.getValues('Cnames',Xinput.CnamesRandomVariable);%#ok<AGROW>
            end
            
            if ~isempty(Xinput.CnamesDesignVariable)
                Carguments{end+1}='Mdoedesignvariables'; %#ok<AGROW>
                Carguments{end+1}=XsimData.getValues('Cnames',Xinput.CnamesDesignVariable); %#ok<AGROW>
            end
            
            Xinput.Xsamples=Samples(Carguments{:});
            Xobj.XcalibrationInput=Xinput;
        otherwise
            error('openCOSSAN:MetaModel:calibrate',...
                'Field name %s  not allowed for the method calibrate of %s', varargin{k},class(Xobj));
    end
end

%% Check that all information has been defined
%  Verify that adequate Input exists

if exist('Xsimulator','var')
    Xs  = Xsimulator.sample('Xinput',Xobj.XFullmodel.Xinput);
    Xobj.XcalibrationInput = Xobj.XFullmodel.Xinput;
    Xobj.XcalibrationInput.Xsamples = Xs;
    Xobj.XcalibrationOutput = apply(Xobj.XFullmodel,Xobj.XcalibrationInput);
else
    
    assert(~isempty(Xobj.XcalibrationInput),...
        'openCOSSAN:MetaModel:calibrate',...
        ['Either samples (contained in the Input object)' ...
        'or the simulation object has to be provided']);
    
    % Check if samples are present
    assert(Xobj.XcalibrationInput.Nsamples>0,...
        'openCOSSAN:MetaModel:calibrate',...
        'The CalibrationInput does not contain samples');
    
    if isempty(Xobj.XcalibrationOutput)
        Xobj.XcalibrationOutput = apply(Xobj.XFullmodel,Xobj.XcalibrationInput);
    end
end

%% Collects inputs
Minputs=Xobj.XcalibrationInput.getValues('Cnames',Xobj.Cinputnames);

%% Extract outputs
Moutputs = Xobj.XcalibrationOutput.getValues('Cnames',Xobj.Coutputnames);

%%  Call metamodel calibration alghorithm
Xobj = Xobj.train(Minputs,Moutputs);
Xobj.Lcalibrated        = true;         % change status of response surface to calibrated

%% calibration error
XSimOutput  = apply(Xobj,Xobj.XcalibrationInput);
varargout{1} = XSimOutput;

for iresponse = 1:length(Xobj.Coutputnames)
    % Get target values from output object stored in the meta-model
    Vtargets = getValues(Xobj.XcalibrationOutput,'Sname',Xobj.Coutputnames{iresponse});
    
    % Get output values obtained with the meta-model
    Voutputs = getValues(XSimOutput,'Sname',Xobj.Coutputnames{iresponse});
    
    Xobj.VcalibrationError(iresponse) = 1-sum((Vtargets-Voutputs).^2)/sum((Vtargets-mean(Vtargets)).^2);
end
