classdef IntervalPredictorModel < opencossan.metamodels.MetaModel
    %IntervalPredictorModel
    %
    %   This method is the constructor of the class IntervalPredictorModel. It is
    %   intended for creating a response surface that approximates the response
    %   associated with a Model object.
    %
    % See also:  http://cossan.co.uk/wiki/index.php/@IntervalPredictorModel
    %
    % Copyright 2018, Jonathan Sadeghi, COSSAN Working Group,
    % University~of~Liverpool, United Kingdom
    
    properties
        NmaximumExponent
        Mexponents
        Bound='Lower'
        chanceConstraint=1 %Enclose all input data
    end
    
    properties (SetAccess = protected, GetAccess = public)
        PUpper %The IPM Parameters
        PLower
        rescaleInputs
        k=0
    end
    
    methods
        %% Methods of the class
        XSimDataOutput  = evaluate(Xobj,Pinput)
        [Xobj,varargout] = validate(Xobj,varargin)
        
        %% constructor
        function Xobj=IntervalPredictorModel(varargin)
            %IntervalPredictorModel
            %
            %   This method is the constructor of the class IntervalPredictorModel. It is
            %   intended for creating a response surface that approximates the response
            %   associated with a Model object. For example, the model can be a FE
            %   model.
            %
            % See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@IntervalPredictorModel
            
            import opencossan.*
            
            %% Check varargin
            if nargin==0
                % Return an empty object
                return
            end
            
            %OpenCossan.validateCossanInputs(varargin{:})
            
            %%  Set the values of the public properties
            for k=1:2:nargin
                switch lower(varargin{k}),
                    % Description of the object
                    case{'chanceconstraint'}
                        Xobj.chanceConstraint=varargin{k+1};
                    case {'description'}
                        Xobj.Description   = varargin{k+1};
                    case {'sbound'}
                        Xobj.Bound   = lower(varargin{k+1});
                    case {'nmaximumexponent','nexponent'}
                        Xobj.NmaximumExponent = varargin{k+1};
                    case {'mexponents'}
                        Xobj.Mexponents = varargin{k+1};
                    case {'outputnames'}
                        % Response of interst
                        Xobj.OutputNames  = varargin{k+1};
                    case {'inputnames'},
                        % Subset of inputs used to define the metamodel
                        Xobj.InputNames  = varargin{k+1};
                        % Full model associated with IntervalPredictorModel
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
                            'openCOSSAN:IntervalPredictorModel',...
                            'PropertyName %s must be an object of type Input',varargin{k});
                        
                    case{'xcalibrationoutput','cxcalibrationoutput'}
                        if isa(varargin{k+1},'cell')
                            Xobj.XcalibrationOutput  = varargin{k+1}{1};
                        else
                            Xobj.XcalibrationOutput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XcalibrationOutput,'SimulationData'), ...
                            'openCOSSAN:IntervalPredictorModel',...
                            'PropertyName %s must be an object of type SimulationData',varargin{k});
                    case{'xvalidationinput','cxvalidationinput'},
                        
                        if isa(varargin{k+1},'cell')
                            Xobj.XvalidationInput  = varargin{k+1}{1};
                        else
                            Xobj.XvalidationInput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XvalidationInput,'Input'), ...
                            'openCOSSAN:IntervalPredictorModel',...
                            'PropertyName %s must be an object of type Input',varargin{k});
                        
                    case{'xvalidationoutput','cxvalidationoutput'}
                        if isa(varargin{k+1},'cell')
                            Xobj.XvalidationOutput  = varargin{k+1}{1};
                        else
                            Xobj.XvalidationOutput  = varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XvalidationOutput,'SimulationData'), ...
                            'openCOSSAN:IntervalPredictorModel',...
                            'PropertyName %s must be an object of type SimulationData',varargin{k});
                        % Other cases
                    otherwise
                        error('openCOSSAN:IntervalPredictorModel',...
                            'PropertyName %s not allowed for a IntervalPredictorModel object', varargin{k})
                end
            end
            
            % Validate the constructor of the metamodel
%            Xobj=validateConstructor(Xobj);
            
            
            if ~isempty(Xobj.NmaximumExponent)
                assert(~mod(Xobj.NmaximumExponent,1),...
                    'openCOSSAN:IntervalPredictorModel',...
                    'The maximum exponent must be an integer.')
            elseif ~isempty(Xobj.Mexponents)
                assert(~any(mod(Xobj.Mexponents,1)),...
                    'openCOSSAN:IntervalPredictorModel',...
                    'The model matrix must contain only integers')
            end
            
            % check that either the maximum exponent or the custom model
            % has been passed when Stype is custom
            if isempty(Xobj.NmaximumExponent) && isempty(Xobj.Mexponents)
                error('openCOSSAN:IntervalPredictorModel',...
                    ['Either the maximum exponent or the matrix of expoents'...
                    ' is required to define a custom model.'])
            end
            if ~isempty(Xobj.NmaximumExponent) && ~isempty(Xobj.Mexponents)
                error('openCOSSAN:IntervalPredictorModel',...
                    ['Only require NmaximumExponent or Mexponent'])
            end
            
            assert(Xobj.chanceConstraint>0&&Xobj.chanceConstraint<=1,...
                'openCOSSAN:IntervalPredictorModel',...
                'The fraction of contained input data must be between 0 and 1')
            assert(length(Xobj.chanceConstraint)==1,...
                'openCOSSAN:IntervalPredictorModel',...
                'The fraction of contained input data must be a scalar quantity')
            assert(length(Xobj.OutputNames)==1,'openCOSSAN:IntervalPredictorModel',...
                'Currently only one output name is supported')
            assert((strcmpi(Xobj.Bound,'lower')||strcmpi(Xobj.Bound,'upper')),...
                'openCOSSAN:IntervalPredictorModel',...
                'can create either upper or lower bound')
        end     %end of constructor
        
        function Xobj = train(Xobj,Minputs,Moutputs)
            %% train
            %
            % train method receive the matrix with inputs and vector with
            % outputs and returns a trained response surface
            %
            
            Nvar = size(Minputs,2);
            NDataPoints=length(Xobj.McalibrationTarget);
            Xobj.MboundsInput = zeros(2,Nvar);
            for j=1:Nvar
                Xobj.MboundsInput(:,j) = [min(Minputs(:,j)); max(Minputs(:,j)) ];
            end
            
            for iresponse=1:size(Moutputs,2)
                
                if isempty(Xobj.Mexponents)
                    % create a full polynomial model of maximum
                    % power NmaximumExponent.
                    % These two lines get all the possible
                    % combination of the exponents (got it from
                    % http://groups.google.com/group/comp.soft-sys.matlab/browse_thread/thread/878717e082473f68)
                    Xobj.Mexponents = fullfact((Xobj.NmaximumExponent+1)*ones(1,Nvar))-1;
                    Xobj.Mexponents(sum(Xobj.Mexponents,2)>Xobj.NmaximumExponent,:) = [];
                    % then, the exponents are sorted in a nice way,
                    % e.g., fist the zeros, then all the linear
                    % terms, then exponents that sums to 2 with
                    % precedence to interaction terms, and so on...
                    [~,isort]=sort(prod((Xobj.NmaximumExponent-1).^(Xobj.Mexponents),2)...
                        +sum((Xobj.NmaximumExponent-1).^(Xobj.Mexponents),2));
                    Xobj.Mexponents=Xobj.Mexponents(isort,:);
                else
                    % check that the custom model has the right
                    % number of inputs
                    assert(size(Xobj.Mexponents,2)==Nvar,...
                        'openCOSSAN:IntervalPredictorModel:calibrate',...
                        ['The training data has %d inputs, while '...
                        'the user defined model has %d inputs.'],...
                        Nvar,size(Xobj.Mexponents,2))
                end
                Nterms=size(Xobj.Mexponents,1);
                
                Xobj.rescaleInputs=mean(abs(Minputs));
                Minputs=Minputs./Xobj.rescaleInputs;
                
                % call regstats with the custom model to train
                % the response surface
                MD = x2fx(Minputs,Xobj.Mexponents);
                MDSum=(mean(abs(MD)));
                objective=[-MDSum,MDSum];
                
                %Get constraints
                Aeq=[];
                beq=[];
                lb=[];
                ub=[];
                
                Mconstraint=zeros(2*NDataPoints+Nterms,Nterms*2);
                Mconstraint(1:NDataPoints,1:Nterms)=-(MD-abs(MD))/2;
                Mconstraint(NDataPoints+1:2*NDataPoints,1:Nterms)=(MD+abs(MD))/2;
                Mconstraint(1:NDataPoints,Nterms+1:Nterms*2)=-(MD+abs(MD))/2;
                Mconstraint(NDataPoints+1:2*NDataPoints,Nterms+1:Nterms*2)=(MD-abs(MD))/2;
                Mconstraint(2*NDataPoints+1:2*NDataPoints+Nterms,1:Nterms)=eye(Nterms);
                Mconstraint(2*NDataPoints+1:2*NDataPoints+Nterms,Nterms+1:Nterms*2)=-eye(Nterms);
                b=[-Moutputs;Moutputs;zeros(Nterms,1)];
                
                options = optimoptions('fmincon','MaxIter',1000000,...
                    'Algorithm','sqp');
                
                [MIPMParameters]=linprog(objective,Mconstraint,b,Aeq,beq,lb,ub);
                if Xobj.chanceConstraint~=1
                    %we can solve quickly with linprog if all inputs are
                    %enclosed, otherwise need to use fmincon
                    nonlinconstraint=@(x) nonlincons(x,Mconstraint(1:2*NDataPoints,1:Nterms*2),b(1:2*NDataPoints),Xobj.chanceConstraint);
                    
                    [MIPMParameters]=fmincon(@(x) objective*x, MIPMParameters,Mconstraint(2*NDataPoints+1:end,1:Nterms*2),b(2*NDataPoints+1:end),[],[],[],[],nonlinconstraint,options);
                    
                    tolerance=10^-12;
                    Xobj.k=sum(tolerance<=Mconstraint(1:2*NDataPoints,1:Nterms*2)*MIPMParameters-b(1:2*NDataPoints));
                end
                
                assert(size(MD,2)<=size(Minputs,1),...
                    'openCOSSAN:IntervalPredictorModel:calibrate',...
                    ['Object not calibrated: too few calibration samples.\n ' ...
                    '%d samples are available, while at least ' ...
                    '%d samples are needed.'],(size(MD,1)),(size(MD,2)))
                
                assert(logical(any(any(~isnan(Moutputs)))),...
                    'openCOSSAN:IntervalPredictorModel:calibrate',...
                    ['Object not calibrated: the output variable contains %d' ...
                    ' NaN values.'],(sum(sum(isnan(Moutputs)))))
                
                Xobj.PLower=MIPMParameters(1:end/2);
                Xobj.PUpper=MIPMParameters(end/2+1:end);                
            end
            
            function [ constraints,eq,gradc,gradeq ] = nonlincons( x,A,b,tol )
                %Chance Constrainted Optimisation Constraints (required for IPMs)               
                constraints=A*x-b;
                
                positiveConstraints=constraints>0;
                nPositiveConstraints=length(positiveConstraints);
                
                [~,I]=sort(constraints);
                
                nToRemove=min(nPositiveConstraints,floor((1-tol)*NDataPoints));
                
                constraints(I(end-nToRemove:end))=0;
                
                gradc=[];
                
                eq=[];
                gradeq=[];                
            end
            
        end
        
        function reliabilityPlot(Xobj)
            epsilon=[[0:0.001:0.1],[0.1:0.01:1]];
            beta=[[0:0.001:0.1],[0.1:0.01:1]];
            
            for i=1:length(epsilon)
                if i>1
                    if beta(i-1)>0.001 %Define precision for speed increase here
                        beta(i)=getReliability(Xobj,epsilon(i));
                    else
                        beta(i:length(epsilon))=0;
                        break;
                    end
                else
                    beta(i)=1;
                end
            end
            
            plot(1-beta,1-epsilon)
            hold
            xlabel('confidence') % x-axis label
            ylabel('model reliability') % y-axis label
            axis([0 1 0 1])
            hold off
        end
        function reliab=getReliability(Xobj,epsilon)
            nDataPoints=length(Xobj.McalibrationTarget);
            Nterms=size(Xobj.Mexponents,1);
            d=2*Nterms;
            
            if epsilon<0||epsilon>1
                error('openCOSSAN:IntervalPredictorModel:calibrate',...
                    'Invalid value of reliability - this reliability is impossible');
            else
                if ~(Xobj.k<nDataPoints-d)
                    error('openCOSSAN:IntervalPredictorModel:calibrate',...
                        'k<N-d is not satisfied - Reliability information is invalid')
                else
                    reliab=0;
                    if epsilon>=0&&epsilon<=1
                        reliab=binocdf(Xobj.k+d-1,nDataPoints,epsilon);
                    else
                        error('Epsilon should be between 0 and 1')
                    end
                    reliab=reliab*nchoosek(Xobj.k+d-1,Xobj.k);
                    if (reliab>1)
                        reliab=1;
                    end
                end
            end
        end
    end
end
