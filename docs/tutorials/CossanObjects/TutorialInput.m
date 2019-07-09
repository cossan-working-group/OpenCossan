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
clear
close all;
clc;

import opencossan.common.inputs.*
import opencossan.common.inputs.stochasticprocess.*
%% Create additional object
% Now we create 4 different parameter objects that will be included in the
% Input object. Please refer to the documentation of the Parameter for more
% details
Xmat1   = Parameter('Description','material 1 E','value',7E+7);
Xmat2   = Parameter('Description','material 2 E','value',2E+7);
Xmat3   = Parameter('Description','material 3 E','value',1E+4);
Xconfiguration  = Parameter('Description','material configuration','value',unidrnd(3,16,16));

% TODO: Update after new RandomVariable are merged
% Now we create RandomVariable and RandomVariableSet
x1  = opencossan.common.inputs.random.NormalRandomVariable('mean',2.763,'std',0.4);
x2  = opencossan.common.inputs.random.NormalRandomVariable('mean',1.25,'std',0.4);
Xrvs1 = opencossan.common.inputs.random.RandomVariableSet('names',{'x1','x2'},'members',[x1 x2]);

% Create a second RandomVariableSet
% Definition of Random Variables
x3  = opencossan.common.inputs.random.UniformRandomVariable('Bounds',[0; 10]);
x4  = opencossan.common.inputs.random.UniformRandomVariable('Bounds',[5, 1]);

Xrvs2   = opencossan.common.inputs.random.RandomVariableSet('names',{'x3','x4'},'members',[x3 x4]);

% Create RandomVariableSet with IID RandomVariable
Xrvs3 = opencossan.common.inputs.random.RandomVariableSet('members',x1,'Nrv',10,'names',{'x1'});
    
%% Create Functions
Xfun1   = Function('Description','function #1', ...
    'Expression','<&x3&>+<&x4&>');
Xfun2   = Function('Description','function #2', ...
    'Expression','<&Xmat3&>./<&x1&>');
Xfun3   = Function('Description','function #2', ...
    'Expression','<&Xmat3&>+1');

%% Create an Input passing all the objects at once

%% Create an Input passing one object per type, then adding the others

%% Create an Input object that contains all the object already prepared
Xin=Input('Description','My first Input'); % initialize Input object

% Add parameters to the input object
Xin = Xin.add('Member',Xconfiguration,'Name','Xconfiguration');
Xin = Xin.add('Member',Xmat1,'Name','Xmat1');
Xin = Xin.add('Member',Xmat2,'Name','Xmat2');
Xin = Xin.add('Member',Xmat3,'Name','Xmat3');
% Add RandomVariable
Xin     = Xin.add('Member',Xrvs1,'Name','Xrvs1');
Xin     = Xin.add('Member',Xrvs2,'Name','Xrvs2');
Xin     = Xin.add('Member',Xrvs3,'Name','Xrvs3');

% Add Functions
Xin = Xin.add('Member',Xfun1,'Name','Xfun1');
Xin = Xin.add('Member',Xfun2,'Name','Xfun2');
Xin = Xin.add('Member',Xfun3,'Name','Xfun3');

%% Show summary of the Input object
display(Xin)

%% Get the numerical values from the Input Object
% The default values of the input factors can be extracted using the
% methods getDefaultValuesStructure and getDefaultValuesCell to obtain the
% values is a structure or in a cell, respectively

% Return values in a cell
Xin.getDefaultValuesCell

% Return values in a Structure
Xin.getDefaultValuesStructure

% Return values in a Structure
[m,v]=Xin.getMoments('CSnames',Xin.RandomVariableNames)

%% Generate samples from the Input object
% Realisation of the input values can be obtained calling the method sample
% of the Input object. The samples are stored in a Samples object that is
% accessible from the field Xsamples of the Input object. 

Xin = Xin.sample; % Generate a single sample
display(Xin)

Xin = Xin.sample('Nsamples',20); % Generate 20 samples and replace the 
                                     % previous generated sample
display(Xin)

% Add additional samples to the previous sample                                     
Xin = Xin.sample('Nsamples',25,'AddSamples',true);
display(Xin)

% Access the Samples object
Xin.Samples

% The realisations of the inputs can be extracted using the methods
% getValues and specifing the name of the variable
Xin.getValues('VariableName','Xfun1')

% or to extract more variables at the same time
Xin.getValues('VariableNames',{'Xfun1', 'Xfun2'})

% or to the entire sample set in a matrix format 
Xin.getSampleMatrix
% and in a structure
Xin.getStructure

%% Using get and dependent field to retrieve information from Xinput
% get the list of the  RandomVariableSet
Cname=Xin.RandomVariableNames;
display('Name of the RandomVariableSet')
display(Cname)
% get the list of the Parameter
Cname=Xin.ParameterNames;
display('Name of the Parameter')
display(Cname)
% get the list of Function
Cname=Xin.FunctionNames;
display('Name of the Function')
display(Cname)
% get the list of StochasticProcess
Cname=Xin.StochasticProcessNames;
display('Name of the StochasticProcess')
display(Cname')
% get the list of all variables
Cname=Xin.Names;
display('Name of the Variable present in the Input')
display(Cname)

%% Retrieve values from the Input object
% recompute the values of the function
Vfvalues=get(Xin,'FunctionValues');
display(Vfvalues)

% The function returns a cell array
Cvalue=Xin.getValues('VariableName','Xfun1');
display(Cvalue)

% retrive the values of the input (as a structure)
Tstruct=Xin.getStructure;
display(Tstruct)

% or as a matrix (rvs and functions only)
Msamples=Xin.getSampleMatrix;
display(Msamples);

% retrieve default values of the Xinput (i.e. mean values of the rvs)
get(Xin,'DefaultValues')


%% USAGE OF STOCHASTIC PROCESS WITH INPUT OBJECT
% See TutorialKarhunenLoeve for an explanation of the KarhunenLoeve class

Xcovfun  = CovarianceFunction('Description','covariance function', ...
    'IsFunction',false,'Format','structure',...
    'Script', strcat('sigma = 1; b = 0.5; for i=1:length(Tinput), ',...
    'Toutput(i).fcov  = sigma^2*exp(-1/b*abs(Tinput(i).x_2-Tinput(i).x_1));',...
    'end'), 'OutputNames',{'fcov'}); % Define the outputs

% Now we create a KarhunenLoeve object that is able to generate the
% stochastic process based on the Karhunen-Loeve expansion.
SP1    = KarhunenLoeve('Distribution','normal',...
    'Mean',0,'CovarianceFunction',Xcovfun,...
    'Coordinates',linspace(0,5,101),'IsHomogeneous',true);
SP1 = SP1.computeTerms('NumberTerms',20,'AssembleCovariance',true);

% Add stochastic process to the Input object
Xin    = Input('Members',{SP1,SP1,SP1},'MembersNames',{'SP1','SP2','SP3'});

% Generate samples of all defined stochastic processes
Xin = Xin.sample('NSamples',2);
Xs  = Xin.Samples;

% The object contains three dataseries (collection of dataseries)
ds2 = Xs.Xdataseries;

Xin = sample(Xin,'Nsamples',15,'AddSamples',true); % add samples to already generates samples in Xin
Xs  = Xin.Samples;
ds2 = Xs.Xdataseries;


% Define parameters, functions, random variables and random variable sets

Xmat1   = Parameter('Description','material 1 E','Value',7E+7);
Xmat2   = Parameter('Description','material 2 E','Value',2E+7);
Xmat3   = Parameter('Description','material 3 E','Value',1E+4);
Mconf   = unidrnd(3,16,16);
Xconfiguration  = Parameter('Description','material configuration','Value',Mconf);

Xin = add(Xin,'Member',Xmat1,'Name','Xmat1');
Xin = add(Xin,'Member',Xmat2,'Name','Xmat2');
Xin = add(Xin,'Member',Xmat3,'Name','Xmat3');
Xin = add(Xin,'Member',Xconfiguration,'Name','Xconfiguration');

Xfun1   = Function('Description','function #1','Expression','<&Xmat3&>*<&x1&>');
Xfun2   = Function('Description','function #2','Expression','<&Xmat3&>+1');
Xin = add( Xin,'Member',Xfun2,'Name','Xfun2');
x1  = RandomVariable('Sdistribution','normal','mean',2.763,'std',0.4);
x2  = RandomVariable('Sdistribution','normal','mean',1.25,'std',0.4);
x3  = RandomVariable('Sdistribution','normal','mean',4,'std',0.4);
x4  = RandomVariable('Sdistribution','uniform','mean',5,'std',1);

Cmems   = {'x1'; 'x2'};
Xrvs1     = RandomVariableSet('Cmembers',Cmems);
Cmems   = {'x3'; 'x4'};
Xrvs2   = RandomVariableSet('Cmembers',Cmems);
Xin     = add(Xin,'Member',Xrvs1,'Name','Xrvs1');
Xin     = add(Xin,'Member',Xrvs2,'Name','Xrvs1');

% Generate samples of random variables and stochastic processes
Xin = Xin.sample('Nsamples',10);
display(Xin)

%% validate solution (part of samples of SP1)

Vdata = Xin.Samples.Xdataseries(1,1).Vdata;
assert(all(abs(Vdata(1:10)-[ -0.0135   -0.4616   -1.1806   -1.8682...
    -2.2480   -2.1991   -1.7961   -1.2487   -0.7832   -0.5369])<1.e-4),...
    'CossanX:Tutorials:TutorialDataseries', ...Vdata = Xin.Xsamples.Xdataseries(1,1).Vdata;
    'Reference Solution ds1 does not match.');



OpenCossan.cossanDisp('End of the Tutorial, bye bye! ')

