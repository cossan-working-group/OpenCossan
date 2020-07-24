%% TUTORIALINPUT
% This turorial shows how to create and use an Input object
% The Input object is uses to generate samples of random variables,
% collection of parameters, function, stochastic process and design
% variables.
%
% See Also:  TutorialParameter
% TutorialRandomVariable TutorialRandomVariableSet TutorialDesingVariable
% TutorialStochasticProcess TutorialFunction
%
% $Copyright~1993-2017,~COSSAN~Working~Group$
% $https://cossan.co.uk/wiki/index.php/@CossanX$
% $Author: Edoardo-Patelli$

import opencossan.common.inputs.*
import opencossan.common.inputs.stochasticprocess.*
%% Create additional object
% Now we create 4 different parameter objects that will be included in the
% Input object. Please refer to the documentation of the Parameter for more
% details
mat1 = Parameter('Description','material 1 E','value',7E+7);
mat2 = Parameter('Description','material 2 E','value',2E+7);
mat3 = Parameter('Description','material 3 E','value',1E+4);

% Now we create RandomVariable and RandomVariableSet
x1  = opencossan.common.inputs.random.NormalRandomVariable('mean',2.763,'std',0.4);
x2  = opencossan.common.inputs.random.NormalRandomVariable('mean',1.25,'std',0.4);
rvset1 = opencossan.common.inputs.random.RandomVariableSet('names',{'x1','x2'},'members',[x1 x2]);

% Create a second RandomVariableSet
% Definition of Random Variables
x3  = opencossan.common.inputs.random.UniformRandomVariable('Bounds',[0; 10]);
x4  = opencossan.common.inputs.random.UniformRandomVariable('Bounds',[1, 5]);

rvset2   = opencossan.common.inputs.random.RandomVariableSet('names',{'x3','x4'},'members',[x3 x4]);

% Create RandomVariableSet with IID RandomVariable
rvset3 = opencossan.common.inputs.random.RandomVariableSet.fromIidRandomVariables (x1, 3,'basename','iid');

%% Create Functions
fun1 = Function('Description', 'function #1', 'Expression', '<&x3&>+<&x4&>');
fun2 = Function('Description', 'function #2', 'Expression', '<&mat3&>./<&x1&>');
fun3 = Function('Description', 'function #2', 'Expression', '<&mat3&>+1');

%% Create an Input object from prepared inputs
input = Input('members', {mat1, mat2, mat3}, ...
    'names', ["mat1", "mat2", "mat3"]);

% Inputs can also be added individually
input = input.add('Member',rvset1,'Name','rvset1');
input = input.add('Member',rvset2,'Name','rvset2');
input = input.add('Member',rvset3,'Name','rvset3');

input = input.add('Member',fun1,'Name','fun1');
input = input.add('Member',fun2,'Name','fun2');
input = input.add('Member',fun3,'Name','fun3');

%% Show summary of the Input object
display(input)

%% Get the numerical values from the Input Object
% The default values of the input factors can be extracted using the methods getDefaultValues

input.getDefaultValues()

% Return moments of random variables in the input
[mean, std] = input.getMoments()

%% Generate samples from the Input object

samples = input.sample('samples',2); % Generate 2 samples
display(samples);

%% Using dependent fields to retrieve information from Xinput

names = input.RandomVariableSetNames;
fprintf('Names of the RandomVariableSet: %s\n', strjoin(names, ", "));

% get the list of the Parameter
names = input.ParameterNames;
fprintf('Names of the Parameters: %s\n', strjoin(names, ", "));

% get the list of Function
names = input.FunctionNames;
fprintf('Names of the Functions: %s\n', strjoin(names, ", "));

% get all names
names = input.Names;
fprintf('Names of the Variables: %s\n', strjoin(names, ", "));


%% USAGE OF STOCHASTIC PROCESS WITH INPUT OBJECT
% See TutorialKarhunenLoeve for an explanation of the KarhunenLoeve class

Xcovfun = opencossan.common.inputs.stochasticprocess.CovarianceFunction(...
    'FunctionHandle', @(x) 1^2*exp(-1/0.5*abs(x(:,1) - x(:,2))), ...
    'IsFunction', true, 'Format', 'matrix', 'OutputNames',{'fcov'}, ...
    'InputNames', {'x_1', 'x_2'});

% Now we create a KarhunenLoeve object that is able to generate the
% stochastic process based on the Karhunen-Loeve expansion.
sp  = opencossan.common.inputs.stochasticprocess.KarhunenLoeve('Distribution','normal',...
    'Mean',0,'CovarianceFunction',Xcovfun,...
    'Coordinates',linspace(0,5,101),'IsHomogeneous',true);
sp = sp.computeTerms('NumberTerms',20,'AssembleCovariance',true);

% Add stochastic process to the Input object
input = input.add('member', sp, 'name', "SP1");
input = input.add('member', sp, 'name', "SP2");
input = input.add('member', sp, 'name', "SP3");

% Generate samples of random variables and stochastic processes. The dataseries of the stochastic
% processes are returned as a second output from the sample method.
[samples, ds] = input.sample('samples', 10);

