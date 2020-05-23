%% Tutorial for the Evaluator object
% The evaluator object provides a common interface for the evaluating
% models (Matlab, 3rd party software). It also defines the execution
% strategy and the interface with JobManager. 
%
%
% See Also: Evaluator TutorialModel
%
% $Author: Edoardo Patelli$ 
% COSSAN Working Group
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2020 COSSAN WORKING GROUP

OpenCossan is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License or, (at your option)
any later version.

OpenCossan is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

clear;
close all
clc;

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(56236)

%% Local evaluation of a Matlab model
% In this first simple example, a model model is evaluated on the local machine. 
%
% Define a siple model based on a Matlab function
% Construct a Mio object
Xm=opencossan.workers.MatlabWorker('description', 'Performance function', ...
    'Script','for j=1:length(Tinput), Toutput(j).out1=sqrt(Tinput(j).RV1^2+Tinput(j).RV2^2); end', ...
    'OutputNames',{'out1'},...
    'InputNames',{'RV1' 'RV2'},...
    'Format','structure',...
    'IsFunction',false); % This flag specify if the .m file is a script or a function.
% Construct the Evaluator
Xeval1 = opencossan.workers.Evaluator("Solver",Xm,"SolverName","Xm","Description","fist Evaluator");

% In order to be able to test our Evaluator we need an Input object:
% Define an Input
RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
Xpar1=opencossan.common.inputs.Parameter('value',3);
Xpar2=opencossan.common.inputs.Parameter('value',6);
% Define the RVset
Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'},'members',[RV1; RV2]);
% Define Xinput
Xin = opencossan.common.inputs.Input('description','Input for Tutorial Evaluator');
Xin = add(Xin,'Member',Xrvs1,'name','Xrvs1');
Xin = add(Xin,'member',Xpar1,'name','Xpar1');
Xin = add(Xin,'member',Xpar2,'name','Xpar2');
Xin = sample(Xin,'Nsamples',2);
% TestX evaluetor
Xo1=Xeval1.apply(Xin);
display(Xo1)
Vout=Xo1.getValues('Cnames',Xeval1.OutputNames);


% Validate Solution
Vreference= [1.1261e+00;7.6901e-01];
assert(max(abs(Vout-Vreference))<1e-4,...
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
Xm2=opencossan.workers.MatlabWorker('description', 'Performance function', ...
    'Script','for j=1:length(Tinput), Toutput(j).out2=Tinput(j).out1+3; end', ...
    'OutputNames',{'out2'},...
    'InputNames',{'out1'},...
    'Format','structure',...
    'IsFunction',false); % This flag specify if the .m file is a script or a function.

% Construct a Mio object
Xm3=opencossan.workers.MatlabWorker('description', 'Performance function', ...
    'Script','for j=1:length(Tinput), Toutput(j).out3=Tinput(j).out2+Tinput(j).RV1; end', ...
    'OutputNames',{'out3'},...
    'InputNames',{'out2' 'RV1'},...
    'Format','structure',...
    'IsFunction',false);

XevALL=opencossan.workers.Evaluator('Solver',[Xm Xm2 Xm3],'SolverName',["Xm" "Xm2" "Xm3"]);
XevALL.InputNames
% The provided output are shows in the field Coutputnames
XevALL.OutputNames


%% Deterministic Analysis
%
Xoutdet=XevALL.deterministicAnalysis(Xin);
display(Xoutdet)
Vout=Xoutdet.getValues('Name','out3');

% Validate Solution
Vreference= 3;
assert(abs(Vout-Vreference)<1e-4,...
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
display(XevALL.VerticalSplit)

XinTest(1) = sample(Xin,'Nsamples',1);
XinTest(2) = sample(Xin,'Nsamples',10);
XinTest(3) = sample(Xin,'Nsamples',100);
XinTest(4) = sample(Xin,'Nsamples',1000);

%  create an empty connector
Xc=Connector;
XevALLverticalSplit=Evaluator('CXmembers',{Xm Xm2 Xc Xm3},'LverticalSplit',true);
XevALLhorizontalSplit=Evaluator('CXmembers',{Xm Xm2 Xc Xm3},'LverticalSplit',false);

Vtime=zeros(length(XinTest),2);

% Here we are testing the performance
for n=1:length(XinTest)
    tic, [~]=XevALLverticalSplit.apply(XinTest(n)); Vtime(n,1)=toc;
    tic, [~]=XevALLhorizontalSplit.apply(XinTest(n)); Vtime(n,2)=toc;
end

% Usually the horizontal split is the fasted method. However, some analysis
% required to split the analyisis in vertical blocks. 

