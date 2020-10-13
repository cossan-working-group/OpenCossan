function [XmodelOut,varargout] = updateSensitivity(Xobj,varargin )
%UPDATE Summary of this function goes here
%   Detailed explanation goes here
% Default values in case it were not passed by the user

%% Setting default optimizer
Xoptimizer=opencossan.optimization.Cobyla;% default value
Xobj.Mweighterror=eye(size(Xobj.Xmodel.Evaluator.Coutputnames,2));
Xobj.Mweightregularisation=eye(size(Xobj.Xmodel.Evaluator.Coutputnames,2));

%% Process input
%OpenCossan.validateCossanInputs(varargin{:});
for k=1:2:length(varargin)
    switch(lower(varargin{k}))
        case{'xoptimizer'}
            % optimizer
            assert(isa(varargin{k+1},'opencossan.optimization.Optimizer'),'OpenCossan:ModelUpdating:updateSensitivity',...
             'The object after the PropertyName Xoptimizer must be of an Optimizer subclass.')
            Xoptimizer = varargin{k+1};
        case{'regularizationfactor'} % regularization factor
            Xobj.Regularizationfactor = varargin{k+1};
        case{'luseregularization'} % regularization factor
            Xobj.LuseRegularization = varargin{k+1};
        case{'mweighterror'}  % regularization factor for error function term
            Xobj.Mweighterror= varargin{k+1};
        case{'mweightregularisation'}  % regularization factor for regularisation term
            Xobj.Mweightregularisation = varargin{k+1};            
        otherwise
            error('openCOSSAN:ModelUpdating:updateSensitivity',...
                    'PropertyName %s not allowed for method updateSensitivity', varargin{k})
    end
end
assert(~isempty(Xoptimizer),'OpenCossan:ModelUpdating:updateSensitivity',...
                                              'It is mandatory to specify Xoptimizer.')                   
%% -----------------Preparation phase to perform optimization--------------
% Get the Xmodel Object from the Modelpdating class and make a copy to
% object 'Xmdl'
Xmdl=Xobj.Xmodel;
% Update the inputs of this model with those from the optimisation problem
TableDefaultValues = Xobj.Xmodel.Input.getDefaultValues();
VdefaultValues=TableDefaultValues{:,Xobj.Cinputnames};
for n=1:length(VdefaultValues)
    Xdv=opencossan.optimization.ContinuousDesignVariable('description',Xobj.Cinputnames{n},...
                                     'value',VdefaultValues(n),...
                                     'lowerBound',Xobj.VlowerBounds(n),...
                                     'upperBound',Xobj.VupperBounds(n));
    Xmdl.Input = Xmdl.Input.remove('Name',Xobj.Cinputnames{n}); % Remove parameter from Input object
    Xmdl.Input=Xmdl.Input.add('Member',Xdv,'Name',Xobj.Cinputnames{n});                             % Add Design Variable to input object
end
% Creating objective function to be optimized. Summ of errors over all
% experimental data
Xobjfun=opencossan.optimization.ObjectiveFunction('description','objective function', ...
                                             'FunctionHandle',@(x)evaluateFitness(Xobj,x),...
                                             'IsFunction',true,...
                                             'InputNames',Xobj.Cinputnames,...
                                             'OutputNames',{'fitness'},...
                                             'format','matrix');
Xop=opencossan.optimization.OptimizationProblem('Description','Optimization problem',...
                                           'Model',Xmdl,...
                                           'InitialSolution',VdefaultValues,...
                                           'objectivefunctions',Xobjfun);
Xoptimum=Xop.optimize('optimizer',Xoptimizer);

% Set Model to be outputed with the updated parameters 
XmodelOut=Xobj.Xmodel;
XinputUpdated=XmodelOut.Input;
%Updates only the input parameters of the model
for iDV=1:length(VdefaultValues)
    Xparameter = XinputUpdated.Parameters(iDV);
    Xparameter.Value = Xoptimum.OptimalSolution(iDV);
    XinputUpdated=XinputUpdated.remove('Name',Xobj.Cinputnames{iDV});
    XinputUpdated=XinputUpdated.add('Member',Xparameter,'Name',Xobj.Cinputnames{iDV});
end
XmodelOut.Input=XinputUpdated;    
varargout{1}=Xoptimum;
end

