%% TutorialCantileverBeam: Optimization
% Perform optimization on the cantilever beam
% (<TutorialCantileverBeamMatlab.html>) using a MATLAB evaluator.
%
% <<cantilever-beam.png>>
%
% See Also http://cossan.co.uk/wiki/index.php/Cantilever_Beam
%
% Author: *Edoardo Patelli*, Institute for Risk and Uncertainty, University
% of Liverpool, UK

%% LICENSE
%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2018 COSSAN WORKING GROUP

OpenCossan is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License or,
(at your option) any later version.
	
OpenCossan is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

%% Setup
% Set the verbosity level to 2 in order to silence evaluator output
% messages.
OpenCossan.setVerbosityLevel(2);

%% Definition of the Input: Design Variables
% In this tutorial the Random Variables are replaced by two Design
% Variables. The optimization analysis requires the definition of Design
% Variables, i.e. the variables that define new configurations.

b = DesignVariable('value',0.12,'lowerBound',0.01,'upperBound',0.50,'Sdescription','Beam Width');
h = DesignVariable('value',0.54,'lowerBound',0.02,'upperBound',1,'Sdescription','Beam Heigth');

%% Definition of the Input: Parameters
% In this example we do not use |RandomVariables| but only |Parameters|.
L = Parameter('value',1.8,'Sdescription','Beam Length');
maxDisplacement = Parameter('value',0.001,'Sdescription','Maximum allowed Displacement');
P = Parameter('value',10000,'Sdescription','Load');
rho = Parameter('value',600,'Sdescription','Density');
E = Parameter('value',10e9,'Sdescription','Young''s modulus');

%% Definition of the Input: Function
% Construct the |Function| object that defines the moment of inertia as
%
% $$I = \frac{bh^3}{12}$$

I = Function('Sdescription','Moment of Inertia','Sexpression','<&b&>.*<&h&>.^3/12');

%% Definition of the Input: Input
% Construct the |Input| object grouping the input objects together.
XinputOptimization=Input('CXmembers',{L b P h rho E I maxDisplacement},...
    'CSmembers',{'L' 'b' 'P' 'h' 'rho' 'E' 'I' 'MaxW'});
% The summary show that Xinput contains all the previously created
% objects:
display(XinputOptimization);

%% Definition of the Evaluator
% Construct the |Evaluator| object by passing an |Mio| (MATLAB-Input-Output) object.
% The |Mio| is used to calculate the displacement
%
% $$w = \frac{pgbhL^4}{8EI} + \frac{PL^3}{3EI}$$,
%
% using the previously defined objects.
Sfolder=fileparts(mfilename('fullpath'));% returns the current folder
Xmio=Mio('Spath',fullfile(Sfolder,'MatlabModel'),'Sfile','tipDisplacement.m',...
    'Cinputnames',{'I' 'b' 'L' 'h' 'rho' 'P'},'Liostructure',true, ...
    'Coutputnames',{'w'});

% Create the Evaluator using the Mio
Xevaluator=Evaluator('CXmembers',{Xmio},'CSmembers',{'Xmio'});

%% Definition of the Physical Model
% Construct the |Model| by passing the |Input| and the |Evaluator|
Xmodel=Model('Xinput',XinputOptimization,'Xevaluator',Xevaluator);

%% Design of Experiments Analysis
% The |DesignOfExperiment| analysis can be used to see if a feasible
% solution is present in the bounds set for the Design Variables.
%
% Define a user DOE object. We evaluate the model at the lower and upper
% bounds of the design variable plus at the current values. Therefore, for
% each design variable we have 3 values and a total of 9 model evaluations
% are required.
%
% The evaluation points are defined by means of the MdoeFactor matrix
% defined between -1 and 1.
MdoeFactors=[-1 -1;
    0 -1;
    1 -1;
    -1  0;
    0  0;
    1  0;
    -1  1;
    0  1;
    1  1];
% When the flag Lusecurrentvalues is set to true the current values of the design
% variables is used in corresponcence of the MdoeFactors=0.

Xdoe = DesignOfExperiments('Sdesigntype','UserDefined',...
    'Mdoefactors',MdoeFactors,'Lusecurrentvalues',true);

% Show summary of the design of experimemts
display(Xdoe)

% Evaluate the model at the points defined by the DesignOfExperiment
XoutDoe = Xdoe.apply(Xmodel);

%% Results of the Design of Experiments
h = XoutDoe.getValues('Sname','h');
b = XoutDoe.getValues('Sname','b');
w = XoutDoe.getValues('Sname','w');
Status = cell(9,1);

for n = 1:numel(w)
    if (w(n) < maxDisplacement.value)
        Status{n} = 'Feasible';
    else
        Status{n} = 'Infeasible';
    end
end

results = table(h,b,w,Status);
format shorte;
display(results);
format short;
% There are 3 feasible solutions and this means the the opimization problem
% is well defined. Now we have to identify the optimal solution.

%% Definition of the Objective Function
% The goal of this optimization is to minimaze the weight of the beam. The
% weight can be easely computed using a matlab script (MIO).
Xobjfun = ObjectiveFunction('Sdescription','objective function', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).BeamWeight=Tinput(n).rho*Tinput(n).b*Tinput(n).h*Tinput(n).L;end',...
    'CoutputNames',{'BeamWeight'},'Liostructure',true,...
    'CinputNames',{'rho' 'b' 'h' 'L'});

%% Definition of the Constraint
% Construct a |Constraint| defined by the maximum tip displacement of the
% beam.
XconMaxStress = Constraint('Sdescription','constraint', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).Constraint=Tinput(n).w-Tinput(n).MaxW; end',...
    'CoutputNames',{'Constraint'},'Liostructure',true,...
    'CinputNames',{'w' 'MaxW' },...
    'Linequality',true);

%% Definition of the OptimizationProblem
% Construct the |OptimizationProblem| from the |ObjectiveFunction|, the
% |Constraint| and the |Model|.
Xop = OptimizationProblem('Sdescription','Optimization problem', ...
    'XobjectiveFunction',Xobjfun,'CXconstraint',{XconMaxStress},'Xmodel',Xmodel);

% Define the Optimizers
Xsqp = SequentialQuadraticProgramming('finitedifferenceperturbation',0.01);
Xcobyla = Cobyla();
Xga = GeneticAlgorithms('Smutationfcn','mutationadaptfeasible','NmaxIterations',50, ...
    'NPopulationSize',200);

%% Optimization: Setup
% Reset the random number generator in order to always obtain the same
% results. *DO NOT CHANGE THE VALUES OF THE SEED!*
OpenCossan.resetRandomNumberGenerator(542727);

%% Optimization: Sequential Quadratic Programming
% Optimize the beam width using Sequential Quadratic Programming
Xoptimum1 = Xop.optimize('Xoptimizer',Xsqp);
% Show results of the optimization
display(Xoptimum1)

%% Optimization: Cobyla
% Optimize the beam width using Cobyla
Xoptimum2 = Xop.optimize('Xoptimizer',Xcobyla);
% Show results of the optimization
display(Xoptimum2)

%% Optimization: Genetic Algorithm
% Optimize the beam width using Genetic Algorithm
Xoptimum3 = Xop.optimize('Xoptimizer',Xga);
% Show results of the optimization
display(Xoptimum3)

%% Compare Optimization results
% Show results in a table
SQP = [Xoptimum1.NevaluationsObjectiveFunctions;
       Xoptimum1.VoptimalScores;
       Xoptimum1.VoptimalDesign';
       Xoptimum1.VoptimalConstraints];
   
COBYLA = [Xoptimum2.NevaluationsObjectiveFunctions;
          Xoptimum2.VoptimalScores;
          Xoptimum2.VoptimalDesign;
          Xoptimum2.VoptimalConstraints(1)];
  
GA = [Xoptimum3.NevaluationsObjectiveFunctions;
      Xoptimum3.VoptimalScores;
      Xoptimum3.VoptimalDesign';
      Xoptimum3.VoptimalConstraints];
  
results = table(SQP,COBYLA,GA,'RowNames',{'Number of Evaluations',...
    'Objective Function', 'Design Variable b', 'Design Variable h',...
    'Constraint'});

display(results);

%% Validate Solutions
% Compare the optimal constraints against the reference solutions.
Vsolution = [SQP(5) COBYLA(5) GA(5)];
Vreference=[ 1.01e-07   2.6385e-05   9.9860e-04];
assert(abs(max(Vsolution-Vreference))<1e-4, 'Tutorial:TutorialCantileverBeamOptimization',...
    'Solutions do not match reference values');

%% Next Tutorials
%
% * Cantilever Beam Reliability Analysis: <TutorialCantileverBeamMatlabReliabilityAnalysis.html>
% * Cantilever Beam Reliability Based Optimization: <TutorialCantileverBeamMatlabRBO.html>