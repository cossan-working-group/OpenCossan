classdef Model
    % Model This class defines the model composed by an Input object and an
    % Evaluator object.
    
    properties
        Sdescription    % Description of the object
        Xinput          % Input object
        Xevaluator      % Evaluator object
    end
    
    properties (Dependent=true)
        Coutputnames    % Names of the output variables
        Cinputnames    % Names of the input variables
    end
    
    methods
        Xo=apply(Xobj,Pinput)           % Evaluate the Model
        
        Xo=deterministicAnalysis(Xobj)  % Performe deterministi analysis
        
        Xo=setGridProperties(Xobj,varargin)   % Add execution details (i.e. Grid configuration) 
        
        display(Xobj)            % Show details of the Model object
        
        % Constructor
        function Xmdl =Model(varargin)
            %MODEL  Constructor function for class MODEL
            %
            % See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/@Model
            %
            % Copyright 1993-2011, COSSAN Working Group, University of Innsbruck, Austria
            % Author: Edoardo-Patelli
           
            if nargin==0
                return
            end
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'xinput'
                        if	not(isa(varargin{k+1},'Input'))
                            error('openCOSSAN:Model:Model',...
                                [inputname(k+1) ' is not an object of kind Input']);
                        end
                        Xmdl.Xinput=varargin{k+1};
                    case 'xevaluator'
                        if	not(isa(varargin{k+1},'Evaluator'))
                            error('openCOSSAN:Model:Model',...
                                [inputname(k+1) ' is not an object of kind Evaluator']);
                        end
                        Xmdl.Xevaluator=varargin{k+1};
                   case 'cxinput'
                        if	not(isa(varargin{k+1}{1},'Input'))
                            error('openCOSSAN:Model:Model',...
                                'Provided object after CXinput is class %s and not an object of kind Input',class(varargin{k+1}{1}));
                        end
                        Xmdl.Xinput=varargin{k+1}{1};
                    case 'cxevaluator'
                        if	not(isa(varargin{k+1}{1},'Evaluator'))
                            error('openCOSSAN:Model:Model',...
                                'Provided object after CXevaluator is of class %s and not an object of kind Evaluator',class(varargin{k+1}{1}));
                        end
                        Xmdl.Xevaluator=varargin{k+1}{1};
                    case {'sdescription'}
                        Xmdl.Sdescription=varargin{k+1};
                    case {'cmembers','cmember'}
                        % The object are retrieved from the base workspace
                        for iobj=1:length(varargin{k+1})
                            Xobj=evalin('base',varargin{k+1}{iobj});
                            if isa(Xobj,'Input')
                                Xmdl.Xinput= Xobj;
                            elseif isa(Xobj,'Evaluator')
                                Xmdl.Xevaluator=Xobj;
                            else
                                error('openCOSSAN:Model:Model',...
                                    ['The object ' varargin{k+1}(iobj) ' is not an Input nor an Evaluator object']);
                            end
                        end
                    case 'cxmembers'
                        % The object are retrieved from the base workspace
                        for iobj=1:length(varargin{k+1})
                            Xobj=varargin{k+1}{iobj};
                            if isa(Xobj,'Input')
                                Xmdl.Xinput= Xobj;
                            elseif isa(Xobj,'Evaluator')
                                Xmdl.Xevaluator=Xobj;
                            else
                                error('openCOSSAN:Model:Model',...
                                    ['The object of class ' class(varargin{k+1}{iobj}) ' can not be added to the Model']);
                            end
                        end
                        
                end
            end
            
            %% Check the Objects
            if isempty(Xmdl.Xinput)
                error('openCOSSAN:Model',...
                    'An object of kind Input is required by the Model');
            end
            
            if isempty(Xmdl.Xevaluator)
                error('openCOSSAN:Model',...
                    'The Model must contain an Evaluator');
            end
            
            %% Check Input/Output Names
            CrequiredInputs=Xmdl.Xevaluator.Cinputnames;
            Cinputnames=Xmdl.Cinputnames;
            for n=1:length(CrequiredInputs)
                assert(any(strcmp(CrequiredInputs{n},Cinputnames)), ...
                    'openCOSSAN:Model',...
                    strcat('An input object containing the following inputs is required: \n', ...
                    sprintf('%s ',CrequiredInputs{:}), ...
                    ' \nProvided inputs: \n', ...
                    sprintf('%s ',Cinputnames{:})))
            end
        end
        
        function Coutputnames=get.Coutputnames(Xmdl)
            Coutputnames=Xmdl.Xevaluator.Coutputnames;
        end
        
        function Cinputnames=get.Cinputnames(Xmdl)
            Cinputnames=Xmdl.Xinput.Cnames;
        end
        
    end % End methods
    
end % end class def
