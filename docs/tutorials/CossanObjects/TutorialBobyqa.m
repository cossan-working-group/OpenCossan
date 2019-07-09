%% Tutorial for the BOBYQA object
%
% In this tutorial BOBYQA is used to find the minimum of the Rosenbrock function 
% where f(x) represents the objective function x1 and x2 are continuos design variables defined in (-5,5)
%
% See Also: http://cossan.co.uk/wiki/index.php/@Bobyqa
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/computeFailureProbability@ProbabilisticModel
%
% $Copyright~1993-2015,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$

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

clear;
close all
clc;
%% Create input 
% In this tutorial we create a very simple accademic example in order to show
% how to used the optimization method. The input object must contain at least 1
% Design Variable.

X1      = opencossan.optimization.DesignVariable('Sdescription','design variable 1','value',rand,...
    'lowerBound',-5,'upperBound',5);
X2      = opencossan.optimization.DesignVariable('Sdescription','design variable 2','value',rand,...
    'lowerBound',-5,'upperBound',5);
Xin     = opencossan.common.inputs.Input('MembersNames',{'X1' 'X2'},'Members',{X1 X2});


%% Define a model 
SrosenbrockPath=fullfile(opencossan.OpenCossan.getRoot,'examples','Models','MatlabFunctions','Rosenbrock.m');
Xm  = opencossan.workers.Mio('Description','the objective function is the Rosenbrock function', ...
    'FullFileName',SrosenbrockPath, ...
...    'Spath',SrosenbrockPath,...
...    'Sfile','Rosenbrock.m',...
...    'Liostructure',false,...
    'IsFunction',true,...
...    'Liomatrix',true,...
    'InputNames',{'X1','X2'},...
    'OutputNames',{'mioout'});
% 
 Xe      = Evaluator('Xmio',Xm);     % Define the evaluator
 Xmdl    = Model('Xevaluator',Xe,'Xinput',Xin);


%%  Create objective function
% The objective function corresponds to the output of the model. It is not
% necessary to have a Model to perform and optimization. 

Xofun1   = ObjectiveFunction('Sdescription','objective function', ...
    'Sscript','for n=1:length(Toutput), Toutput(n).fobj=Tinput(n).mioout; end',...
    'Cinputnames',{'mioout'},...
    'Liostructure',true,...
    'Coutputnames',{'fobj'});


%% define the optimizator problem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'Xmodel',Xmdl,'VinitialSolution',[-4 1], ...
    'XobjectiveFunction',Xofun1);

%% Create optimizer
% A COBYLA objet is a optimizer with 2 dedicate parameters:
% * initialTrustRegion = define the radious of the initial spheric trust region
% * finalTrustRegion = define the minimum radius of the spheric trust region

Xbob    = Bobyqa('nInterpolationConditions',0,...
    'stepSize',0.01,...
    'rhoEnd', 1e-6,...
    'xtolRel',1e-9,...
    'minfMax',1e-9,...
    'ftolRel',1e-8,...
    'ftolAbs',1e-14,...
    'verbose',1);

% % Reset the random number generator in order to obtain always the same results.
% % DO NOT CHANGE THE VALUES OF THE SEED
% OpenCossan.resetRandomNumberGenerator(46354)

Xoptimum=Xop.optimize('Xoptimizer',Xbob);
display(Xoptimum)

%% Reference Solution
OpenCossan.cossanDisp('Textbook solution');
OpenCossan.cossanDisp('f(1.0,1.0) = 0');
OpenCossan.cossanDisp('Reference solution');
OpenCossan.cossanDisp(['0.999997828110346 ','0.999995813360559'])
OpenCossan.cossanDisp('Bobyqa solution');
OpenCossan.cossanDisp(num2str(Xoptimum.getOptimalDesign,'% 10.15f'));

%% Validate solution
Vreference=[  0.999997828110346; 0.999995813360559];
Mdata = [Xoptimum.XdesignVariable(1).Vdata; Xoptimum.XdesignVariable(2).Vdata];
assert(max(Vreference-Mdata(:,end))<1e-4,...
    'openCOSSAN:Tutorial:TutorialCobylaWrongReferenceSolution',...
    'Reference solution not identified!')

