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
        MaximumExponent {mustBeInteger} = [];
        Exponents {mustBeInteger} = [];
        Bound(1,1) string {mustBeMember(Bound,{'Lower','lower','upper','Upper'})} = 'Lower';
        ChanceConstraint(1,1) {mustBePositive, ...
            mustBeLessThanOrEqual(ChanceConstraint,1)} = 1;
    end
    
    properties (SetAccess = protected, GetAccess = public)
        PUpper %The IPM Parameters
        PLower
        RescaleInputs
        k {mustBeInteger} = 0
    end
    
    methods
        %% Methods of the class
        XSimDataOutput  = evaluate(Xobj,Pinput)
        [Xobj,varargout] = validate(Xobj,varargin)
        
        function obj = IntervalPredictorModel(varargin)
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
            
            %%  Set the values of the public properties
            for k=1:2:nargin
                switch lower(varargin{k})
                    % Description of the object
                    case{'chanceconstraint'}
                        obj.ChanceConstraint=varargin{k+1};
                    case {'description'}
                        obj.Description   = varargin{k+1};
                    case {'sbound'}
                        obj.Bound   = lower(varargin{k+1});
                    case {'nmaximumexponent','nexponent'}
                        obj.MaximumExponent = varargin{k+1};
                    case {'mexponents'}
                        obj.Exponents = varargin{k+1};
                    case {'outputnames'}
                        % Response of interst
                        obj.OutputNames  = varargin{k+1};
                    case {'inputnames'}
                        % Subset of inputs used to define the metamodel
                        obj.InputNames  = varargin{k+1};
                        % Full model associated with IntervalPredictorModel
                    case{'xfullmodel','cxfullmodel'}
                        if isa(varargin{k+1},'cell')
                            obj.XFullmodel     = varargin{k+1}{1};
                        else
                            obj.XFullmodel     = varargin{k+1};
                        end
                        % Input Object for calibrating ResponseSruface
                    case{'xcalibrationinput','cxcalibrationinput'}
                        
                        if isa(varargin{k+1},'cell')
                            obj.XcalibrationInput  = varargin{k+1}{1};
                        else
                            obj.XcalibrationInput  = varargin{k+1};
                        end
                        
                        assert(isa(obj.XcalibrationInput,'Input'), ...
                            'openCOSSAN:IntervalPredictorModel',...
                            'PropertyName %s must be an object of type Input',varargin{k});
                        
                    case{'xcalibrationoutput','cxcalibrationoutput'}
                        if isa(varargin{k+1},'cell')
                            obj.XcalibrationOutput  = varargin{k+1}{1};
                        else
                            obj.XcalibrationOutput  = varargin{k+1};
                        end
                        
                        assert(isa(obj.XcalibrationOutput,'SimulationData'), ...
                            'openCOSSAN:IntervalPredictorModel',...
                            'PropertyName %s must be an object of type SimulationData',varargin{k});
                    case{'xvalidationinput','cxvalidationinput'}
                        
                        if isa(varargin{k+1},'cell')
                            obj.XvalidationInput  = varargin{k+1}{1};
                        else
                            obj.XvalidationInput  = varargin{k+1};
                        end
                        
                        assert(isa(obj.XvalidationInput,'Input'), ...
                            'openCOSSAN:IntervalPredictorModel',...
                            'PropertyName %s must be an object of type Input',varargin{k});
                        
                    case{'xvalidationoutput','cxvalidationoutput'}
                        if isa(varargin{k+1},'cell')
                            obj.XvalidationOutput  = varargin{k+1}{1};
                        else
                            obj.XvalidationOutput  = varargin{k+1};
                        end
                        
                        assert(isa(obj.XvalidationOutput,'SimulationData'), ...
                            'openCOSSAN:IntervalPredictorModel',...
                            'PropertyName %s must be an object of type SimulationData',varargin{k});
                        % Other cases
                    otherwise
                        error('openCOSSAN:IntervalPredictorModel',...
                            'PropertyName %s not allowed for a IntervalPredictorModel object', varargin{k})
                end
            end
            
            % Check that either the maximum exponent or the matrix of
            % exponents is passed but not both (xor!).
            assert(xor(isempty(obj.MaximumExponent),isempty(obj.Exponents)),...
                'openCOSSAN:IntervalPredictorModel',...
                'Must pass either maximum exponent or the matrix of exponents.');
            
            assert(length(obj.OutputNames) == 1,...
                'openCOSSAN:IntervalPredictorModel',...
                'Currently only one output name is supported');
        end
        
        function obj = train(obj,Minputs,Moutputs)
            %% train
            %
            % train method receive the matrix with inputs and vector with
            % outputs and returns a trained response surface
            %
            
            Nvar = size(Minputs,2);
            NDataPoints=length(obj.McalibrationTarget);
            obj.MboundsInput = zeros(2,Nvar);
            for j=1:Nvar
                obj.MboundsInput(:,j) = [min(Minputs(:,j)); max(Minputs(:,j)) ];
            end
            
            for iresponse=1:size(Moutputs,2)
                
                if isempty(obj.Exponents)
                    % create a full polynomial model of maximum
                    % power NmaximumExponent.
                    % These two lines get all the possible
                    % combination of the exponents (got it from
                    % http://groups.google.com/group/comp.soft-sys.matlab/browse_thread/thread/878717e082473f68)
                    obj.Exponents = fullfact((obj.MaximumExponent+1)*ones(1,Nvar))-1;
                    obj.Exponents(sum(obj.Exponents,2)>obj.MaximumExponent,:) = [];
                    % then, the exponents are sorted in a nice way,
                    % e.g., fist the zeros, then all the linear
                    % terms, then exponents that sums to 2 with
                    % precedence to interaction terms, and so on...
                    [~,isort]=sort(prod((obj.MaximumExponent-1).^(obj.Exponents),2)...
                        +sum((obj.MaximumExponent-1).^(obj.Exponents),2));
                    obj.Exponents=obj.Exponents(isort,:);
                else
                    % check that the custom model has the right
                    % number of inputs
                    assert(size(obj.Exponents,2)==Nvar,...
                        'openCOSSAN:IntervalPredictorModel:calibrate',...
                        ['The training data has %d inputs, while '...
                        'the user defined model has %d inputs.'],...
                        Nvar,size(obj.Exponents,2))
                end
                Nterms=size(obj.Exponents,1);
                
                obj.RescaleInputs=mean(abs(Minputs));
                Minputs=Minputs./obj.RescaleInputs;
                
                % call regstats with the custom model to train
                % the response surface
                MD = x2fx(Minputs,obj.Exponents);
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
                if obj.ChanceConstraint~=1
                    %we can solve quickly with linprog if all inputs are
                    %enclosed, otherwise need to use fmincon
                    nonlinconstraint=@(x) nonlincons(x,Mconstraint(1:2*NDataPoints,1:Nterms*2),b(1:2*NDataPoints),obj.ChanceConstraint);
                    
                    [MIPMParameters]=fmincon(@(x) objective*x, MIPMParameters,Mconstraint(2*NDataPoints+1:end,1:Nterms*2),b(2*NDataPoints+1:end),[],[],[],[],nonlinconstraint,options);
                    
                    tolerance=10^-12;
                    obj.k=sum(tolerance<=Mconstraint(1:2*NDataPoints,1:Nterms*2)*MIPMParameters-b(1:2*NDataPoints));
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
                
                obj.PLower=MIPMParameters(1:end/2);
                obj.PUpper=MIPMParameters(end/2+1:end);                
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
        
        function varargout = reliabilityPlot(obj)
            epsilon = [0:0.001:0.1, 0.11:0.01:1];
            beta = [0:0.001:0.1, 0.11:0.01:1];
            
            for i = 1:length(epsilon)
                if i > 1
                    %Define precision for speed increase here
                    if beta(i-1) > 0.001 
                        beta(i) = getReliability(obj,epsilon(i));
                    else
                        beta(i:length(epsilon)) = 0;
                        break;
                    end
                else
                    beta(i) = 1;
                end
            end
            
            h = figure;
            hold on;
            plot(1-beta,1-epsilon)
            xlabel('Confidence');
            ylabel('Model Reliability');
            axis([0 1 0 1]);
            hold off;
            
            if nargout == 1
                varargout{1} = h;
            end
        end
        
        function reliab=getReliability(Xobj,epsilon)
            nDataPoints=length(Xobj.McalibrationTarget);
            Nterms=size(Xobj.Exponents,1);
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
