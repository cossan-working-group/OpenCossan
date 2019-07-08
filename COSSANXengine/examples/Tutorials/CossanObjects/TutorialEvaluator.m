%% Tutorial for the Evaluator object
% The evaluator object provides a common interface for the Model object to
% the user defined solvers or model (i.e. a FE solver or a Matlab
% script/function).
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Evaluator
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(56236)

%% Define a user define model based on a Matlab function

% Construct a Mio object
Xm=Mio('Sdescription', 'Performance function', ...
    'Sscript','for j=1:length(Tinput), Toutput(j).out1=sqrt(Tinput(j).RV1^2+Tinput(j).RV2^2); end', ...
    'Coutputnames',{'out1'},...
    'Cinputnames',{'RV1' 'RV2'},...
    'Liostructure',true,...
    'Lfunction',false); % This flag specify if the .m file is a script or a function.


%% Construct the Evaluator
% Construct evaluator using only Mio object

Xeval1 = Evaluator('Xmio',Xm,'Sdescription','fist Evaluator');

% In order to be able to test our Evaluator we need an Input object:

%% Define an Input
% Define RVs
RV1=RandomVariable('Sdistribution','normal', 'mean',0,'std',1);
RV2=RandomVariable('Sdistribution','normal', 'mean',0,'std',1);
Xpar1=Parameter('value',3);
Xpar2=Parameter('value',6);
% Define the RVset
Xrvs1=RandomVariableSet('Cmembers',{'RV1', 'RV2'});
% Define Xinput
Xin = Input('Sdescription','Input for Tutorial Evaluator');
Xin = Xin.add('Xmember',Xrvs1,'Sname','Xrvs1');
Xin = Xin.add('Xmember',Xpar1,'Sname','Xpar1');
Xin = Xin.add('Xmember',Xpar2,'Sname','Xpar2');
Xin = sample(Xin,'Nsamples',2);

%% TestX evaluetor
Xo1=Xeval1.apply(Xin);
display(Xo1)
Vout=Xo1.getValues('Cnames',Xeval1.Coutputnames);


% Validate Solution
Vreference= [1.1261e+00;7.6901e-01];
assert(max(abs(Vout-Vreference))<1e-4,...
    'CossanX:Tutorials:TutorialEvaluator','Reference Solution does not match.')

%% Second example
% The evaluator can contain more the one Mio or Connectors and the output of a
% Mio/Connector can be used as input for the next Mio/Connector/SolutionSequence
% object. Hence the order of the objects defined in the Evaluator is important. 
% Please refer to the Tutorial of the JobManager



% Construct a Mio object
Xm2=Mio('Sdescription', 'Performance function', ...
    'Sscript','for j=1:length(Tinput), Toutput(j).out2=Tinput(j).out1+3; end', ...
    'Coutputnames',{'out2'},...
    'Cinputnames',{'out1'},...
    'Liostructure',true,...
    'Lfunction',false); % This flag specify if the .m file is a script or a function.

% Construct a Mio object
Xm3=Mio('Sdescription', 'Performance function', ...
    'Sscript','for j=1:length(Tinput), Toutput(j).out3=Tinput(j).out2+Tinput(j).RV1; end', ...
    'Coutputnames',{'out3'},...
    'Cinputnames',{'out2' 'RV1'},...
    'Liostructure',true,...
    'Lfunction',false);

XevALL=Evaluator('CXmembers',{Xm Xm2 Xm3});

% The input factors required to evaluate the object are shown in the field
% Cinputname. Please note that out1 and out2 are that are required to evaluate
% Xm2 and Xm3, respectively are not shown in this field because they are
% factors computed internally to the evaluator object.
XevALL.Cinputnames
% The provided output are shows in the field Coutputnames
XevALL.Coutputnames

Xout=XevALL.apply(Xin);
display(Xout)
%% Deterministic Analysis
%
Xoutdet=XevALL.deterministicAnalysis(Xin);
display(Xoutdet)
Vout=Xoutdet.getValues('Sname','out3');

% Validate Solution
Vreference= 3;
assert(abs(Vout-Vreference)<1e-4,...
    'CossanX:Tutorials:TutorialEvaluator','Reference Solution does not match.')

