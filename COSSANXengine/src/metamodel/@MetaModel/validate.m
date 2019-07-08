function [Xobj varargout] = validate(Xobj,varargin)
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
OpenCossan.validateCossanInputs(varargin{:})

% MetaModel already calibrated
if ~Xobj.Lcalibrated ,
    error('openCOSSAN:MetaModel:apply',...
        'MetaModel has not been calibrated');
end

%% Extract data
for k=1:2:length(varargin)
    switch lower(varargin{k}),
        % Simulation object used to generate samples for validating the MetaModel
        % Number of samples to calibrate MetaModel
        case {'xsimulator','cxsimulator'}
            if isa(varargin{k+1},'cell')
                Xsimulator  = varargin{k+1}{1};
            else
                Xsimulator  = varargin{k+1};
            end
            assert(isa(Xsimulator,'Simulations'), ...
                'openCOSSAN:MetaModel:validate',...
                'PropertyName %s must be an object of the subclasses of Simulations',varargin{k});
            
        case{'xvalidationinput','cxvalidationinput'},
            
            if isa(varargin{k+1},'cell')
                Xobj.XvalidationInput  = varargin{k+1}{1};
            else
                Xobj.XvalidationInput  = varargin{k+1};
            end
            
            assert(isa(Xobj.XvalidationInput,'Input'), ...
                'openCOSSAN:MetaModel:validate',...
                'PropertyName %s must be an object of type Input',varargin{k});
            
        case{'xvalidationoutput','cxvalidationoutput'}
            if isa(varargin{k+1},'cell')
                Xobj.XvalidationOutput  = varargin{k+1}{1};
            else
                Xobj.XvalidationOutput  = varargin{k+1};
            end
            
            assert(isa(Xobj.XvalidationOutput,'SimulationData'), ...
                'openCOSSAN:MetaModel:validate',...
                'PropertyName %s must be an object of type SimulationData',varargin{k});
        case{'xsimulationdata','cxsimulationdata'}
            if isa(varargin{k+1},'cell')
                XsimData  = varargin{k+1}{1};
            else
                XsimData  = varargin{k+1};
            end
                        
            assert(isa(XsimData,'SimulationData'), ...
                'openCOSSAN:MetaModel:validate',...
                'Object of class %s not valid after the property name %s',class(XsimData),varargin{k});
            
            % Create calibration Input/Output
            Xobj.XvalidationOutput=XsimData.split('Cmembers',Xobj.Coutputnames); 
            
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
            
        otherwise
            error('openCOSSAN:MetaModel:validate',...
                'Field name %s not allowed for the method validate of %s',...
                varargin{k},class(Xobj));
    end
end

%% Check that all information has been defined
% Verify that adequate Input exists

if exist('Xsimulator','var')
    Xs  = Xsimulator.sample('Xinput',Xobj.XFullmodel.Xinput);
    Xobj.XvalidationInput = Xobj.XFullmodel.Xinput;
    Xobj.XvalidationInput.Xsamples = Xs;
    Xobj.XvalidationOutput =apply(Xobj.XFullmodel,Xobj.XvalidationInput);
else
    assert(~isempty(Xobj.XvalidationInput),...
        'openCOSSAN:MetaModel:validate',...
        'Either Simulation object or the XvalidationInput has to be provided');
    
    assert(~isempty(Xobj.XvalidationOutput),...
        'openCOSSAN:MetaModel:validate',...
        'Either Simulation object or the XvalidationOutput has to be provided');
end

%% Compute output for validation using metamodel
XSimOutput  = apply(Xobj,Xobj.XvalidationInput);
varargout{1} = XSimOutput;

for iresponse = 1:length(Xobj.Coutputnames)
    
    % Get target values from output object stored in the meta-model
    Vtargets = Xobj.XvalidationOutput.getValues('Sname',Xobj.Coutputnames{iresponse});
    
    % Get output values obtained with the meta-model
    Voutputs = XSimOutput.getValues('Sname',Xobj.Coutputnames{iresponse});
    
    Xobj.VvalidationError(iresponse) = 1-sum((Vtargets-Voutputs).^2)/sum((Vtargets-mean(Vtargets)).^2);
end


%% regression error on validation samples
Xobj.Lvalidated  = true;         %change status of MetaModel to validated

return
