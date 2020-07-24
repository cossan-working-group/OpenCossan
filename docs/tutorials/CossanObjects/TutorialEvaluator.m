%% Tutorial for the Evaluator object
% The evaluator object provides a common interface for the evaluating
% models (Matlab, 3rd party software). It also defines the execution
% strategy and the interface with JobManager. 
%
%
% See Also: http://cossan.co.uk/wiki/index.php/@Evaluator
%
% $Author: Edoardo Patelli$ 
% Copyright~1993-2015, COSSAN Working Group, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(56236)

%% Local evaluation of a Matlab model
% In this first simple example, a model model is evaluated on the local machine. 
%
% Define a siple model based on a Matlab function
% Construct a Mio object
mio = opencossan.workers.Mio('description', 'Performance function', ...
    'Script','for j=1:length(Tinput), Toutput(j).out1=sqrt(Tinput(j).RV1^2+Tinput(j).RV2^2); end', ...
    'OutputNames',{'out1'},...
    'InputNames',{'RV1' 'RV2'},...
    'Format','structure',...
    'IsFunction',false); % This flag specify if the .m file is a script or a function.
% Construct the Evaluator
evaluator = opencossan.workers.Evaluator('Xmio',mio,'Sdescription','fist Evaluator');

% In order to be able to test our Evaluator we need an Input object:
% Define an Input
rv1 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
rv2 = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
par1 = opencossan.common.inputs.Parameter('value',3);
par2 = opencossan.common.inputs.Parameter('value',6);

% Define the RVset
rvset = opencossan.common.inputs.random.RandomVariableSet('names',["RV1", "RV2"],'members',[rv1; rv2]);
% Define Input
input = opencossan.common.inputs.Input();
input = add(input,'Member',rvset,'name','Xrvs1');
input = add(input,'member',par1,'name','Xpar1');
input = add(input,'member',par2,'name','Xpar2');
samples = sample(input,'samples',2);
% TestX evaluetor
out = evaluator.apply(samples);
disp(out1.Samples);

% Validate Solution
Vreference= [1.1261e+00;7.6901e-01];
assert(max(abs(out.Samples.out1-Vreference))<1e-4,...
    'CossanX:Tutorials:TutorialEvaluator','Reference Solution does not match.')

%% Second example with multiple model evaluated sequentially. 
% The evaluator can contain more the one Mio or Connectors and the output of a
% Mio/Connector can be used as input for the next Mio/Connector/SolutionSequence
% object. Hence the order of the objects defined in the Evaluator is important. 
% The input factors required to evaluate the object are shown in the field
% Cinputname. Please note that out1 and out2 are that are required to evaluate
% Xm2 and Xm3, respectively are not shown in this field because they are
% factors computed internally to the evaluator object.

% Construct a Mio object
mio2 = opencossan.workers.Mio('description', 'Performance function', ...
    'FunctionHandle', @(x) x + 3, ...
    'OutputNames',{'out2'}, ...
    'InputNames',{'out1'}, ...
    'Format','matrix', ...
    'IsFunction', true); % This flag specify if the .m file is a script or a function.

% Construct a Mio object
mio3 = opencossan.workers.Mio('description', 'Performance function', ...
    'FunctionHandle', @(x) x(:, 1) + x(:, 2), ...
    'OutputNames',{'out3'}, ...
    'InputNames',{'out2' 'RV1'}, ...
    'Format','matrix', ...
    'IsFunction', true);

evalWithMultipleMios = opencossan.workers.Evaluator('CXmembers',{mio mio2 mio3});

%% Deterministic Analysis
%
outDeterministic = evalWithMultipleMios.deterministicAnalysis(input);
disp(outDeterministic.Samples);

% Validate Solution
assert(outDeterministic.Samples.out3 == 3,...
    'CossanX:Tutorials:TutorialEvaluator','Reference Solution does not match.')

%% Execution strategies
% There are 2 different strategies to evaluate the models: 
% * HorizontalSplit and VerticalSplit
% These two techniques can be selected by the flag LverticalSplit 
%
% In the horizontal split, all the simulations are split in batches and
% each workers evaluate all the batches before passing the analysis to the
% next worker. 
% In the vertical split, each job evaluate all the workers sequentially for 1 or more samples
% The execution of the models is done in vertical chunks (i.e. all the
% models are exetuted before processing the next samples). 

% The default option is HorizontalSplit
display(evalWithMultipleMios.LverticalSplit)

samples = {};
samples{1} = sample(input,'samples',1);
samples{2} = sample(input,'samples',10);
samples{3} = sample(input,'samples',100);
samples{4} = sample(input,'samples',1000);

verticalSplit = opencossan.workers.Evaluator('CXmembers',{mio mio2 mio3},'LverticalSplit',true);
horizontalSplit = opencossan.workers.Evaluator('CXmembers',{mio mio2 mio3},'LverticalSplit',false);

time = zeros(length(samples), 2);

% Here we are testing the performance
for n=1:length(samples)
    tic; verticalSplit.apply(samples{n}); time(n, 1) = toc;
    tic; horizontalSplit.apply(samples{n}); time(n, 2) = toc;
end

disp(time);

% Usually the horizontal split is the fasted method. However, some analysis
% required to split the analyisis in vertical blocks. 

