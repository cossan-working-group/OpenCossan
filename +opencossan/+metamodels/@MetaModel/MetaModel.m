classdef MetaModel < opencossan.workers.Worker
    % Abstract class for creating metamodel objects
    % Subclass constructor should accept
    % property name/property value pairs
    %
    % See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@MetaModel
    % Author: Edoardo Patelli
    % Copyright 1993-2015, COSSAN Working Group, University~of~Liverpool,UK
    
    
    properties % Public access
        XFullmodel                    % object  of type Model or ProbabilisticModel defining the full model
        XcalibrationInput = []        % Supporting points (Input object)
        XcalibrationOutput = []       % Output of full model at supporting points
        XvalidationInput = []         % Points used for validation (Input object)
        XvalidationOutput = []        % Output of full model at validation points
        XcalibrationData  = []        % Simulation data object with calibration data  
        TcalibrationData  = []        % Table of calibration data  
        TvalidationData   = []        % Table of validation data  
    end
    
    properties (SetAccess = protected, GetAccess = public)
        Lcalibrated = false           % Flag indicating if MetaModel has been calibrated
        Lvalidated = false            % Flag indicating if MetaModel has been validated
        VcalibrationError             % Error at calibration points
        VvalidationError              % Error at validation points
        MboundsInput                  % Minimum and maximum value of calibration inputs
    end
    
    properties (Dependent)
        MvalidationTarget     % target output for validation
        MvalidationOutput     % metamodel output for validation
        McalibrationTarget    % target output for calibration
        McalibrationOutput    % metamodel output for calibration
        Xinput                % Link to the Xinput to the full model if available
    end
    
    methods (Abstract)
        [varargout] = evaluate(Xobj,Tinput);
    end
    
    methods
        
        function MvalidationTarget=get.MvalidationTarget(Xobj)
            if ~isempty(Xobj.XvalidationOutput)
                MvalidationTarget=getValues(Xobj.XvalidationOutput,'Cnames',Xobj.Coutputnames);
            else
                MvalidationTarget=[];
            end
        end
        
        function McalibrationTarget=get.McalibrationTarget(Xobj)
            if ~isempty(Xobj.XcalibrationOutput)
                McalibrationTarget=getValues(Xobj.XcalibrationOutput,'Cnames',Xobj.OutputNames);
            else
                McalibrationTarget=[];
            end
        end
        
        
        function MvalidationOutput=get.MvalidationOutput(Xobj)
            if Xobj.Lvalidated
                XSimOut = Xobj.apply(Xobj.XvalidationInput);
                MvalidationOutput = getValues(XSimOut,'Cnames',Xobj.Coutputnames);
            else
                MvalidationOutput=[];
            end
        end
        
        function McalibrationOutput=get.McalibrationOutput(Xobj)
            if Xobj.Lcalibrated
                XSimOut = Xobj.apply(Xobj.XcalibrationInput);
                McalibrationOutput = getValues(XSimOut,'Cnames',Xobj.Coutputnames);
            else
                McalibrationOutput=[];
            end
        end
        
        function Xinput=get.Xinput(Xobj)
            if isempty(Xobj.XFullmodel)
                Xinput=Xobj.XcalibrationInput;
            else
                Xinput=Xobj.XFullmodel.Xinput;
            end
        end
        
        function Xobj=set.Xinput(Xobj,Xinput)
            if isempty(Xobj.XFullmodel)
                Xobj.XcalibrationInput=Xinput;
            else
                Xobj.XFullmodel.Xinput=Xinput;
            end
        end
        
        Xout=deterministicAnalysis(Xobj) % perform deterministic analysis
        varargout=plotregression(Xobj,varargin)  % plot comparison of target and obtained output
        [Xobj,Xoutput] = calibrate(Xobj,varargin);
        [Xobj,Xoutput] = validate(Xobj,varargin);        
        [Minput,Tinput] = prepareInput(Xobj,Pinput);
    end
    
    methods (Access=protected)
        Xobj=validateConstructor(Xobj)   % validate the constructor of the subclasses.
    end
    
end

