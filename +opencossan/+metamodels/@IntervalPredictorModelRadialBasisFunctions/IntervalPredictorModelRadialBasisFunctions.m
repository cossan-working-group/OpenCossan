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
        Nterms {mustBeInteger} = [];
        BasisScale = 1;
        Bound(1,1) string {mustBeMember(Bound,{'Lower','lower','upper','Upper'})} = 'Lower';
        ChanceConstraint(1,1) {mustBePositive, ...
            mustBeLessThanOrEqual(ChanceConstraint,1)} = 1;
    end
    
    properties (SetAccess = protected, GetAccess = public)
        PUpper %The IPM Parameters
        PLower
        RescaleInputs
        Mcenters = [];
        Msigma = [];
        k {mustBeInteger} = 0
        lb = [];
        ub = [];
        net = [];
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
                    case {'basisscale'}
                        obj.BasisScale = varargin{k+1};
                    case {'nterms'}
                        obj.Nterms = varargin{k+1};
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
                                                
                    case{'xcalibrationoutput','cxcalibrationoutput'}
                        if isa(varargin{k+1},'cell')
                            obj.XcalibrationOutput  = varargin{k+1}{1};
                        else
                            obj.XcalibrationOutput  = varargin{k+1};
                        end
                        
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
                    case{'parambound'}
                        obj.lb = varargin{k+1}(:,1);
                        obj.ub = varargin{k+1}(:,2);
                    otherwise
                        error('openCOSSAN:IntervalPredictorModel',...
                            'PropertyName %s not allowed for a IntervalPredictorModel object', varargin{k})
                end
            end
            
 
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
                
                obj.RescaleInputs=mean(abs(Minputs));
                Minputs=Minputs./obj.RescaleInputs;
                
                obj.Mcenters=zeros(obj.Nterms,Nvar); %Centers should be uniformly distributed throughout inputs
                obj.Msigma=zeros([Nvar Nvar obj.Nterms]);

                obj.net=newrb(Minputs',Moutputs',0,obj.BasisScale,obj.Nterms-1);
% 
                obj.Mcenters(1,:)=zeros(Nvar,1);
                obj.Mcenters(2:obj.Nterms,:)=obj.net.IW{1};
%                 obj.Mcenters = transp(linspace(min(Minputs),max(Minputs),obj.Nterms));
                obj.Msigma(:,:,1)=eye(Nvar)/eps;%add the constant term

                for i=2:obj.Nterms
                    obj.Msigma(:,:,i)=obj.net.b{1}(i-1)^-2*eye(Nvar);
                end

                % call regstats with the custom model to train
                % the response surface
                MD = x2fxExp(Minputs,obj.Mcenters,obj.Msigma);
                MDSum=(mean(abs(MD)));
                objective=[-MDSum,MDSum];
                
                %Get constraints
                Aeq=[];
                beq=[];
%                 lb=[];
%                 ub=[];
                lowerb = repmat(obj.lb,2*obj.Nterms,1);
                upperb = repmat(obj.ub,2*obj.Nterms,1);
                
                Mconstraint=zeros(2*NDataPoints+obj.Nterms,obj.Nterms*2);
                Mconstraint(1:NDataPoints,1:obj.Nterms)=-(MD-abs(MD))/2;
                Mconstraint(NDataPoints+1:2*NDataPoints,1:obj.Nterms)=(MD+abs(MD))/2;
                Mconstraint(1:NDataPoints,obj.Nterms+1:obj.Nterms*2)=-(MD+abs(MD))/2;
                Mconstraint(NDataPoints+1:2*NDataPoints,obj.Nterms+1:obj.Nterms*2)=(MD-abs(MD))/2;
                Mconstraint(2*NDataPoints+1:2*NDataPoints+obj.Nterms,1:obj.Nterms)=eye(obj.Nterms);
                Mconstraint(2*NDataPoints+1:2*NDataPoints+obj.Nterms,obj.Nterms+1:obj.Nterms*2)=-eye(obj.Nterms);
                b=[-Moutputs;Moutputs;zeros(obj.Nterms,1)];
                
                options = optimoptions('fmincon','MaxIter',1000000,...
                    'Algorithm','sqp');
                
                [MIPMParameters]=linprog(objective,Mconstraint,b,Aeq,beq,lowerb,upperb);
                if obj.ChanceConstraint~=1
                    %we can solve quickly with linprog if all inputs are
                    %enclosed, otherwise need to use fmincon
                    nonlinconstraint=@(x) nonlincons(x,Mconstraint(1:2*NDataPoints,1:obj.Nterms*2),b(1:2*NDataPoints),obj.ChanceConstraint);
                    
                    [MIPMParameters]=fmincon(@(x) objective*x, MIPMParameters,Mconstraint(2*NDataPoints+1:end,1:obj.Nterms*2),b(2*NDataPoints+1:end),[],[],[],[],nonlinconstraint,options);
                    
                    tolerance=10^-12;
                    obj.k=sum(tolerance<=Mconstraint(1:2*NDataPoints,1:obj.Nterms*2)*MIPMParameters-b(1:2*NDataPoints));
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
                nPositiveConstraints=sum(positiveConstraints);
                
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
        
        function reliability = getReliability(obj, epsilon)
            nDataPoints = length(obj.McalibrationTarget);
            d = 2 * obj.Nterms;
            
            assert(epsilon >= 0 && epsilon <=1,...
                'openCOSSAN:IntervalPredictorModel:getReliability',...
                'Invalid value of reliability: %d', epsilon);
            
            assert(obj.k < nDataPoints - d,...
                'openCOSSAN:IntervalPredictorModel:getReliability',...
                'Reliability information is invalid: k<N-d is not satisfied.');
            
            reliability = binocdf(obj.k + d - 1, nDataPoints, epsilon);
            reliability = reliability * nchoosek(obj.k + d - 1, obj.k);
            if reliability > 1
                reliability = 1;
            end
        end
    end
end
% 
function out = x2fxExp(Minputs,Mcenters,Msigma)
%Generate radial basis
NDataPoints=size(Minputs,1);
Nterms=size(Mcenters,1);
out=zeros(NDataPoints,Nterms);
for i=1:NDataPoints
    for j=1:Nterms
        out(i,j)=exp(-((Minputs(i,:)-Mcenters(j,:))/(Msigma(:,:,j)))*transpose(Minputs(i,:)-Mcenters(j,:)));
    end
end
end