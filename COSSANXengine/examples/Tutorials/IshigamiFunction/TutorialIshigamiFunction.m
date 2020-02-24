%% Tutorial ISHIGAMI FUNCTION
% In this tutorial we show how to connect OpenCossab to an external solver via
% ASCII file manipulation. 
%
% The solver (ishigamifunction) is a C code and requires an input file
% input.dat and produce an output file result.out 
% The source code is in /examples/Models/IshigamiFunction/ and to compile
% the solver run in the terminal:
%
% gcc ini.c ishigamiFunction.c -lm -o ishigamiFunction
%
% This will generate the executable (external solver).

OpenCossan.reset
Spath = fileparts(which('TutorialIshigamiFunction.m'));
SsolverBinaryPath=fullfile(OpenCossan.getCossanRoot,'examples','Models','IshigamiFunction');
if ispc
    SsolverBinaryFile=fullfile(SsolverBinaryPath,'ishigamiFunction.exe');
else
    SsolverBinaryFile=fullfile(SsolverBinaryPath,'ishigamiFunction');
end

%% Input Definition
% In this example, the external solver computes the value of the Ishigami
% function, a classical example for testing sensitivity analysis algorithms.
% The Ishigami function gets as input three random variables uniformly
% distributed in [-pi,pi] and 2 shape parameters.
Xrv1=RandomVariable('Sdistribution','uniform','lowerbound',-pi,'upperbound',pi);
Xrv2=RandomVariable('Sdistribution','uniform','lowerbound',-pi,'upperbound',pi);
Xrv3=RandomVariable('Sdistribution','uniform','lowerbound',-pi,'upperbound',pi);
Xrvset = RandomVariableSet('Cmembers',{'Xrv1','Xrv2','Xrv3'},'CXrv',{Xrv1,Xrv2,Xrv3});

% Define parameters
parameterA = Parameter('value',7);
parameterB = Parameter('value',0.05);

% Construct Input object
Xinput = Input('CXmembers',{Xrvset,parameterA,parameterB},...
    'CSmembers',{'Xrvset','parameterA','parameterB'});

%% Connector set-up
% The connector is the object that calls an external solver after modifying 
% the input files with sampled data. Additionally, it retrieves the
% quantity of interest from the output files. A connector is then inserted
% as a black-box solver into an Evaluator object.

%% Injector
% The injector is the object used to read the template file for the
% insertion of sampled data. It reads a file with identifiers and create a
% modifiable file connected to cossan input qunatities. Injector is used to
% insert single scalar values. Dedicated injectors subclasses are available
% for specilized requirement like the injection of tables. 
Xinjector = Injector('Sscanfilepath',SsolverBinaryPath,...
    'Sscanfilename','input.dat.cossan',... % file to be scan with the cossan identifiers
    'Sfile','input.dat'); % file created by injector with the injected data
%% Extractor
% The extractor is used to retrieve the quantity of interest from an ASCII
% output file. The user must specify a search string and a relative
% position (row, column) from this string to identify where the quantity of
% interest is located. It is possible to extract a scalar value or to
% specify a repetition number (the nr. of rows specified in Nrepeat are
% read and te extracted values are saved in a vector).
% Other extractors are available for dedicated extraction of data in
% tabular form.
Xresponse = Response('Sname','out',... name to be assigned to the extracted quantity
    'ClookOutFor',{'Result'}, ...
    'Ncol',1,'Nrow',1,'Sformat','%9e');
Xextractor = Extractor('Sfile','result.out','Xresponse',Xresponse);
%% Connector
% The Connector object instructs cossan on the command to be executed to
% call the external solver, the main input file, and contains the
% constructed injectors and extractors.
connector_ishigami = Connector('Sdescription','Connector to test executable ishigami',...
        'Sexecmd','%SsolverBinary %SmainInputFile', ...
        'SmainInputPath',SsolverBinaryPath,...
        'SmainInputFile','input.dat',...
        'SsolverBinary',SsolverBinaryFile,...
        'CXmembers',{Xinjector,Xextractor});

% You can check the connector with the test method
connector_ishigami.test

%% Model definition

% This evaluator executes all the solvers on the local machine
Xevaluator   = Evaluator('CXmembers',{connector_ishigami},'CSnames',{'test_connector'});

% Model is the union of the black-boxes and the uncertain inputs
Xmodel = Model('Xevaluator',Xevaluator,'Xinput',Xinput);

%% Uncertainty Quantification
% Uncertainty propagation with Latin Hypercube sampling. For each sample a
% modified input file is executed in a dedicated folder.
Xmc = LatinHypercubeSampling('Nsamples',25);
Xout = Xmc.apply(Xmodel);

% Plot results
Xout.plotData('Sname','out')

%% MetaModel
Xps1 = PolyharmonicSplines('Sdescription','quadratic spline of Rosenbrock function',...
    'XfullModel',Xmodel,...   %full model
    'Cinputnames',{'Xrv1' 'Xrv2','Xrv3'},... 
    'Coutputnames',{'out'},...  %response to be extracted from full model
    'Stype','cubic',...
    'Sextrapolationtype','quadratic');

Xlhs1= LatinHypercubeSampling('Nsamples',200); % simulation obecjt for calibration samples
Xps1 = Xps1.calibrate('XSimulator',Xlhs1); % calibrate spline

Xlhs2=LatinHypercubeSampling('Nsamples',50); % simulation object for validation samples
Xps1 = Xps1.validate('XSimulator',Xlhs2); % validate spline

% regression plots for calibration and validation
% because of the nature of splines, the regression plot for calibration is
% perfect (the splines always pass from the support points)
f1 = Xps1.plotregression('Stype','calibration','Soutputname','out');

%% Sensitivity
% The sensitivity is carried out using the metamodel in place of the full
% model
%% First order indices
% Compute the first order global sensitivity indices by using 10000 samples
XfirstOrder = GlobalSensitivityRandomBalanceDesign('Nsamples',10000,...
                                                    'Nbootstrap',100,...
                                                    'Xtarget',Xps1);
XFOIndices = XfirstOrder.computeIndices();
f2 = XFOIndices.plot;
%% Total indices
Xss = LatinHypercubeSampling('Nsamples',10000);
Xsobol = GlobalSensitivitySobol('Xsimulator',Xss,...
                                'Nbootstrap',100,...
                                'Xtarget',Xps1);
                            
XtotIndices = Xsobol.computeIndices();
f3 = XtotIndices.plot;
