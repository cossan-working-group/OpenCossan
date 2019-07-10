%% TutorialCantileverBeamMatlabOptimization
% Perform optimization using Matlab evaluator
%
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/Cantilever_Beam

%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2019 COSSAN WORKING GROUP

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

%% Preparation of the Input
% In this tutorial the random variable are replaced by two design variables
%
% The optimization analysis requires the definition of Design Variables
% (i.e. the variables that define new configurations)
b = opencossan.optimization.ContinuousDesignVariable('value', 0.12, 'lowerBound', 0.01, 'upperBound', 0.50, 'Description', 'Beam width');
h = opencossan.optimization.ContinuousDesignVariable('value', 0.54, 'lowerBound', 0.02, 'upperBound', 1, 'Description', 'Beam Heigth');

% In this example we do not use random variables and we only use Parameters
L = opencossan.common.inputs.Parameter('value', 1.8, 'Description', 'Beam Length');
maxDisplacement = opencossan.common.inputs.Parameter('value', 0.001, 'Description', 'Maximum allowed displacement');
P = opencossan.common.inputs.Parameter('value', 10000, 'Description', 'Load');
rho = opencossan.common.inputs.Parameter('value', 600, 'Description', 'density');
E = opencossan.common.inputs.Parameter('value', 10e9, 'Description','Young''s modulus');

% Definition of the Function
I = opencossan.common.inputs.Function('Description','Moment of Inertia','Expression','<&b&>.*<&h&>.^3/12');

%% Prepare Input Object
% The above prepared objects can be added to an Input Object
XinputOptimization = opencossan.common.inputs.Input('Members',{L b P h rho E I maxDisplacement},...
    'MembersNames',{'L' 'b' 'P' 'h' 'rho' 'E' 'I' 'MaxW'});

%% Preparation of the Evaluator
% Use of a matlab script to compute the Beam displacement
folder = fileparts(mfilename('fullpath'));% returns the current folder
Xmio = opencossan.workers.Mio('FullFileName',fullfile(folder,'model','tipDisplacement.m'),...
    'InputNames',{'I', 'b', 'L', 'h', 'rho', 'P', 'E'},'Format','structure', ...
    'OutputNames',{'w'});
% Add the MIO object to an Evaluator object
Xevaluator = opencossan.workers.Evaluator('CXmembers',{Xmio},'CSmembers',{'Xmio'});

%% Preparation of the Physical Model
% Define the Physical Model
Xmodel = opencossan.common.Model('Input', XinputOptimization, 'Evaluator', Xevaluator);

%% Check feasibility of the optimization preoblem
% The EesignOfExperiment analysis can be used to see if a feasible solution
% is present in the bounds set for the Design Varaibles Define a user
% defined DOE object. We evaluate the model at the lower and upper bounds
% of the design variable plus the current values. Therefore for each design
% variable we have 3 values and a total of 9 model evaluations are
% required. The evaluation points are defined by means of the MdeoFactor
% matrix defined between -1 and 1.
MdoeFactors=[-1 -1;
    0 -1;
    1 -1;
    -1  0;
    0  0;
    1  0;
    -1  1;
    0  1;
    1  1];
% When the flag Lusecurrentvalues is set to true the current values of the
% design variables is used in corresponcence of the MdoeFactors=0.

Xdoe = opencossan.simulations.DesignOfExperiments('Sdesigntype','UserDefined',...
    'Mdoefactors',MdoeFactors,'Lusecurrentvalues',true);

% Show summary of the design of experimemts
display(Xdoe)

% and now, evaluate the model at the points defined by the
% DesignOfExperiment
XoutDoe=Xdoe.apply(Xmodel);

%% Results of the Design of Experiments
h = XoutDoe.getValues('Sname','h');
b = XoutDoe.getValues('Sname','b');
w = XoutDoe.getValues('Sname','w');
status = cell(9,1);

for n = 1:numel(w)
    if (w(n) < maxDisplacement.Value)
        status{n} = 'Feasible';
    else
        status{n} = 'Infeasible';
    end
end

results = table(h,b,w,status);
format shorte;
display(results);
format short;

% There are 3 feasible solutions and this means the the opimization problem
% is well define. Now we have to identify the oprimal solution.

%% Define the Objective Funtion
% The aim of this optimization is to minimaze the weight of the beam. The
% weight can be easely computed using a matlab script.
Xobjfun = opencossan.optimization.ObjectiveFunction('Description','Objective function', ...
    'Script','for n=1:length(Tinput),Toutput(n).BeamWeight=Tinput(n).rho*Tinput(n).b*Tinput(n).h*Tinput(n).L;end', ...
    'OutputNames',{'BeamWeight'}, ...
    'Format','structure', ...
    'InputNames',{'rho' 'b' 'h' 'L'});

%% Create (inequality) constraint
% The maximum displacement of the beam tip
XconMaxStress = opencossan.optimization.Constraint(...
    'Description','Constraint', ...
    'Script','for n=1:length(Tinput),Toutput(n).Constraint=Tinput(n).w-Tinput(n).MaxW; end', ...
    'OutputNames',{'Constraint'}, ...
    'Format','structure', ...
    'InputNames',{'w' 'MaxW' }, ...
    'Inequality',true);

%% Create object OptimizationProblem
Xop = opencossan.optimization.OptimizationProblem('Sdescription','Optimization problem', ...
    'XobjectiveFunction',Xobjfun,'Xconstraint',XconMaxStress,'Xmodel',Xmodel);

% Define Optimizers
Xsqp = opencossan.optimization.SequentialQuadraticProgramming();
Xcobyla = opencossan.optimization.Cobyla();
Xga = opencossan.optimization.GeneticAlgorithms('Smutationfcn','mutationadaptfeasible','NmaxIterations',10, ...
    'NPopulationSize',10);

%% Perform optimization

% Reset the random number generator in order to obtain always the same
% results. DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(542727)

% We start with the Sequential Quadratic Programming method.
Xoptimum1 = Xop.optimize('Xoptimizer',Xsqp);
% Show results of the optimization
display(Xoptimum1)

% Now we optimize the problem using Cobyla
Xoptimum2 = Xop.optimize('Xoptimizer',Xcobyla);
% Show results of the optimization display(Xoptimum2)
display(Xoptimum2)
% Now we optimize the problem using Genetic Algorithms
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

%% RELIABILITY ANALYSIS
% The reliaility analysis is performed by the following tutorial
%  See Also: <TutorialCantileverBeamMatlabReliabilityAnalysis.html>

% echodemo TutorialCantileverBeamMatlabReliabilityAnalysis

%% RELIABILITY BASED OPTIMIZAZION
% The reliability based optimization is shown in the following tutotial See
% Also: <TutorialCantileverBeamMatlabRBO.html>

% echodemo TutorialCantileverBeamMatlabRBO
