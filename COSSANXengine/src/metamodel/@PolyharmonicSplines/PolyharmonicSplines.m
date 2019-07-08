classdef PolyharmonicSplines < MetaModel
    %ResponseSurface
    %
    %   This method is the constructor of the class ResponseSurface. It is
    %   intended for creating a response surface that approximates the response
    %   associated with a Model object.
    %
    % See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@ResponseSurface
    %
    % Copyright 1993-2011, COSSAN Working Group, University~of~Innsbruck, Austria
    
    properties
        Stype = 'linear';  % Type of spline; supported types are 'linear', 'quadratic', 'cubic', or any other integer power
        SextrapolationType = 'linear'; % Type of polynomial extrapolation; supported types are 'linear', 'quadratic', 'interaction' or 'purequadratic'
    end
    
    properties (SetAccess = protected, GetAccess = public)
        CVsplinesCoefficients          %Coefficients of the spline basis
        CVpolyCoefficients             %Coefficients of the polynomial part
    end
    
    properties (SetAccess = protected, GetAccess = private)
        Nexponent = 1;     % exponent of the spline basis (converted from Stype)
        Mcenters      % the training inputs must be saved! They are necessary to create an output
    end
    
    methods
        %% Methods of the class
        [varargout]     = apply(Xobj,Xinput);
        %% constructor
        function Xobj=PolyharmonicSplines(varargin)
            %ResponseSurface
            %
            %   This method is the constructor of the class PolyharmonicSplines. It is
            %   intended for creating a Polyharmonic Splines that approximates the response
            %   associated with a Model object. For example, the model can be a FE
            %   model. Please be careful that the spline always pass
            %   through the training points, thus it should not be used
            %   with noisy data.
            %
            % See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@PolyharmonicSplines
            %
            % Copyright 1993-2011, COSSAN Working Group, University~of~Innsbruck, Austria
            
            
            %% Check varargin
            if nargin==0
                % Return an empty object
                return
            end
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            %%  Set the values of the public properties
            for k=1:2:nargin
                switch lower(varargin{k}),
                    % Description of the object
                    case {'sdescription'}
                        Xobj.Sdescription   = varargin{k+1};
                        % Type of response surface
                    case {'stype'}
                        CTypesSupported     = {'linear','quadratic','cubic','custom'};
                        if ismember(lower(varargin{k+1}),CTypesSupported),
                            switch lower(varargin{k+1})
                                case 'linear'
                                    Xobj.Nexponent = 1;
                                case 'quadratic'
                                    Xobj.Nexponent = 2;
                                case 'cubic'
                                    Xobj.Nexponent = 3;
                            end
                        else
                            error('openCOSSAN:PolyharmonicSplines',...
                                '%s is not a valid PolyharmonicSplines type',varargin{k+1})
                        end
                        Xobj.Stype  = lower(varargin{k+1});
                    case {'nexponent'}
                        % check that the exponent values is passed only
                        % when the type "custom" is specified
                        assert(any(strcmp({'custom'},varargin)),...
                            'openCOSSAN:PolyharmonicSplines',...
                            'The spline exponent can be passed only when Stype is "custom"')
                        Xobj.Nexponent = varargin{k+1};
                    case {'sextrapolationtype'}
                        switch lower(varargin{k+1})
                            case{'linear','quadratic','interaction','purequadratic'}
                                Xobj.SextrapolationType=lower(varargin{k+1});
                            otherwise
                                error('openCOSSAN:PolyharmonicSplines',...
                                    '%s is not a valid polynomial extrapolation type',varargin{k+1})
                        end
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
                        
                        assert(isa(Xobj.XcalibrationInput,'Input'), ...
                            'openCOSSAN:PolyharmonicSplines',...
                            'PropertyName %s must be an object of type Input',varargin{k});
                        
                    case{'xcalibrationoutput','cxcalibrationoutput'}
                        if isa(varargin{k+1},'cell')
                            Xobj.XcalibrationOutput  = varargin{k+1}{1};
                        else
                            Xobj.XcalibrationOutput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XcalibrationOutput,'SimulationData'), ...
                            'openCOSSAN:PolyharmonicSplines',...
                            'PropertyName %s must be an object of type SimulationData',varargin{k});
                    case{'xvalidationinput','cxvalidationinput'},
                        
                        if isa(varargin{k+1},'cell')
                            Xobj.XvalidationInput  = varargin{k+1}{1};
                        else
                            Xobj.XvalidationInput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XvalidationInput,'Input'), ...
                            'openCOSSAN:PolyharmonicSplines',...
                            'PropertyName %s must be an object of type Input',varargin{k});
                        
                    case{'xvalidationoutput','cxvalidationoutput'}
                        if isa(varargin{k+1},'cell')
                            Xobj.XvalidationOutput  = varargin{k+1}{1};
                        else
                            Xobj.XvalidationOutput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XvalidationOutput,'SimulationData'), ...
                            'openCOSSAN:PolyharmonicSplines',...
                            'PropertyName %s must be an object of type SimulationData',varargin{k});
                        % Other cases
                    otherwise
                        error('openCOSSAN:PolyharmonicSplines',...
                            'PropertyName %s not allowed for a PolyharmonicSplines object', varargin{k})
                end
            end
            
            % Validate the constructor of the metamodel
            Xobj=validateConstructor(Xobj);         
            
            % Additional validations needed for "custom" model
            if strcmpi(Xobj.Stype,'custom')
                if ~isempty(Xobj.Nexponent)
                    assert(~mod(Xobj.Nexponent,1),...
                        'openCOSSAN:ResponseSurface',...
                        'The maximum exponent must be an integer.')
                end
            end
            
            
        end     %end of constructor
        
        function Xobj = train(Xobj,Minputs,Moutputs)
            %% train
            %
            % train method receive the matrix with inputs and vector with
            % outputs and returns a trained response surface
            %
            
            [Xobj.Mcenters, iUnique, ~] = unique(Minputs,'rows');
            
            % auxiliary variables
            Ncenters = size(Xobj.Mcenters,1);
            Ndim = size(Xobj.Mcenters,2);
            
            switch Xobj.SextrapolationType
                % it is 10x faster than calling
                % size(x2fx(Xobj.Mcenters,Xobj.SextrapolationType),2)
                case 'linear'
                    Nzeros = 1+Ndim;
                case 'interaction'
                    Nzeros = 1+Ndim+Ndim*(Ndim-1)/2;
                case 'quadratic'
                    Nzeros = 1+Ndim+Ndim*(Ndim-1)/2+Ndim;
                case 'purequadratic'
                    Nzeros = 1+2*Ndim;
            end
            
            % check that enough points have been given (at least Ndim+1
            % points are needed, assuming they are not collinears)
            if Ncenters < Ndim +2
                error('openCOSSAN:PolyharmonicSplines:train',...
                    strcat('At least %d centers are needed to calibrate a ',...
                    'spline in dimension %d.\nNumber of available centers: %d'),...
                    Ndim+2, Ndim, Ncenters);
            end
            
            % splines don't need to be bounded, but this is kept for
            % compatibility with metamodel.
            Xobj.MboundsInput = zeros(2,size(Minputs,2));
            for j=1:size(Minputs,2)
                Xobj.MboundsInput(:,j) = [min(Minputs(:,j)); max(Minputs(:,j)) ];
            end
            
            for iresponse=1:size(Moutputs,2)
                % compute the relative distance between each couple of centers
                MA = zeros(Ncenters,Ncenters);
                for idim = 1:Ndim
                    MA = MA + bsxfun(@minus,Xobj.Mcenters(:,idim),Xobj.Mcenters(:,idim)').^2;
                end
                MA = sqrt(MA);
                
                % apply the desired polyharmonic base function
                if bitget(Xobj.Nexponent, 1) %very fast check if integer is odd or even
                    MA = MA.^Xobj.Nexponent;
                else
                    % since the diagonal has zeros, the logarithm return
                    % NaN as an output (0*log(0) is an udetermined form,
                    % but we know that the output we want is 0)
                    MA = MA.^Xobj.Nexponent.*log(MA);
                    % put a zero on the diagonal (or on all the points with
                    % identical coordinates)
                    MA(isnan(MA)) = 0;
                end
                
                Mfull = [[MA,x2fx(Xobj.Mcenters,Xobj.SextrapolationType)];...
                    [x2fx(Xobj.Mcenters,Xobj.SextrapolationType)', zeros(Nzeros,Nzeros)]];
                
                Vfull = [Moutputs(iUnique,iresponse); zeros(Nzeros,1)];
                
                Vweights = linsolve(Mfull,Vfull);
                
                % save coefficients
                Xobj.CVsplinesCoefficients{iresponse} = Vweights(1:Ncenters);
                Xobj.CVpolyCoefficients{iresponse} = Vweights(Ncenters+1:end);
            end
            
        end
    end
end
