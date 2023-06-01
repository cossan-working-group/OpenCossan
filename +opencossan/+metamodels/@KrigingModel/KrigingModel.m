classdef KrigingModel < opencossan.metamodels.MetaModel
    %KRIGING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SregressionType = 'regpoly0'
        ScorrelationType = 'correxp'
        VlowerCorrelationBound  % length(Ninput)
        VupperCorrelationBound           % bla bla
        VcorrelationParameter % theta
        TdaceModel
    end
    
    properties (Dependent)
        Stype
    end
    
    properties (Hidden,SetAccess = private)
        CregressionTypesSupported     = {'regpoly0','regpoly1','regpoly2'};
        CcorrelationTypesSupported    = {'correxp','correxpg','corrgauss',...
            'corrlin','corrspherical','corrspline'};
        
    end
    
    methods
        %% constructor
        function Xobj=KrigingModel(varargin)
            %Kriging
            %
            %
            % See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Kriging
            
            
            %% Check varargin
            if nargin==0
                % Return an empty object
                return
            end
            
            opencossan.OpenCossan.validateCossanInputs(varargin{:})
            
            %% Check that the DACE toolbox exist
            if ~isdeployed
                SpathToolbox=fullfile(OpenCossan.getCossanExternalPath,'src','dace');
                
                assert(logical(exist(SpathToolbox,'dir')),'openCOSSAN:Kriging', ...
                    'DACE toolbox not installed')
                
                addpath(SpathToolbox);
            else
                % Check DACE toolbox is available
                % TODO
            end
            
            
            %%  Set the values of the public properties
            for k=1:2:nargin
                switch lower(varargin{k}),
                    % Description of the object
                    case {'sdescription'}
                        Xobj.Sdescription   = varargin{k+1};
                        % Type of response surface
                    case {'sregressiontype'}
                        assert(ismember(lower(varargin{k+1}),Xobj.CregressionTypesSupported),...
                            'openCOSSAN:Kriging', ...
                            strcat('Regression Type %s is not valid.', ...
                            '\n Available options for regression type are: ', ...
                            sprintf('\n* %s',Xobj.CregressionTypesSupported{:})), ...
                            varargin{k+1})
                        Xobj.SregressionType= varargin{k+1};
                    case {'scorrelationtype'}
                        assert(ismember(lower(varargin{k+1}),Xobj.CcorrelationTypesSupported),...
                            'openCOSSAN:Kriging', ...
                            strcat('Regression Type %s is not valid.', ...
                            '\n Available options for regression type are: ', ...
                            sprintf('\n* %s',Xobj.CcorrelationTypesSupported{:})), ...
                            varargin{k+1})
                        Xobj.ScorrelationType= varargin{k+1};
                    case {'vcorrelationparameter'}
                        Xobj.VcorrelationParameter=varargin{k+1};
                        % DO NOT REMOVE THE FOLLOWING LINES
                    case {'coutputnames','csoutputnames'}
                        % Response of interst
                        Xobj.Coutputnames  = varargin{k+1};
                    case {'csinputnames','cinputnames'},
                        % Subset of inputs used to define the metamodel
                        Xobj.Cinputnames  = varargin{k+1};
                        % Full model associated with ResponseSurface
                    case{'xfullmodel','cxfullmodel'},
                        if isa(varargin{k+1},'cell'),
                            Xobj.XFullmodel     = varargin{k+1}{1};
                        else
                            Xobj.XFullmodel     = varargin{k+1};
                        end
                        % Input Object for calibrating ResponseSruface
                    case{'xcalibrationinput','cxcalibrationinput'},
                        
                        if isa(varargin{k+1},'cell')
                            Xobj.XcalibrationInput  = varargin{k+1}{1};
                        else
                            Xobj.XcalibrationInput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XcalibrationInput,'opencossan.common.inputs.Input'), ...
                            'openCOSSAN:Kriging',...
                            'PropertyName %s must be an object of type Input',varargin{k});
                        
                    case{'xcalibrationoutput','cxcalibrationoutput'}
                        if isa(varargin{k+1},'cell')
                            Xobj.XcalibrationOutput  = varargin{k+1}{1};
                        else
                            Xobj.XcalibrationOutput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XcalibrationOutput,'opencossan.common.outputs.SimulationData'), ...
                            'openCOSSAN:Kriging',...
                            'PropertyName %s must be an object of type SimulationData',varargin{k});
                    case{'xvalidationinput','cxvalidationinput'},
                        
                        if isa(varargin{k+1},'cell')
                            Xobj.XvalidationInput  = varargin{k+1}{1};
                        else
                            Xobj.XvalidationInput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XvalidationInput,'opencossan.common.inputs.Input'), ...
                            'openCOSSAN:Kriging',...
                            'PropertyName %s must be an object of type Input',varargin{k});
                        
                    case{'xvalidationoutput','cxvalidationoutput'}
                        if isa(varargin{k+1},'cell')
                            Xobj.XvalidationOutput  = varargin{k+1}{1};
                        else
                            Xobj.XvalidationOutput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XvalidationOutput,'opencossan.common.outputs.SimulationData'), ...
                            'openCOSSAN:Kriging',...
                            'PropertyName %s must be an object of type SimulationData',varargin{k});
                        % Other cases
                    otherwise
                        error('openCOSSAN:Kriging',...
                            'PropertyName %s not allowed for a Kriging object', varargin{k})
                end
            end
            
            % Validate the constructor of the metamodel
            Xobj=validateConstructor(Xobj);
            
        end     %end of constructor
        
        function Stype=get.Stype(Xobj)
            Stype=Xobj.SregressionType;
        end
        function Xobj = train(Xobj,Minputs,Moutputs)
            %% train
            %
            % train method receive the matrix with inputs and vector with
            % outputs and returns a trained response surface
            %
            
            if isempty(Xobj.VlowerCorrelationBound)
                [Xobj.TdaceModel, ~]=dacefit(Minputs,Moutputs,...
                    str2func(Xobj.SregressionType),...
                    str2func(Xobj.ScorrelationType),Xobj.VcorrelationParameter);
            else
                [Xobj.TdaceModel, ~]=dacefit(Minputs,Moutputs,...
                    str2func(Xobj.SregressionType),...
                    str2func(Xobj.ScorrelationType),Xobj.VcorrelationParameter,...
                    Xobj.VlowerCorrelationBound, ...
                    Xobj.VupperCorrelationBound);
            end
            
            
        end
        XsimData = evaluate(Xobj,Pinput);
    end
end

