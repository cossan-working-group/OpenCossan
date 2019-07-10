%% Tutorial for the DesignOfExperiments class
%
% DesignOfExperiments tutorial
% Please refer to the specific tutorials for the other objects available in
% [COSSANEngine/examples/Tutorials]
%
% See Also: http://cossan.co.uk/wiki/index.php/@DesignOfExperiment
%
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 

%% Example #1 - using only RandomVariables in Input

% Define RandomVariablesSet
RV1   = RandomVariable('Sdistribution','normal', 'mean',5, 'std',1); 
RV2   = RandomVariable('Sdistribution','normal', 'mean',15,'std',2); 
RV3   = RandomVariable('Sdistribution','normal', 'mean',1,'std',0.2);
Xrvs1 = RandomVariableSet('Cmembers',{'RV1','RV2','RV3'},'CXmembers',{RV1,RV2,RV3});
% Create an Input object
Xin = Input('Sdescription','Input Object of our model');
Xin = Xin.add('Xmember',Xrvs1,'Sname','Xrvs1');
%% BOX-BEHNKEN

% here we use the Box-Behnken type of DOE in order to generate the samples
Xdoe = DesignOfExperiments('SdesignType','BoxBehnken');

% if you provide also the Xdoe as output, the MdoeFactors will be stored in
% the object (this object is created in sample method, since it requires 
% the Xinput, i.e. you need to know the no Nrv +Ndv)
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin); %#ok<*NASGU>

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MsamplesPhysicalSpace);

% validate the results: second row of samples is selected for this purpose
Vreference=[4.00 17.00 1.00];
assert(max(abs(Xsmp.MsamplesPhysicalSpace(2,:)-Vreference))<1e-6,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#1) Reference Solution does not match.')

% change the perturbance parameter and observe the changes in the samples
% now the samples are perturbed +-2 std dev
Xdoe = DesignOfExperiments('SdesignType','BoxBehnken','perturbanceparameter',2);

% generate the samples
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin); 

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MsamplesPhysicalSpace);

% validate the results: fifth row of samples is selected for this purpose
Vreference=[3.0000   15.0000    0.6000];
assert(max(abs(Xsmp.MsamplesPhysicalSpace(5,:)-Vreference))<1e-6,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#1) Reference Solution does not match.')

%% 2LEVEL-FACTORIAL

% using the 2LEVEL-FACTORIAL type of DOE in order to generate the samples
Xdoe = DesignOfExperiments('SdesignType','2LevelFactorial');

% generate the samples according to the provided input
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin);

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MsamplesPhysicalSpace);

% validate the results: last row of samples is selected for this purpose
Vreference=[6.0000   17.0000    1.2000];
assert(max(abs(Xsmp.MsamplesPhysicalSpace(8,:)-Vreference))<1e-6,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','2LEVEL-FACTORIAL (ex#1) Reference Solution does not match.')

%% FULL-FACTORIAL

% using the full factorial DOE 
Xdoe = DesignOfExperiments('SdesignType','FullFactorial');

% generate the samples accordingly
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin);

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MsamplesPhysicalSpace);

% validate the results: last row of samples is selected for this purpose
Vreference=[6.0000   17.0000    1.0000];
assert(max(abs(Xsmp.MsamplesPhysicalSpace(9,:)-Vreference))<1e-6,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','2LEVEL-FACTORIAL (ex#1) Reference Solution does not match.')

%% Central-Composite with Faced

% using the Central-Composite DOE with "Faced" option
Xdoe = DesignOfExperiments('SdesignType','CentralComposite','ScentralCompositeType','faced');

% generate the samples accordingly
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin);

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MsamplesPhysicalSpace);

% validate the results: 
Vreference=[4.0000   15.0000    1.0000];
assert(max(abs(Xsmp.MsamplesPhysicalSpace(9,:)-Vreference))<1e-6,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','Central-Composite with Faced (ex#1) Reference Solution does not match.')

%% Central-Composite with inscribed

Xdoe = DesignOfExperiments('SdesignType','CentralComposite','ScentralCompositeType','inscribed');

% generate the samples accordingly
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin);

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MsamplesPhysicalSpace);

% validate the results: 
Vreference=[4.4054   13.8108    0.8811];
assert(max(abs(Xsmp.MsamplesPhysicalSpace(1,:)-Vreference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','Central-Composite with inscribed (ex#1) Reference Solution does not match.')

%% Example #2 - using only DesignVariables (continous & discrete) in Input

Xin2 = Input('Sdescription','Input Object of our model');

DV1 = DesignVariable('value',3,'Vsupport',1:2:9);
DV2 = DesignVariable('value',17,'lowerbound',10,'upperbound',20);
DV3 = DesignVariable('value',42,'lowerbound',40,'upperbound',60);
Xin2 = Xin2.add('Xmember',DV1,'Sname','DV1');
Xin2 = Xin2.add('Xmember',DV2,'Sname','DV2');
Xin2 = Xin2.add('Xmember',DV3,'Sname','DV3');

%% BOX-BEHNKEN

Xdoe = DesignOfExperiments('SdesignType','BoxBehnken','Lusecurrentvalues',false);

% generate the samples accordingly
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin2); %#ok<*NASGU>

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MdoeDesignVariables);

% validate the results: 
Vreference=[ 9    10    50];
assert(max(abs(Xsmp.MdoeDesignVariables(3,:)-Vreference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#2) reference Solution does not match.')

%%  2LEVEL-FACTORIAL

Xdoe = DesignOfExperiments('SdesignType','2LevelFactorial');

% generate the samples accordingly
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin2);

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MdoeDesignVariables);

% validate the results: 
Vreference=[3    17    42];
assert(max(abs(Xsmp.MdoeDesignVariables(1,:)-Vreference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','2LEVEL-FACTORIAL (ex#2) reference Solution does not match.')

%%  FULL-FACTORIAL

Xdoe = DesignOfExperiments('SdesignType','FullFactorial','Vlevelvalues',[2 3],'Clevelnames',{'DV2','DV3'});

% generate the samples accordingly
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin2);

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MdoeDesignVariables);

% validate the results: 
Vreference=[3    10    40];
assert(max(abs(Xsmp.MdoeDesignVariables(2,:)-Vreference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','FULL-FACTORIAL (ex#2) reference Solution does not match.')

%% Central-Composite with Faced

Xdoe = DesignOfExperiments('SdesignType','CentralComposite','ScentralCompositeType','faced');

% generate the samples accordingly
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin2);

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MdoeDesignVariables);

% validate the results: 
Vreference=[3    17    42];
assert(max(abs(Xsmp.MdoeDesignVariables(end,:)-Vreference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','Central-Composite with Faced (ex#2) reference Solution does not match.')

%% Central-Composite with inscribed

Xdoe = DesignOfExperiments('SdesignType','CentralComposite','ScentralCompositeType','inscribed');

% generate the samples accordingly
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin2);

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MdoeDesignVariables);

% validate the results: 
Vreference=[3.0000   12.0270   44.0540];
assert(max(abs(Xsmp.MdoeDesignVariables(1,:)-Vreference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','Central-Composite with inscribed (ex#2) reference Solution does not match.')

%% User defined 

Xdoe = DesignOfExperiments('SdesignType','UserDefined','MdoeFactors',[0 0.5 1; -1 -1 -0.5]);

% generate the samples accordingly
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin2);

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MdoeDesignVariables);

% validate the results: 
Vreference=[3.0000   17.5000   60.0000];
assert(max(abs(Xsmp.MdoeDesignVariables(1,:)-Vreference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','User defined (ex#2) reference Solution does not match.')

%% Example #3 - using both DesignVariables & RandomVariables in Input

Xin3 = Input('Sdescription','Input Object of our model');

% Define RandomVariablesSet
RV1   = RandomVariable('Sdistribution','normal', 'mean',5, 'std',1); %#ok<SNASGU>
RV2   = RandomVariable('Sdistribution','normal', 'mean',15,'std',2); 
Xrvs1 = RandomVariableSet('Cmembers',{'RV1', 'RV2'});
Xin3 = Xin3.add('Xmember',Xrvs1,'Sname','Xrvs1');

% Define the DesignVariables
DV1 = DesignVariable('value',2,'minvalue',1,'maxvalue',6);
DV2 = DesignVariable('value',3,'Vsupport',1:2:9);
Xin3 = Xin3.add('Xmember',DV1,'Sname','DV1');
Xin3 = Xin3.add('Xmember',DV2,'Sname','DV2');

%% Define the Model

Xm=Mio('Sdescription', 'This is our Model', ...
    'Sscript','for j=1:length(Tinput),Toutput(j).out=2*Tinput(j).RV1-Tinput(j).RV2+3*Tinput(j).DV1+3*Tinput(j).DV2; end', ...
    'Liostructure',true,...
    'Coutputnames',{'out'},...
    'Cinputnames',{'RV1','RV2','DV1','DV2'},...
    'Lfunction',false); 
% Construct the Evaluator
Xeval = Evaluator('Xmio',Xm,'Sdescription','Evaluator for the DOE tutorial');
Xmdl  = Model('Xevaluator',Xeval,'Xinput',Xin3);

%% BOX-BEHNKEN

Xdoe = DesignOfExperiments('SdesignType','BoxBehnken');

% generate the samples accordingly
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin3); %#ok<*NASGU>

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MdoeDesignVariables);   % samples of DVs
display(Xsmp.MsamplesPhysicalSpace); % samples of RVs

% validate the results: 
Vreference=[2 3];
assert(max(abs(Xsmp.MdoeDesignVariables(1,:)-Vreference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#3) reference Solution does not match.')

% validate the results: 
Vreference=[4 13];
assert(max(abs(Xsmp.MsamplesPhysicalSpace(1,:)-Vreference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#3) reference Solution does not match.')

%%  2LEVEL-FACTORIAL

Xdoe = DesignOfExperiments('SdesignType','2LevelFactorial');

% generate the samples accordingly
[Xsmp Xdoe] = Xdoe.sample('Xinput',Xin3);

% display the coordinates of the DOE and the generated samples
display(Xdoe.MdoeFactors);
display(Xsmp.MdoeDesignVariables);   % samples of DVs
display(Xsmp.MsamplesPhysicalSpace); % samples of RVs

% validate the results: 
Vreference=[6 9];
assert(max(abs(Xsmp.MdoeDesignVariables(end,:)-Vreference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#3) reference Solution does not match.')

% validate the results: 
Vreference=[5 15];
assert(max(abs(Xsmp.MsamplesPhysicalSpace(1,:)-Vreference))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#3) reference Solution does not match.')

%% Use apply method

Xo = Xdoe.apply(Xmdl);

% validate the results: 
Vreference=[28 22 40 8];
assert(max(abs(Xo.Tvalues(2).out-Vreference(1)))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#3) reference Solution does not match.')

assert(max(abs(Xo.Tvalues(5).out-Vreference(4)))<1e-4,...
   'CossanX:Tutorials:TutorialDesignOfExperiments','BOX-BEHNKEN (ex#3) reference Solution does not match.')

