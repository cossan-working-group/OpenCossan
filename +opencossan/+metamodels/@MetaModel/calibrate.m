function [Xobj, varargout] = calibrate(Xobj,varargin)
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
import opencossan.*

%% Parse varargin input
for k=1:2:length(varargin)
    switch lower(varargin{k})
        % Number of samples to calibrate MetaModel
        case {'xsimulator','cxsimulator'}
            if isa(varargin{k+1},'cell')
                Xsimulator  = varargin{k+1}{1};
            else
                Xsimulator  = varargin{k+1};
            end
            assert(strcmp(superclasses(Xsimulator),'opencossan.simulations.Simulations'), ...
                'openCOSSAN:MetaModel:calibrate',...
                'PropertyName %s must be an object of the subclasses of Simulations',varargin{k});
            
        case{'xcalibrationinput','cxcalibrationinput'}
            
            if isa(varargin{k+1},'cell')
                Xobj.XcalibrationInput  = varargin{k+1}{1};
            else
                Xobj.XcalibrationInput  = varargin{k+1};
            end
            
            assert(isa(Xobj.XcalibrationInput,'opencossan.common.inputs.Input'), ...
                'openCOSSAN:MetaModel:calibrate',...
                'PropertyName %s must be an object of type Input',varargin{k});
            
        case{'xcalibrationoutput','cxcalibrationoutput'}
            if isa(varargin{k+1},'cell')
                Xobj.XcalibrationOutput  = varargin{k+1}{1};
            else
                Xobj.XcalibrationOutput  = varargin{k+1};
            end
            
            assert(isa(Xobj.XcalibrationOutput,'opencossan.common.outputs.SimulationData'), ...
                'openCOSSAN:MetaModel:calibrate',...
                'PropertyName %s must be an object of type SimulationData',varargin{k});
            
        case{'tcalibrationdata'}
                Xobj.TcalibrationData  = varargin{k+1}{1};   
                
        case{'xsimulationdata','cxsimulationdata'}
            if isa(varargin{k+1},'cell')
                XsimData  = varargin{k+1}{1};
            else
                XsimData  = varargin{k+1};
            end
                        
            assert(isa(XsimData,'opencossan.common.outputs.SimulationData'), ...
                'openCOSSAN:MetaModel:calibrate',...
                'Object of class %s not valid after the property name %s',class(XsimData),varargin{k});
            
            % Create calibration Input/Output
            Xobj.XcalibrationOutput=XsimData.split('Cmembers',Xobj.Coutputnames); 
            
            if ~isempty(Xobj.XFullmodel)
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
            end
        otherwise
            error('openCOSSAN:MetaModel:calibrate',...
                'Field name %s  not allowed for the method calibrate of %s', varargin{k},class(Xobj));
    end
end


%% Check that all information has been defined
%  Verify that adequate Input exists
if ~isempty(Xobj.TcalibrationData)
    assert(length(intersect(Xobj.TcalibrationData.Properties.VariableNames,Xobj.Cinputnames))==length(Xobj.Cinputnames),...
    'openCOSSAN:MetaModel:calibrate',...
    'TcalibrationData must contain the input',Xobj.Cinputnames);
    assert(length(intersect(Xobj.TcalibrationData.Properties.VariableNames,Xobj.Coutputnames))==length(Xobj.Coutputnames),...
    'openCOSSAN:MetaModel:calibrate',...
    'TcalibrationData must contain the output',Xobj.Coutputnames);
end

if ~isempty(Xobj.XcalibrationData) 
    assert(length(intersect(Xobj.Cinputnames,Xobj.XcalibrationData.Cnames))==length(Xobj.Cinputnames),...
    'openCOSSAN:MetaModel:calibrate',...
    'Object XsimulationData must contain the input',Xobj.Cinputnames);
    assert(length(intersect(Xobj.Coutputnames,Xobj.XcalibrationData.Cnames))==length(Xobj.Coutputnames),...
    'openCOSSAN:MetaModel:calibrate',...
    'Object XsimulationData must contain the output',Xobj.Coutputnames);
    if isempty(Xobj.TcalibrationData)
        Xobj.TcalibrationData=Xobj.XcalibrationData.TableValues;
    end
    Nsamples=height(Xobj.TcalibrationData);
end

if exist('Xsimulator','var')
    Xs  = Xsimulator.sample('Xinput',Xobj.XFullmodel.Input);
    Xobj.XcalibrationInput = Xobj.XFullmodel.Input;

    Xobj.XcalibrationInput.Samples = Xs;
    Xobj.XcalibrationOutput = apply(Xobj.XFullmodel,Xobj.XcalibrationInput);
else
    
    assert(~isempty(Xobj.XcalibrationInput)||~isempty(Xobj.TcalibrationData),...
        'openCOSSAN:MetaModel:calibrate',...
        ['Either samples (contained in the Input object)' ...
        'or the simulation object has to be provided']);

    if ~isempty(Xobj.XcalibrationInput)
        Nsamples=Xobj.XcalibrationInput.Nsamples;
    end
    
    % Check if samples are present
    assert(Nsamples>0 ,...
        'openCOSSAN:MetaModel:calibrate',...
        'The CalibrationInput does not contain samples');
    
    if isempty(Xobj.XcalibrationOutput) && ~isempty(Xobj.XFullmodel)
        Xobj.XcalibrationOutput = apply(Xobj.XFullmodel,Xobj.XcalibrationInput);
    elseif isempty(Xobj.XcalibrationOutput) && ~isempty(Xobj.XFullmodel) && ~isempty(Xobj.XcalibrationInput)
        error('openCOSSAN:MetaModel:calibrate',...
        'Full model and XcalibrationInput object are required to train the metamodel')
    end
end

if ~isempty(Xobj.TcalibrationData)
    TableInput=Xobj.TcalibrationData(:,Xobj.Cinputnames);
    Ttargets=Xobj.TcalibrationData(:,Xobj.Coutputnames);    
 else
    TempTableInput=Xobj.XcalibrationInput.getTable;
    TableInput=TempTableInput(:,Xobj.InputNames);
    Ttargets = Xobj.XcalibrationOutput.TableValues(:,Xobj.OutputNames);
end
Minputs=table2array(TableInput);
Moutputs=table2array(Ttargets);
%%  Call metamodel calibration alghorithm
Xobj = Xobj.train(Minputs,Moutputs);
Xobj.Lcalibrated        = true;         % change status of response surface to calibrated

%% calibration error
Toutput  = evaluate(Xobj,TableInput);
varargout{1} = Toutput;

for iresponse = 1:length(Xobj.OutputNames)
    % Get target values from output object stored in the meta-model
    Vtargets = (table2array(Ttargets(:,Xobj.OutputNames{iresponse})));
    
    % Get output values obtained with the meta-model
    Voutputs = table2array(Toutput);
    
    Xobj.VcalibrationError(iresponse) = 1-nansum((Vtargets-Voutputs).^2)/nansum((Vtargets-nanmean(Vtargets)).^2);
end
