classdef NeuralNetwork < MetaModel
    %NeuralNetwork  Creates an object for constructing a Neural Network
    %
    % See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@NeuralNetwork
    %
    % Copyright 1993-2011, COSSAN Working Group, University~of~Innsbruck, Austria
    
    properties
        Stype          = 'HyperbolicTangent';     % type of neural network activation function
        VhiddenNodes   = 2                        % Vector with the number if nodes for each layer
    end
    
    properties(Access=private)
        MboundsOutput            %Minimum and maximum value of calibration outputs
        TFannStruct              %Structure output of the FANN library
        Vnormminmax = [-0.8 0.8] %Normalization bounds
    end
    
    properties (Dependent = true)
        VCoefficients
        Nhiddenlayers            % Number of hidden layers
        Ntype                    % Activation function type
        Vnnodes                  % Number of Nodes of the NeuralNetwork
    end
    
    methods
        %% constructor
        function Xobj=NeuralNetwork(varargin)
            %NEURALNETWORK constructor for NeuralNetwork
            % See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@NeuralNetwork
            %
            % Copyright 1993-2011, COSSAN Working Group, University~of~Innsbruck, Austria
            
            %%  Argument Check
            
            if nargin==0
                return
            end
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            %% set the values of the public properties
            for k=1:2:nargin
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription   = varargin{k+1};
                    case {'stype'}
                        Xobj.Stype          = varargin{k+1};
                    case {'vnnodes' }
                        Xobj.VhiddenNodes      = varargin{k+1}(2:end-1);
                    case {'vhiddennodes' }
                        Xobj.VhiddenNodes      = varargin{k+1};
                    case {'vnormminmax'}
                        Xobj.Vnormminmax      = varargin{k+1};
                    case{'xfullmodel','cxfullmodel'},
                        if isa(varargin{k+1},'cell'),
                            Xobj.XFullmodel     = varargin{k+1}{1};
                        else
                            Xobj.XFullmodel     = varargin{k+1};
                        end
                    case {'coutputnames','csoutputnames'},
                        Xobj.Coutputnames  = varargin{k+1};
                    case {'cinputnames','csinputnames'},
                        Xobj.Cinputnames  = varargin{k+1};
                    case{'xcalibrationinput','cxcalibrationinput'},
                        
                        if isa(varargin{k+1},'cell')
                            Xobj.XcalibrationInput  = varargin{k+1}{1};
                        else
                            Xobj.XcalibrationInput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XcalibrationInput,'Input'), ...
                            'openCOSSAN:NeuralNetwork',...
                            'PropertyName %s must be an object of type Input',varargin{k});
                        
                    case{'xcalibrationoutput','cxcalibrationoutput'}
                        if isa(varargin{k+1},'cell')
                            Xobj.XcalibrationOutput  = varargin{k+1}{1};
                        else
                            Xobj.XcalibrationOutput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XcalibrationOutput,'SimulationData'), ...
                            'openCOSSAN:NeuralNetwork',...
                            'PropertyName %s must be an object of type SimulationData',varargin{k});
                    case{'xvalidationinput','cxvalidationinput'},
                        
                        if isa(varargin{k+1},'cell')
                            Xobj.XvalidationInput  = varargin{k+1}{1};
                        else
                            Xobj.XvalidationInput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XvalidationInput,'Input'), ...
                            'openCOSSAN:NeuralNetwork',...
                            'PropertyName %s must be an object of type Input',varargin{k});
                        
                    case{'xvalidationoutput','cxvalidationoutput'}
                        if isa(varargin{k+1},'cell')
                            Xobj.XvalidationOutput  = varargin{k+1}{1};
                        else
                            Xobj.XvalidationOutput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XvalidationOutput,'SimulationData'), ...
                            'openCOSSAN:NeuralNetwork',...
                            'PropertyName %s must be an object of type SimulationData',varargin{k});
                    otherwise
                        error('openCOSSAN:NeuralNetwork',...
                             'PropertyName %s is not valid ', varargin{k})
                end
                
            end
            
            
            % Validate the constructor of the metamodel
            Xobj=validateConstructor(Xobj);
            
            % initialize structure containing the FANN properties
            Nfuntype = Xobj.Ntype;
            % this variable is used to check that the correct Stype has
            % been defined, since a try-catch is used to check that the mex
            % has been correctly initialized
            try
                Xobj.TFannStruct = createFann(Xobj.Vnnodes, Nfuntype, 1);
            catch ME
                if strcmpi(ME.identifier,'MATLAB:invalidMEXFile')
                    error('openCOSSAN:NeuralNetwork',['Unable to call createFann mex.\n'...
                        'Please check that your library path is correctly set.'])
                end
            end
            
            
        end
               
        [varargout] = apply(Xnn,Pinput)
        
        
        function Xnn = train(Xnn,Minputs,Moutputs)
            %% train
            %
            % train method receive the matrix with inputs and vector with
            % outputs and returns a trained neural network
            %
            
            % Normalize inputs and outputs
            Nsamples = size(Minputs,1);
            Xnn.MboundsInput = zeros(2,size(Minputs,2));
            for j=1:size(Minputs,2)
                if min(Minputs(:,j)) == max(Minputs(:,j))
                    Xnn.MboundsInput(:,j) = [min(Minputs(:,j))-1; max(Minputs(:,j))+1];
                else
                    Xnn.MboundsInput(:,j) = [min(Minputs(:,j)); max(Minputs(:,j)) ];
                end
            end
            Xnn.MboundsOutput = zeros(2,size(Moutputs,2));
            for j=1:size(Moutputs,2)
                Xnn.MboundsOutput(:,j) = [min(Moutputs(:,j)); max(Moutputs(:,j)) ];
            end
            
            % Normalize Minputs and Voutput between Xnn.Vnormminmax(1) and Xnn.Vnormminmax(2)
            MnormInput = Xnn.Vnormminmax(1)+...
                (Xnn.Vnormminmax(2)-Xnn.Vnormminmax(1))*(Minputs-repmat(Xnn.MboundsInput(1,:),Nsamples,1))./...
                (repmat(Xnn.MboundsInput(2,:),Nsamples,1)-repmat(Xnn.MboundsInput(1,:),Nsamples,1));
            MnormOutput = Xnn.Vnormminmax(1)+...
                (Xnn.Vnormminmax(2)-Xnn.Vnormminmax(1))*(Moutputs-repmat(Xnn.MboundsOutput(1,:),Nsamples,1))./...
                (repmat(Xnn.MboundsOutput(2,:),Nsamples,1)-repmat(Xnn.MboundsOutput(1,:),Nsamples,1));
            
            %% Update network weights
            if ~isempty(Xnn.TFannStruct)
                Xnn.TFannStruct = trainFann(Xnn.TFannStruct, MnormInput, MnormOutput);
            else
                error('openCOSSAN:NeuralNetwork:calibrate',...
                    'Cannot calibrate NeuralNetwork, Fann not correctly initialized')
            end
        end
        
        %% Dependent Properties
        function Vcoefficients = get.VCoefficients(Xobj)
            Vcoefficients = Xobj.TFannStruct.weights;
        end
        
        function Nhiddenlayers = get.Nhiddenlayers(Xobj)
            if ~isempty(Xobj.Vnnodes)
                Nhiddenlayers = length(Xobj.Vnnodes) -2;
            end
        end
        
        function Vnnodes = get.Vnnodes(Xobj)
            Vnnodes= [length(Xobj.Cinputnames) Xobj.VhiddenNodes length(Xobj.Coutputnames)];
        end
        
        
        
        
        function Ntype = get.Ntype(Xobj)
            switch lower(Xobj.Stype)
                case {'hyptan', 'hyperbolictangent', 'sigmoid'}
                    Ntype = 1;
                case 'gaussian'
                    Ntype = 2;
                case 'linear'
                    Ntype = 3;
                otherwise
                    error('openCOSSAN:NeuralNetwork','Unknown activation function type: %s', Xobj.Stype)
            end
        end
    end
    
end
