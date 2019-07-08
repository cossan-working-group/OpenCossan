function [XmodelOut,varargout] = updateSensitivity(Xobj,varargin )
%UPDATE Summary of this function goes here
%   Detailed explanation goes here
% Default values in case it were not passed by the user

%% Setting default optimizer
Xoptimizer=Cobyla;% default value
Xobj.Mweighterror=eye(size(Xobj.Xmodel.Xevaluator.Coutputnames,2));
Xobj.Mweightregularisation=eye(size(Xobj.Xmodel.Xevaluator.Coutputnames,2));

%% Process input
OpenCossan.validateCossanInputs(varargin{:});
for k=1:2:length(varargin)
    switch(lower(varargin{k}))
        case{'xoptimizer'}
            % optimizer
            assert(isa(varargin{k+1},'Optimizer'),'OpenCossan:ModelUpdating:updateSensitivity',...
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
VdefaultValues=Xobj.Xmodel.Xinput.getValues('Cnames',Xobj.Cinputnames);
for n=1:length(VdefaultValues)
    Xdv=DesignVariable('Sdescription',Xobj.Cinputnames{n},...
                                     'value',VdefaultValues(n),...
                                     'lowerBound',Xobj.VlowerBounds(n),...
                                     'upperBound',Xobj.VupperBounds(n));
   Xmdl.Xinput.Xparameters  = rmfield(Xmdl.Xinput.Xparameters,Xobj.Cinputnames{n}); % Remove parameter from Input object
   Xmdl.Xinput.XdesignVariable.(Xobj.Cinputnames{n})=Xdv;                             % Add Design Variable to input object
end
% Creating objective function to be optimized. Summ of errors over all
% experimental data
Xobjfun=ObjectiveFunction('Sdescription','objective function', ...
                                             'Afunction',@(x)evaluateFitness(Xobj,x),...
                                             'Cinputnames',Xobj.Cinputnames,...
                                             'Coutputnames',{'fitness'},...
                                             'Lfunction',true,...
                                             'Liomatrix',true, ...
                                             'Liostructure',false);
Xop=OptimizationProblem('Sdescription','Optimization problem',...
                                           'Xmodel',Xmdl,...
                                           'VinitialSolution',VdefaultValues,...
                                           'XobjectiveFunction',Xobjfun);
Xoptimum=Xop.optimize('Xoptimizer',Xoptimizer);

%Get values from optimum object

VupdatedValue=Xoptimum.VoptimalDesign;

% Set Model to be outputed with the updated parameters 
XmodelOut=Xobj.Xmodel;
XinputUpdated=XmodelOut.Xinput;
%Updates only the input parameters of the model
for iDV=1:length(VdefaultValues)
         XinputUpdated=XinputUpdated.set('Sname',Xobj.Cinputnames{iDV},...
                       'SpropertyName','parametervalue',...
                       'value',VupdatedValue(iDV,end) );
end
XmodelOut.Xinput=XinputUpdated;    
varargout{1}=Xoptimum;
end

