%% Tutorial for the Constraint object
% The Constrains object defines the constains for the
% optimization problem. It is a subclass of the Mio object and inherits all
% the methods from that class. 
% Please refer to the Mio tutorial and Optimization tutorial  for more
% examples of the constraints
%
% See Also:  http://cossan.co.uk/wiki/index.php/@Constraint
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author:~Edoardo~Patelli$ 

clear;
close all
clc;
%% Define a Constraint object 
% The fieds Linequality is used to define the type of constaint (equality
% or inequality constraint)

Xcon   = opencossan.optimization.Constraint('Description','non linear inequality constraint', ...
    'Script','for n=1:length(Tinput),Toutput(n).Con1=2-Tinput(n).X1-Tinput(n).X2;end',...
    'Outputnames',{'Con1'},'Inputnames',{'X1','X2'},'Linequality',true);
% Show details of the Constraints
display(Xcon)


%% Test a Constraint object   
% a structure of inputs values is required to evaluate the Constraint object
Tinput.X1=4;
Tinput.X2=3;

Xout=Xcon.run(Tinput);

display(Xout);

%% Use a Constraint object in a Optimization Problem
% Create input 
X1      = DesignVariable('Sdescription','design variable 1','value',7);
X2      = DesignVariable('Sdescription','design variable 2','value',2);
Xinput  = Input('CXmembers',{X1 X2},'CSobjectNames',{'X1' 'X2'})

% Define an  ObjectiveFunction
Xofun   = ObjectiveFunction('Sdescription','objective function', ...
          'Cinputnames',{'X1','X2'},... % Define the inputs 
          'Sscript','for n=1:length(Tinput),Toutput(n).fobj=Tinput(n).X1;end',...
          'Coutputnames',{'fobj'}); % Define the outputs
      
% Define an Optimization Problem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'Xinput',Xin,'XobjectiveFunction',Xofun,'Xconstraint',Xcon);
% Show the optimization problem
% The object contains 1 Objective Function and 1 Constraint 
display(Xop)

% It is necessary to initialize a Optimum object before evaluating
% Contraints and Objective function
Xoptimum=initializeOptimum(Xop);

% Evaluate the objective fuction at 2 points: 5 4 and 2 1.
Vo=Xcon.evaluate('Xoptimum',Xoptimum,'XoptimizationProblem',Xop,'MreferencePoints',[5 4; 2 1]);

% Vo contains the values of the Constraint (-7 and -1)
sprintf('Constraint values: [%f %f]',Vo(1),Vo(2))

% New evaluation 
[Vo, ~, Mgrad]=Xcon.evaluate('Xoptimum',Xoptimum,'XoptimizationProblem',Xop,...
                'MreferencePoints',[5 4],'Lgradient',true);
sprintf('Constraint values: [%f]',Vo(1))

% Return also the gradient
[Vin,Veq,VinGrad,VeqGrad]=Xcon.evaluate('XoptimizationProblem',Xop,'MreferencePoints',[5 4],'Lgradient',true);

display(VinGrad)

% Validate Solution
VinR=-7;
VinGradR=[-1 ; -1];

assert(max(abs(Vin-VinR))<1e-6,'CossanX:Tutorials:TutorialConstraint', ...
    'Reference Solution Inequality constraint does not match.')
assert(isempty(Veq),'CossanX:Tutorials:TutorialConstraint',...
    'Reference Solution Equality constraintdoes not match.')
assert(max(max(abs(VinGrad-VinGradR)))<1e-6,'CossanX:Tutorials:TutorialConstraint',...
    'Reference Solution Inequality constraint Gradient does not match.')
assert(isempty(VeqGrad),'CossanX:Tutorials:TutorialConstraint',...
    'Reference Solution Equality constraint Gradient does not match.')

%% More constrains can be defined using the multiple Constraints object.
Xcon   = Constraint('Sdescription','2 non linear inequality constraints and 1 equality constain', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).Con1=2-Tinput(n).X1-Tinput(n).X2;end',...
    'Coutputnames',{'Con1'},'Cinputnames',{'X1','X2'},'Linequality',true);

Xcon(2)   = Constraint('Sdescription','2 non linear inequality constraints and 1 equality constain', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).Con2=Tinput(n).X1;end',...
    'Coutputnames',{'Con2'},'Cinputnames',{'X1','X2'},'Linequality',true);

Xcon(3)   = Constraint('Sdescription','2 non linear inequality constraints and 1 equality constain', ...
    'Sscript','for n=1:length(Tinput);Toutput(n).Con3=Tinput(n).X2;end',...
    'Coutputnames',{'Con3'},'Cinputnames',{'X1','X2'},'Linequality',false);

% Define a new OptimizationProblem with three Constraint objects 
Xop3     = OptimizationProblem('Sdescription','Optimization problem', ...
    'Xinput',Xin,'XobjectiveFunction',Xofun,'Xconstraint',Xcon);
display(Xop3)


