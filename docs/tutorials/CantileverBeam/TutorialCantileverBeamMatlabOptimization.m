%% TutorialCantileverBeamMatlabOptimization
% Perform optimization using Matlab evaluator
%
%
% See Also http://cossan.co.uk/wiki/index.php/Cantilever_Beam
%
% <html>
% <h3 style="color:#317ECC">Copyright 2006-2020: <b> COSSAN working group</b></h3>
% Author: <b>Edoardo-Patelli</b> <br> 
% <i>Institute for Risk and Uncertainty, University of Liverpool, UK</i>
% <br>COSSAN web site: <a href="http://www.cossan.co.uk">http://www.cossan.co.uk</a>
% <br><br>
% <span style="color:gray"> This file is part of <span style="color:orange">openCOSSAN</span>.  The open source general purpose matlab toolbox
% for numerical analysis, risk and uncertainty quantification (<a
% href="http://www.cossan.co.uk">http://www.cossan.co.uk</a>).
% <br>
% <span style="color:orange">openCOSSAN</span> is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
% <span style="color:orange">openCOSSAN</span> is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details. 
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <a href="http://www.gnu.org/licenses/">http://www.gnu.org/licenses/"</a>.
% </span></html>

%% Preparation of the Input
% In this tutorial the random variable are replaced by two design variables
%
% The optimization analysis requires the definition of Design Variables (i.e.
% the variables that define new configurations)  
b=DesignVariable('value',0.12,'lowerBound',0.01,'upperBound',0.50,'Sdescription','Beam width');
h=DesignVariable('value',0.54,'lowerBound',0.02,'upperBound',1,'Sdescription','Beam Heigth');

% In this example we do not use random variables and we only use Parameters
L=Parameter('value',1.8,'Sdescription','Beam Length');
MaxW=Parameter('value',0.001,'Sdescription','Maximum allowed displacement');
P=Parameter('value',10000,'Sdescription','Load');
rho=Parameter('value',600,'Sdescription','density');
E=Parameter('value',10e9,'Sdescription','Young''s modulus');
% Definition of the Function
I=Function('Sdescription','Moment of Inertia','Sexpression','<&b&>.*<&h&>.^3/12');

%% Prepare Input Object
% The above prepared objects can be added to an Input Object
XinputOptimization=Input('CXmembers',{L b P h rho E I MaxW},...
    'CSmembers',{'L' 'b' 'P' 'h' 'rho' 'E' 'I' 'MaxW'});
% Show summary of the Input Object
display(XinputOptimization)
%% Preparation of the Evaluator
% Use of a matlab script to compute the Beam displacement
Sfolder=fileparts(mfilename('fullpath'));% returns the current folder
Xmio=Mio('Spath',fullfile(Sfolder,'MatlabModel'),'Sfile','tipDisplacement.m',...
    'Cinputnames',{'I' 'b' 'L' 'h' 'rho' 'P','E'},'Sformat','structure', ...
    'Coutputnames',{'w'});
% Add the MIO object to an Evaluator object
Xevaluator=Evaluator('Solvers',Xmio,'SolversName',"Xmio");

%% Preparation of the Physical Model
% Define the Physical Model
Xmodel=Model('Input',XinputOptimization,'Evaluator',Xevaluator);

%% Check feasibility of the optimization preoblem
% The EesignOfExperiment analysis can be used to see if a feasible solution is
% present in the bounds set for the Design Varaibles 
% Define a user defined DOE object. 
% We evaluate the model at the lower and upper bounds of the design variable
% plus the current values. Therefore for each design variable we have 3 values
% and a total of 9 model evaluations are required.
% The evaluation points are defined by means of the MdeoFactor matrix defined
% between -1 and 1. 
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
         
Xdoe=simulations.DesignOfExperiments('Sdesigntype','UserDefined',...
    'Mdoefactors',MdoeFactors,'Lusecurrentvalues',true);

% Show summary of the design of experimemts 
display(Xdoe)

% and now, evaluate the model at the points defined by the DesignOfExperiment 
XoutDoe=Xdoe.apply(Xmodel);

%% Show the quantify of interest
Cnames={'h' 'b' 'w'};
Mdoe=XoutDoe.getValues('Cnames',Cnames);

% Show results

fprintf('%10s | %10s | %10s | %10s\n-------------------------------------------------\n',Cnames{:}, 'Solution status')

for n=1:size(Mdoe,1)
    if Mdoe(n,3)<MaxW.value
        fprintf('%10.3e | %10.3e | %10.3e | %10s\n',Mdoe(n,:),'Feasible Solution')
    else
        fprintf('%10.3e | %10.3e | %10.3e | %10s\n',Mdoe(n,:),'Uneasible Solution')

    end
end

% There are 3 feasible solutions and this means the the opimization problem is
% well define. Now we have to identify the oprimal solution.


%% Define the Objective Funtion
% The aim of this optimization is to minimaze the weight of the beam. The weight
% can be easely computed using a matlab script.  
Xobjfun   = ObjectiveFunction('Sdescription','objective function', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).BeamWeight=Tinput(n).rho*Tinput(n).b*Tinput(n).h*Tinput(n).L;end',...
    'CoutputNames',{'BeamWeight'},'Sformat','structure',...
    'CinputNames',{'rho' 'b' 'h' 'L'});

%% Create (inequality) constraint
% The maximum displacement of the beam tip 
XconMaxStress   = Constraint('Sdescription','constraint', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).Constraint=Tinput(n).w-Tinput(n).MaxW; end',...
    'CoutputNames',{'Constraint'},'Sformat','structure',...
    'CinputNames',{'w' 'MaxW' },...
    'Linequality',true);

%% Create object OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'XobjectiveFunction',Xobjfun,'CXconstraint',{XconMaxStress},'Xmodel',Xmodel);

% Define Optimizers
Xsqp=SequentialQuadraticProgramming('finitedifferenceperturbation',0.01);
Xcobyla=Cobyla;
Xga=GeneticAlgorithms('Smutationfcn','mutationadaptfeasible','NmaxIterations',10, ...
    'NPopulationSize',10);


%% Perform optimization

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(542727)

% We start with the Sequential Quadratic Programming method.
Xoptimum1=Xop.optimize('Xoptimizer',Xsqp);
% Show results of the optimization
display(Xoptimum1)

% Now we optimize the problem using Cobyla
Xoptimum2=Xop.optimize('Xoptimizer',Xcobyla);
% Show results of the optimization
display(Xoptimum2)

% Now we optimize the problem using Genetic Algorithms
Xoptimum3=Xop.optimize('Xoptimizer',Xga);
% Show results of the optimization
display(Xoptimum3)


%% Compare Optimizarion results
Cnames={'SQP','COBYLA','GA'};
Sformat='%10.3e | %10.3e | %10.3e | %12s\n';
% Show results

fprintf('%10s | %10s | %10s | %10s\n-------------------------------------------------\n',Cnames{:}, 'Property')

Vev(1)=Xoptimum1.NevaluationsObjectiveFunctions;
Vev(2)=Xoptimum2.NevaluationsObjectiveFunctions;
Vev(3)=Xoptimum3.NevaluationsObjectiveFunctions;
fprintf(Sformat,Vev,'Number evaluations')

Voptimim(1)=Xoptimum1.getOptimalObjective;
Voptimim(2)=Xoptimum2.getOptimalObjective;
Voptimim(3)=Xoptimum3.getOptimalObjective;

fprintf(Sformat,Voptimim,'Objective Function')

Vdv(:,1)=Xoptimum1.getOptimalDesign;
Vdv(:,2)=Xoptimum2.getOptimalDesign;
Vdv(:,3)=Xoptimum3.getOptimalDesign;

fprintf(Sformat,Vdv(:,1),' Design Variable b')
fprintf(Sformat,Vdv(:,2),' Design Variable h')

Vcon=zeros(5,3);
Vcon(:,1)=Xoptimum1.getOptimalConstraint;
Vcon(:,2)=Xoptimum2.getOptimalConstraint;
Vcon(:,3)=Xoptimum3.getOptimalConstraint;
fprintf(Sformat,Vcon(1,:),'Constaint')

%% Validate Solutions
Vreference=[ 1.5627e-04   2.6385e-05   9.9860e-04];
assert(max(abs(Vreference-Voptimim))<1e-4, 'Tutorial:TutorialCantileverBeamOptimization',...
    'Solutions do not match reference values')


%% RELIABILITY ANALYSIS 
% The reliaility analysis is performed by the following tutorial
%  See Also: <TutorialCantileverBeamMatlabReliabilityAnalysis.html>

% echodemo TutorialCantileverBeamMatlabReliabilityAnalysis

%% RELIABILITY BASED OPTIMIZAZION 
% The reliability based optimization is shown in the following tutotial 
% See Also: <TutorialCantileverBeamMatlabRBO.html>

% echodemo TutorialCantileverBeamMatlabRBO
