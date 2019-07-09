classdef ModeBased < opencossan.metamodels.MetaModel
    
    properties
        Cnamesmodalprop             % Cell array with names of modal properties
        SfilenamesCalibrationSet    % Name of file containing the sets of calibration samples
        SnamesCalibrationInput      % Names of the Input object used for calibration
        SnamesCalibrationOutput     % Name of the Modes objects used for calibration
        Xmodes0                     % Modes object with nominal eigenvectors and eigenvalues
        Vmodes                      % Vector index of modes to be calibrated
        Vmkmodes                    % Vector with number of modes to be used for calibration of each mode
        Mmass0                      % nominal mass matrix
    end
    
    properties (Access=private)
        Mlincomb                    % Matrix defining the linear relation between input and output
        Cindexmodes                 % index of modes of nominal model used for approximation
    end
    
    methods
        
        function Xobj=ModeBased(varargin)
            
            if nargin==0
                return;
            end
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Description=varargin{k+1};
                    case {'xfullmodel'}
                        Xobj.XFullmodel=varargin{k+1};
                    case {'cnamesmodalprop'}
                        Xobj.Cnamesmodalprop =varargin{k+1};
                    case {'sfilenamescalibrationset'}
                        Xobj.SfilenamesCalibrationSet =varargin{k+1};
                    case {'snamescalibrationinput'}
                        Xobj.SnamesCalibrationInput =varargin{k+1};
                    case {'snamescalibrationoutput'}
                        Xobj.SnamesCalibrationOutput =varargin{k+1};    
                    case {'xmodes0'}
                        Xobj.Xmodes0 = varargin{k+1};
                    case {'xcalibrationinput'}
                        Xobj.XcalibrationInput = varargin{k+1};
                    case {'xcalibrationoutput'}
                        Xobj.XcalibrationOutput = varargin{k+1};
                    case {'xvalidationinput'}
                        Xobj.XvalidationInput = varargin{k+1};
                    case {'xvalidationoutput'}
                        Xobj.XvalidationOutput = varargin{k+1};
                    case {'vmkmodes'}
                        Xobj.Vmkmodes = varargin{k+1}; 
                    case {'vmodes'}
                        Xobj.Vmodes = varargin{k+1}; 
                    case {'mmass0'}
                        Xobj.Mmass0 = varargin{k+1};      
                    otherwise
                        error('openCOSSAN:metamodel:ModeBased',...
                            ['Field name (' varargin{k} ') not allowed']);
                end
            end
            
            if isempty(Xobj.Mmass0)
                error('openCOSSAN:ModeBased',...
                      'The nominal mass matrix has to be specified')
            end
                
            
            if ~isempty(Xobj.XFullmodel) && length(Xobj.Cnamesmodalprop)~=2
                error('openCOSSAN:ModeBased',...
                      'The names of the eigenvalues and eigenvectors in the output of XFullmodel have to be specified')
            end
            if ~isempty(Xobj.XFullmodel) && ~isempty(Xobj.Cnamesmodalprop)
                if ~ismember(Xobj.Cnamesmodalprop{1},Xobj.XFullmodel.OutputNames) || ...
                   ~ismember(Xobj.Cnamesmodalprop{2},Xobj.XFullmodel.OutputNames)     
                error('openCOSSAN:ModeBased',...
                      'The names of the eigenvalues and/or eigenvectors are not in the output of XFullmodel')
                end
            end
            
            if ~isempty(Xobj.XFullmodel) && isempty(Xobj.Xmodes0)
                Xobj.Lcalibrated = 0;
                Xobj.Lvalidated = 0;
                XSimOut = deterministicAnalysis(Xobj.XFullmodel);
                Vlambda = XSimOut.TableValues.(Xobj.Cnamesmodalprop{1});
                Mphi = XSimOut.TableValues.(Xobj.Cnamesmodalprop{2});
                Xobj.Xmodes0 = opencossan.common.outputs.Modes('Mphi',Mphi,'Vlambda',Vlambda);
            end
            
            if isempty(Xobj.XFullmodel) && isempty(Xobj.Xmodes0)
                error('openCOSSAN:ModeBased',...
                       'Either the full model or the nominal modal properties have to be specified');
            end
            
            if ~isempty(Xobj.SfilenamesCalibrationSet)
                if isempty(Xobj.SnamesCalibrationInput)
                 error('openCOSSAN:ModeBased',...
                       'The name of the Input object contained in the file are not specified');
                end
                if isempty(Xobj.SnamesCalibrationOutput)
                 error('openCOSSAN:ModeBased',...
                       'The names of the Mode object contained in the file are not specified');
                end 
                load(Xobj.SfilenamesCalibrationSet)
                eval(['Xobj.XcalibrationInput = ' Xobj.SnamesCalibrationInput]);
                eval(['Xobj.XcalibrationOutput = ' Xobj.SnamesCalibrationOutput]);
            end
            
            
            if ~isempty(Xobj.XcalibrationInput) 
                Xobj = calibrate(Xobj);
            end
            
        end %end constructor
        
        Xobj = calibrate(Xobj,varargin);
        [Xobj Xoutput] = validate(Xobj,varargin);
        [varargout] = evaluate(Xobj,Xinput);

    end
end




