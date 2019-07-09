classdef ResponseSurface < opencossan.metamodels.MetaModel 
    %ResponseSurface
    %
    %   This method is the constructor of the class ResponseSurface. It is
    %   intended for creating a response surface that approximates the response
    %   associated with a Model object.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@ResponseSurface
    %
    % Copyright 1993-2011, COSSAN Working Group, University~of~Innsbruck, Austria
    
    properties
        Stype          = 'linear';  % Type of response surface; supported types are 'linear', 'interaction', 'purequadratic', 'quadratic' or 'custom'
        NmaximumExponent
        Mexponents
        VridgeCoefficient = [];
    end
    
    properties (SetAccess = protected, GetAccess = public)
        CVCoefficients          %Coefficients of response surface
    end
    
    methods
        %% Methods of the class
        XSimDataOutput  = evaluate(Xobj,Pinput)
        %% constructor
        function Xobj=ResponseSurface(varargin)
            %ResponseSurface
            %
            %   This method is the constructor of the class ResponseSurface. It is
            %   intended for creating a response surface that approximates the response
            %   associated with a Model object. For example, the model can be a FE
            %   model.
            %
            % See also: https://cossan.co.uk/wiki/index.php/@ResponseSurface
            %
            % Copyright 1993-2011, COSSAN Working Group, University~of~Innsbruck, Austria
            
            import opencossan.*
            
            %% Check varargin
            if nargin==0
                % Return an empty object
                return
            end
            
            %%  Set the values of the public properties
            for k=1:2:nargin
                switch lower(varargin{k}),
                    % Description of the object
                    case {'sdescription'}
                        Xobj.Description   = varargin{k+1};
                        % Type of response surface
                    case {'stype'}
                        CTypesSupported     = {'linear','interaction','purequadratic','quadratic','custom'};
                        if ismember(lower(varargin{k+1}),CTypesSupported),
                            Xobj.Stype  = lower(varargin{k+1});
                        else
                            error('openCOSSAN:ResponseSurface',...
                                '%s of type %s is not supported',varargin{k},varargin{k+1})
                        end
                    case {'nmaximumexponent','nexponent'}
                        % check that the exponent values is passed only
                        % when the type "custom" is specified
                        assert(any(strcmp({'custom'},varargin)),...
                            'openCOSSAN:ResponseSurface',...
                            'The maximum exponent can be passed only when Stype is "custom"')
                        Xobj.NmaximumExponent = varargin{k+1};
                    case {'mexponents'}
                        % check that the exponents matrix is passed only
                        % when the type "custom" is specified
                        assert(any(strcmp({'custom'},varargin)),...
                            'openCOSSAN:ResponseSurface',...
                            'The model matrix can be passed only when Stype is "custom"')
                        Xobj.Mexponents = varargin{k+1};
                    case {'vridgecoefficient'}
                        Xobj.VridgeCoefficient = varargin{k+1};
                    case {'coutputnames','csoutputnames'}
                        % Response of interst
                        Xobj.OutputNames  = varargin{k+1};
                    case {'csinputnames','cinputnames'},
                        % Subset of inputs used to define the metamodel
                        Xobj.InputNames  = varargin{k+1};
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
                        
                        assert(isa(Xobj.XcalibrationInput,'Input'), ...
                            'openCOSSAN:ResponseSurface',...
                            'PropertyName %s must be an object of type Input',varargin{k});
                        
                    case{'xcalibrationoutput','cxcalibrationoutput'}
                        if isa(varargin{k+1},'cell')
                            Xobj.XcalibrationOutput  = varargin{k+1}{1};
                        else
                            Xobj.XcalibrationOutput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XcalibrationOutput,'SimulationData'), ...
                            'openCOSSAN:ResponseSurface',...
                            'PropertyName %s must be an object of type SimulationData',varargin{k});
                    case{'xvalidationinput','cxvalidationinput'},
                        
                        if isa(varargin{k+1},'cell')
                            Xobj.XvalidationInput  = varargin{k+1}{1};
                        else
                            Xobj.XvalidationInput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XvalidationInput,'Input'), ...
                            'openCOSSAN:ResponseSurface',...
                            'PropertyName %s must be an object of type Input',varargin{k});
                        
                    case{'xvalidationoutput','cxvalidationoutput'}
                        if isa(varargin{k+1},'cell')
                            Xobj.XvalidationOutput  = varargin{k+1}{1};
                        else
                            Xobj.XvalidationOutput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XvalidationOutput,'SimulationData'), ...
                            'openCOSSAN:ResponseSurface',...
                            'PropertyName %s must be an object of type SimulationData',varargin{k});
                        % Other cases
                    otherwise
                        error('openCOSSAN:ResponseSurface',...
                            'PropertyName %s not allowed for a ResponseSurface object', varargin{k})
                end
            end
            
            % Validate the constructor of the metamodel
            Xobj=validateConstructor(Xobj);
            
            % Additional validations needed for "custom" model
            if strcmpi(Xobj.Stype,'custom')
                if ~isempty(Xobj.NmaximumExponent)
                    assert(~mod(Xobj.NmaximumExponent,1),...
                        'openCOSSAN:ResponseSurface',...
                        'The maximum exponent must be an integer.')
                elseif ~isempty(Xobj.Mexponents) 
                    assert(~any(mod(Xobj.Mexponents,1)),...
                        'openCOSSAN:ResponseSurface',...
                        'The model matrix must contain only integers')
                end
            end
            
            % check that either the maximum exponent or the custom model
            % has been passed when Stype is custom
            if strcmpi(Xobj.Stype,'custom')
                if isempty(Xobj.NmaximumExponent) && isempty(Xobj.Mexponents)
                    error('openCOSSAN:ResponseSurface',...
                        ['Either the maximum exponent or the matrix of expoents'...
                        ' is required to define a custom model.'])
                end
            end
            
        end     %end of constructor
        
        function Xrs = train(Xrs,Minputs,Moutputs)
            %% train
            %
            % train method receive the matrix with inputs and vector with
            % outputs and returns a trained response surface
            %
            
            Nvar = size(Minputs,2);
            Xrs.MboundsInput = zeros(2,Nvar);
            for j=1:Nvar
                Xrs.MboundsInput(:,j) = [min(Minputs(:,j)); max(Minputs(:,j)) ];
            end
            
            if ~isempty(Xrs.VridgeCoefficient)
                assert(size(Xrs.VridgeCoefficient,2)==size(Moutputs,2),...
                    'openCOSSAN:ResponseSurface:calibrate',...
                    ['Wrong dimension of ridge coefficiens vector.\n' ... 
                    'Number of response surface outputs: %d\n' ...
                    'Number of ridge regression coefficients: %d\n'],...
                    size(Moutputs,2),size(Xrs.VridgeCoefficient))
            end
            
            for iresponse=1:size(Moutputs,2)

                switch lower(Xrs.Stype),
                    case {'linear'}
                        MD = x2fx(Minputs,'linear');
                    case {'interaction'}
                        MD = x2fx(Minputs,'interaction');
                    case {'purequadratic'}
                        MD = x2fx(Minputs,'purequadratic');
                    case {'quadratic'}
                        MD = x2fx(Minputs,'quadratic');
                    case {'custom'}
                        if isempty(Xrs.Mexponents)
                            % create a full polynomial model of maximum
                            % power NmaximumExponent.
                            % These two lines get all the possible
                            % combination of the exponents (got it from
                            % http://groups.google.com/group/comp.soft-sys.matlab/browse_thread/thread/878717e082473f68)
                            Xrs.Mexponents = fullfact((Xrs.NmaximumExponent+1)*ones(1,Nvar))-1;
                            Xrs.Mexponents(sum(Xrs.Mexponents,2)>Xrs.NmaximumExponent,:) = [];
                            % then, the exponents are sorted in a nice way,
                            % e.g., fist the zeros, then all the linear
                            % terms, then exponents that sums to 2 with
                            % precedence to interaction terms, and so on...
                            [~,isort]=sort(prod((Xrs.NmaximumExponent-1).^(Xrs.Mexponents),2)...
                                +sum((Xrs.NmaximumExponent-1).^(Xrs.Mexponents),2));
                            Xrs.Mexponents=Xrs.Mexponents(isort,:);
                        else
                            % check that the custom model has the right
                            % number of inputs
                            assert(size(Xrs.Mexponents,2)==Nvar,...
                                'openCOSSAN:ResponseSurface:calibrate',...
                                ['The training data has %d inputs, while '...
                                'the user defined model has %d inputs.'],...
                                Nvar,size(Xrs.Mexponents,2))
                        end
                        % call regstats with the custom model to train
                        % the response surface
                        MD = x2fx(Minputs,Xrs.Mexponents);
                end

                assert(size(MD,2)<=size(Minputs,1),...
                    'openCOSSAN:ResponseSurface:calibrate',...
                    ['Object not calibrated: too few calibration samples.\n ' ...
                    '%d samples are available, while at least ' ...
                    '%d samples are needed.'],(size(MD,1)),(size(MD,2)))

                assert(logical(any(any(~isnan(Moutputs)))),...
                    'openCOSSAN:ResponseSurface:calibrate',...
                    ['Object not calibrated: the output variable contains %d' ...
                    ' NaN values.'],(sum(sum(isnan(Moutputs)))))


                if isempty(Xrs.VridgeCoefficient) || Xrs.VridgeCoefficient(iresponse)==0
                    % this is a least square solution, not the matrix division
                    % it is faster than ridge with 0 coefficient or regstats
                    Xrs.CVCoefficients{iresponse} = MD\Moutputs(:,iresponse); 
                else
                    % this uses ridge regression with no stabilization. You
                    % must remove the constant term to obtain the correct
                    % results.
                    Xrs.CVCoefficients{iresponse} = ridge(Moutputs(:,iresponse),MD(:,2:end),Xrs.VridgeCoefficient(iresponse),0); 
                end
            end
            
        end
    end
end
