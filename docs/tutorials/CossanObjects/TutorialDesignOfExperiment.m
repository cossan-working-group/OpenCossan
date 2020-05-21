%% Tutorial for the DesignOfExperiments class
%
% DesignOfExperiments tutorial
% Please refer to the specific tutorials for the other objects available in
% [COSSANEngine/examples/Tutorials]
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@DesignOfExperiment
%
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 
%% Example #1 - using only RandomVariables in Input

%% Define inputs
rv1   = opencossan.common.inputs.random.NormalRandomVariable('mean',5, 'std',1); 
rv2   = opencossan.common.inputs.random.NormalRandomVariable('mean',15,'std',2); 
rv3   = opencossan.common.inputs.random.NormalRandomVariable('mean',1,'std',0.2);

input = opencossan.common.inputs.Input('members', {rv1 rv2 rv3}, 'names', ["rv1" "rv2" "rv3"]);


%% BOX-BEHNKEN
% here we use the Box-Behnken type of DOE in order to generate the samples
doe = opencossan.simulations.DesignOfExperiments('DesignType','BoxBehnken');

% if you provide also the Xdoe as output, the MdoeFactors will be stored in
% the object (this object is created in sample method, since it requires 
% the Xinput, i.e. you need to know the no Nrv +Ndv)
[samples, doe] = doe.sample('input',input); %#ok<*NASGU>

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: second row of samples is selected for this purpose
reference = [4 17 1];
assert(max(abs(samples{2,:} - reference)) < 1e-6,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#1) Reference Solution does not match.')

% change the perturbance parameter and observe the changes in the samples
% now the samples are perturbed +-2 std dev
doe = opencossan.simulations.DesignOfExperiments('DesignType','BoxBehnken', 'Perturbance', 2);

% generate the samples
[samples, doe] = doe.sample('input', input); 

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: fifth row of samples is selected for this purpose
reference = [3 15 0.6];
assert(max(abs(samples{5,:} - reference))<1e-6,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#1) Reference Solution does not match.')

%% 2LEVEL-FACTORIAL

% using the 2LEVEL-FACTORIAL type of DOE in order to generate the samples
doe = opencossan.simulations.DesignOfExperiments('DesignType','2LevelFactorial');

% generate the samples according to the provided input
[samples, doe] = doe.sample('input',input);

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: last row of samples is selected for this purpose
reference = [6 17 1.2];
assert(max(abs(samples{8,:}-reference))<1e-6,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','2LEVEL-FACTORIAL (ex#1) Reference Solution does not match.')

%% FULL-FACTORIAL

% using the full factorial DOE 
doe = opencossan.simulations.DesignOfExperiments('DesignType','FullFactorial');

% generate the samples accordingly
[samples, doe] = doe.sample('input',input);

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: last row of samples is selected for this purpose
reference=[6 17 1];
assert(max(abs(samples{9,:}-reference))<1e-6,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','2LEVEL-FACTORIAL (ex#1) Reference Solution does not match.')

%% Central-Composite with Faced

% using the Central-Composite DOE with "Faced" option
doe = opencossan.simulations.DesignOfExperiments('DesignType','CentralComposite','CentralCompositeType','faced');

% generate the samples accordingly
[samples, doe] = doe.sample('input',input);

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: 
reference=[4 15 1];
assert(max(abs(samples{9,:}-reference))<1e-6,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','Central-Composite with Faced (ex#1) Reference Solution does not match.')

%% Central-Composite with inscribed

doe = opencossan.simulations.DesignOfExperiments('DesignType','CentralComposite','CentralCompositeType','inscribed');

% generate the samples accordingly
[samples, doe] = doe.sample('input',input);

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: 
reference=[4.4054 13.8108 0.8811];
assert(max(abs(samples{1,:}-reference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','Central-Composite with inscribed (ex#1) Reference Solution does not match.')

%% Example #2 - using only DesignVariables (continous & discrete) in Input

dv1 = opencossan.optimization.DiscreteDesignVariable('value',3,'support',1:2:9);
dv2 = opencossan.optimization.ContinuousDesignVariable('value',17,'lowerbound',10,'upperbound',20);
dv3 = opencossan.optimization.ContinuousDesignVariable('value',42,'lowerbound',40,'upperbound',60);

Xin2 = opencossan.common.inputs.Input('members', {dv1 dv2 dv3}, 'names', ["dv1" "dv2" "dv3"]);

%% BOX-BEHNKEN

doe = opencossan.simulations.DesignOfExperiments('DesignType','BoxBehnken', 'usecurrentvalues', false);

% generate the samples accordingly
[samples, doe] = doe.sample('input',Xin2); %#ok<*NASGU>

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: 
reference=[9 10 50];
assert(max(abs(samples{3,:} - reference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#2) reference Solution does not match.')

%%  2LEVEL-FACTORIAL

doe = opencossan.simulations.DesignOfExperiments('DesignType','2LevelFactorial');

% generate the samples accordingly
[samples, doe] = doe.sample('input',Xin2);

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: 
reference=[3 17 42];
assert(max(abs(samples{1,:}-reference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','2LEVEL-FACTORIAL (ex#2) reference Solution does not match.')

%%  FULL-FACTORIAL

doe = opencossan.simulations.DesignOfExperiments('DesignType','FullFactorial','LevelValues',[2 3]);

% generate the samples accordingly
[samples, doe] = doe.sample('input',Xin2);

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: 
reference=[3 10 40];
assert(max(abs(samples{2,:}-reference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','FULL-FACTORIAL (ex#2) reference Solution does not match.')

%% Central-Composite with Faced

doe = opencossan.simulations.DesignOfExperiments('DesignType','CentralComposite','CentralCompositeType','faced');

% generate the samples accordingly
[samples, doe] = doe.sample('input',Xin2);

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: 
reference=[3 17 42];
assert(max(abs(samples{end,:}-reference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','Central-Composite with Faced (ex#2) reference Solution does not match.')

%% Central-Composite with inscribed

doe = opencossan.simulations.DesignOfExperiments('DesignType','CentralComposite','CentralCompositeType','inscribed');

% generate the samples accordingly
[samples, doe] = doe.sample('input',Xin2);

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: 
reference=[3 12.0270 44.0540];
assert(max(abs(samples{1,:} - reference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','Central-Composite with inscribed (ex#2) reference Solution does not match.')

%% User defined 

doe = opencossan.simulations.DesignOfExperiments('DesignType','UserDefined','Factors',[0 0.5 1; -1 -1 -0.5]);

% generate the samples accordingly
[samples, doe] = doe.sample('input',Xin2);

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: 
reference=[3.0000 17.5000 60.0000];
assert(max(abs(samples{1,:}-reference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','User defined (ex#2) reference Solution does not match.')

%% Example #3 - using both DesignVariables & RandomVariables in Input
% Define RandomVariablesSet
rv1   = opencossan.common.inputs.random.NormalRandomVariable('mean',5, 'std',1);
rv2   = opencossan.common.inputs.random.NormalRandomVariable('mean',15,'std',2); 

% Define the DesignVariables
dv1 = opencossan.optimization.ContinuousDesignVariable('value',2,'lowerbound',1,'upperbound',6);
dv2 = opencossan.optimization.DiscreteDesignVariable('value',3,'support',1:2:9);

Xin3 = opencossan.common.inputs.Input('members', {rv1 rv2 dv1 dv2}, 'names', ["rv1" "rv2" "dv1" "dv2"]);

%% Define the Model

Xm = opencossan.workers.Mio('Description', 'This is our Model', ...
    'Script','for j=1:length(Tinput),Toutput(j).out=2*Tinput(j).rv1-Tinput(j).rv2+3*Tinput(j).dv1+3*Tinput(j).dv2; end', ...
    'format','structure',...
    'OutputNames',{'out'},...
    'InputNames',{'rv1','rv2','dv1','dv2'}); 

% Construct the Evaluator
Xeval = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','Evaluator for the DOE tutorial');
Xmdl  = opencossan.common.Model('evaluator',Xeval,'input',Xin3);

%% BOX-BEHNKEN

doe = opencossan.simulations.DesignOfExperiments('DesignType','BoxBehnken');

% generate the samples accordingly
[samples, doe] = doe.sample('input',Xin3); %#ok<*NASGU>

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: 
reference=[4 13 2 3];
assert(max(abs(samples{1,:}-reference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#3) reference Solution does not match.')

%%  2LEVEL-FACTORIAL

doe = opencossan.simulations.DesignOfExperiments('DesignType','2LevelFactorial');

% generate the samples accordingly
[samples,doe] = doe.sample('input', Xin3);

% display the coordinates of the DOE and the generated samples
display(doe.Factors);
display(samples);

% validate the results: 
reference=[6 17 6 9];
assert(max(abs(samples{end,:}-reference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#3) reference Solution does not match.')

%% Use apply method

Xo = doe.apply(Xmdl);

% validate the results: 
reference=[28 22 40 8];
assert(max(abs(Xo.Samples.out(2)-reference(1)))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#3) reference Solution does not match.')

assert(max(abs(Xo.Samples.out(5)-reference(4)))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#3) reference Solution does not match.')

