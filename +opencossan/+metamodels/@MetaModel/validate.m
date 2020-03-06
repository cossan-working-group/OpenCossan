function [Xobj, varargout] = validate(Xobj,varargin)
%validate
%
%   This method is intended for analyzing the predictive capabilities of a
%   calibrated Meta model. That is, the response for a certain number of
%   points is computed using the full Model and also the calibrated meta
%   model.
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Validate@ResponseSurface
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria$

%%  Argument Check
%opencossan.OpenCossan.validateCossanInputs(varargin{:})

% MetaModel already calibrated
if ~Xobj.Lcalibrated 
    error('openCOSSAN:MetaModel:apply',...
        'MetaModel has not been calibrated');
end

%% Extract data
for k=1:2:length(varargin)
    switch lower(varargin{k})
        % Simulation object used to generate samples for validating the MetaModel
        % Number of samples to calibrate MetaModel
        case {'xsimulator','cxsimulator'}
            if isa(varargin{k+1},'cell')
                Xsimulator  = varargin{k+1}{1};
            else
                Xsimulator  = varargin{k+1};
            end
            assert(isa(Xsimulator, 'opencossan.simulations.Simulations'), ...
                'openCOSSAN:MetaModel:validate',...
                'PropertyName %s must be an object of the subclasses of Simulations',varargin{k});
           
        case{'xvalidationinput','cxvalidationinput'}
            
            if isa(varargin{k+1},'cell')
                Xobj.XvalidationInput  = varargin{k+1}{1};
            else
                Xobj.XvalidationInput  = varargin{k+1};
            end
            
            assert(isa(Xobj.XvalidationInput,'opencossan.common.inputs.Input'), ...
                'openCOSSAN:MetaModel:validate',...
                'PropertyName %s must be an object of type Input',varargin{k});
            
            
        case{'xvalidationoutput','cxvalidationoutput'}
            if isa(varargin{k+1},'cell')
                Xobj.XvalidationOutput  = varargin{k+1}{1};
            else
                Xobj.XvalidationOutput  = varargin{k+1};
            end
            
            assert(isa(Xobj.XvalidationOutput,'opencossan.common.outputs.SimulationData'), ...
                'openCOSSAN:MetaModel:validate',...
                'PropertyName %s must be an object of type SimulationData',varargin{k});
        case{'tvalidationdata','tabledata'}    
            Xobj.TvalidationData=  varargin{k+1};  
            
        case{'xsimulationdata','cxsimulationdata'}
            if isa(varargin{k+1},'cell')
                XsimData  = varargin{k+1}{1};
            else
                XsimData  = varargin{k+1};
            end
                        
            assert(isa(XsimData,'opencossan.common.outputs.SimulationData'), ...
                'openCOSSAN:MetaModel:validate',...
                'Object of class %s not valid after the property name %s',class(XsimData),varargin{k});
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
                Xobj.XvalidationInput=Xinput;
            end
            
            % Create calibration Input/Output
            Xobj.XvalidationOutput=XsimData.split('Cmembers',Xobj.Coutputnames); 
            Xobj.XvalidationInput=XsimData.split('Cmembers',Xobj.Cinputnames); 
            
            
            
        otherwise
            error('openCOSSAN:MetaModel:validate',...
                'Field name %s not allowed for the method validate of %s',...
                varargin{k},class(Xobj));
    end
end

%% Check that all information has been defined
% Verify that adequate Input exists
%% Check that all information has been defined
%  Verify that adequate Input exists
if ~isempty(Xobj.TvalidationData)
    assert(length(intersect(Xobj.TvalidationData.Properties.VariableNames,Xobj.Cinputnames))==length(Xobj.Cinputnames),...
    'openCOSSAN:MetaModel:calibrate',...
    'TValidationData must contain the input',Xobj.Cinputnames);
    assert(length(intersect(Xobj.TvalidationData.Properties.VariableNames,Xobj.Coutputnames))==length(Xobj.Coutputnames),...
    'openCOSSAN:MetaModel:calibrate',...
    'TValidationData must contain the output',Xobj.Coutputnames);
end

if ~isempty(Xobj.XcalibrationData) 
    assert(length(intersect(Xobj.Cinputnames,Xobj.XcalibrationData.Cnames))==length(Xobj.Cinputnames),...
    'openCOSSAN:MetaModel:calibrate',...
    'Object XsimulationData must contain the input',Xobj.Cinputnames);
    assert(length(intersect(Xobj.Coutputnames,Xobj.XcalibrationData.Cnames))==length(Xobj.Coutputnames),...
    'openCOSSAN:MetaModel:calibrate',...
    'Object XsimulationData must contain the output',Xobj.Coutputnames);
    if isempty(Xobj.TvalidationData)
        Xobj.TvalidationData=[Xobj.XvalidationInput.TableValues,Xobj.XvalidationOutput.TableValues];
    end
end


if exist('Xsimulator','var')
    Xs  = Xsimulator.sample('Xinput',Xobj.XFullmodel.Input);
    Xobj.XvalidationInput = Xs;
    Xobj.XvalidationOutput = apply(Xobj.XFullmodel,Xobj.XvalidationInput);
else
    assert(~isempty(Xobj.XvalidationInput)||~isempty(Xobj.TvalidationData),...
        'openCOSSAN:MetaModel:validate',...
        'Simulation object or XvalidationInput or TvalidationData has to be provided');
    
    assert(~isempty(Xobj.XvalidationOutput)||~isempty(Xobj.TvalidationData),...
        'openCOSSAN:MetaModel:validate',...
        'Either Simulation object or the XvalidationOutput or TvalidationData has to be provided');
end

%% Compute output for validation using metamodel
if ~isempty(Xobj.TvalidationData)
    TableInput=Xobj.TvalidationData(:,Xobj.Cinputnames);
    Ttargets=Xobj.TvalidationData(:,Xobj.Coutputnames);
else
    TempTableInput=Xobj.XvalidationInput;
    TableInput=TempTableInput(:,Xobj.InputNames);
    Ttargets = Xobj.XvalidationOutput.Samples(:,Xobj.OutputNames);
end

XOutput  = evaluate(Xobj,TableInput);
varargout{1} = XOutput;

for iresponse = 1:length(Xobj.OutputNames)
    
    % Get target values from output object stored in the meta-model
    Vtargets = (table2array(Ttargets(:,Xobj.OutputNames{iresponse})));
    
    % Get output values obtained with the meta-model
    Voutputs = table2array(XOutput);
    
    Xobj.VvalidationError(iresponse) = 1-nansum((Vtargets-Voutputs).^2)/nansum((Vtargets-nanmean(Vtargets)).^2);
    
end


%% regression error on validation samples
Xobj.Lvalidated  = true;         %change status of MetaModel to validated

return
