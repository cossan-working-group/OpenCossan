%% Tutorial AntennaTower
%
% In this tutorial, a robust optimization of a 25-bars truss structure,
% i.e. an antenna tower, is carried out. The direction of the force acting
% on the  structure and the structural parameters are affected by
% uncertainties. 
%
% The objective of the optimization is to minimize the volume of the
% structure (proportional to the costs of the structure), while assuring
% that the maximum nodal displacement is under a certain threshold. 
% Because of the uncertainties involved in the problem, the maximum
% displacement is varying for fixed values of the design variables. Thus, a
% design-by-six-sigma approach is used to take into account the output
% variability in the constraint function. 
% 
% Note that this approach is actually a simplification of Reliability Based
% Optimisation, where the distribution of the output is assumed to be
% Gaussian. 
%
% Implemented in the OpenCossan by Matteo Broggi and Edoardo Patelli
%
% See Also https://cossan.co.uk/wiki/index.php/Truss_Structure

% Copyright 1993-2018, COSSAN Working Group

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(123456)
OpenCossan.setVerbosityLevel(1)
% Retrieve the directory where this tutorial is stored
StutorialPath = fileparts(which('TutorialAntennaTower.m'));

%% Define Inner loop Model 
%
% The inner loop model computes the maximum displacements of the truss
% structure with random Young's moduli of the beams and random direction
% of the applied force. 
% The Young's moduli of the beams is modelled as Gaussian distribution with
% a 5% coeficient of variation. The module of the force is 100e3 N, with a
% variable direction of +-5 degrees from the vertical direction.
%
%% Input definition
% Create a set of 25 independent, identical distributed random variables
% for the Young's moduli of the beams

E = RandomVariable('Sdistribution','normal','mean',1e7,'std',0.05*1e7);
Xrvset1 = RandomVariableSet('CXrv',{E},'Cmembers',{'E'},'Nrviid',25);

% Create a set of two uniform distributed random variables for the force
% direction. This direction is a spherical angle deviation of +- 5 degrees
% from the vertical direction, and a totally random direction in the
% horizontal plane.

theta = RandomVariable('Sdistribution','uniform','parameter1',-5/180*pi,'parameter2',5/180*pi);
phi = RandomVariable('Sdistribution','uniform','parameter1',-pi,'parameter2',pi);
Xrvset2 = RandomVariableSet('CXrv',{theta,phi},'Cmembers',{'theta','phi'});

% The following functions computes the force components given the random
% direction
Fx = Function('Sexpression','-100e3*cos(<&phi&>).*sin(<&theta&>)');
Fy = Function('Sexpression','-100e3*sin(<&phi&>).*sin(<&theta&>)');
Fz = Function('Sexpression','-100e3*cos(<&theta&>)');

% The starting values of the sections are assigned to parameters. There are
% 6 groups of beams, charaterized by the same section.
A1 = Parameter('value',0.4);
A2 = Parameter('value',0.1);
A3 = Parameter('value',3.4);
A4 = Parameter('value',1.3);
A5 = Parameter('value',0.9);
A6 = Parameter('value',1.0);

% Add all the input quantities to an Input object
XinpA = Input('CXmembers',{Xrvset1,Xrvset2,Fx,Fy,Fz,A1,A2,A3,A4,A5,A6},...
    'CSmembers',{'Xrvset1','Xrvset2','Fx','Fy','Fz','A1','A2','A3','A4','A5','A6'});

%% Model definition
% A matlab function is used to compute the maximum displacement of the
% truss structure. The volume of the beams are also returned as an
% additional output. This second output is used by the objective funtion.
% To see the function used in the MIO, please open the file TrussMaxDisp.m
% found in the tutorial folder.

XmioA = Mio('Spath',StutorialPath,...
    'Spath',StutorialPath,...
    'Sfile','TrussMaxDispScript.m',...
    'Lfunction',false,...
    'CinputNames',{'E_1','E_2','E_3','E_4','E_5','E_6','E_7','E_8','E_9','E_10',...
    'E_11','E_12','E_13','E_14','E_15','E_16','E_17','E_18','E_19','E_20',...
    'E_21','E_22','E_23','E_24','E_25','theta','phi'},...
    'CoutputNames',{'maxDisp','beamVolumes'});

% The model object is constructed as follows:
XevalA = Evaluator('CXmembers',{XmioA},'CSnames',{'XmioA'});
XmodelA = Model('Xevaluator',XevalA,'Xinput',XinpA);

%% Define Outer loop Optimization problem 
% The outer loop defines the optimization problem. It takes the output of
% the inner loop as inputs for the optimization. 
% The desing variables of the optimisation problem are the sections of the
% beams  

% Define Design Variables. 
XdvA1 = DesignVariable('value',0.4,'lowerbound',0.4*0.8,'upperbound',0.4*1.2);
XdvA2 = DesignVariable('value',0.1,'lowerbound',0.1*0.8,'upperbound',0.1*1.2);
XdvA3 = DesignVariable('value',3.4,'lowerbound',3.4*0.8,'upperbound',3.4*1.2);
XdvA4 = DesignVariable('value',1.3,'lowerbound',1.3*0.8,'upperbound',1.3*1.2);
XdvA5 = DesignVariable('value',0.9,'lowerbound',0.9*0.8,'upperbound',0.9*1.2);
XdvA6 = DesignVariable('value',1.0,'lowerbound',1.0*0.8,'upperbound',1.0*1.2);
% Define Input object for OptimizationProblem
Xinp = Input('CXmembers',{XdvA1,XdvA2,XdvA3,XdvA4,XdvA5,XdvA6},...
    'CSmembers',{'XdvA1','XdvA2','XdvA3','XdvA4','XdvA5','XdvA6'});

%% Definition of the constraint
% A six-sigma constraint is defined for the maximum displacement. The
% constrain is defined such that:
%
% $$\mu( max(\mathbf{x}) ) - 6 \sigma ( max(\mathbf{x}) ) \leq 4m.$$
%
% $\mathbf{x}$ indicates the nodal displacements of the truss structure.
%
Xcon = Constraint('Sscript',['for n=1:length(Tinput);' ...
'Toutput(n).sixSigmaConstraint = 4.0 -mean(Tinput(n).maxDisp)-6*std(Tinput(n).maxDisp);end'],...
    'Cinputnames',{'maxDisp'},...
    'Soutputname','sixSigmaConstraint',...
    'Linequality',true);

%% Definition of the objective function
%
% The objective function is the total volume of the truss structure. The
% inner loop model returns the beam volumes for each execution of the
% matlab function. Since the volume does not depend on random parameters,
% only the volume of the first sample is kept.

XobjFun = ObjectiveFunction('Sscript',['for n=1:length(Tinput);' ...
    'Toutput(n).totVolume = sum(Tinput(n).beamVolumes);' ...
    'Toutput(n).totVolume=Toutput(n).totVolume(1);end'],...
    'CinputNames',{'beamVolumes'}, ...
    'Coutputnames',{'totVolume'});

%% Define the RobustDesign 
% The RobustDesign problem is defined by combining a model, Objective
% function(s), Constraint(s), Input containing the Design Variables and 
% finally a mapping between the DesignVariable objects and the input of the
% Model of the inner loop. 
% 
% In this example the values of the desing variable (e.g. XdvA1) is used to
% re-define the paramter values (e.g. A1) in the inner loop
%
XrobustDesign = RobustDesign('Sdescription','Antenna tower robust design optimization', ...
        'XinnerLoopModel',XmodelA, ...
        'Xinput',Xinp, ...
        'XobjectiveFunction',XobjFun,...
        'Xconstraint',Xcon,...
        'Xsimulator',LatinHypercubeSampling('Nsamples',200),...
        'CSinnerLoopOutputNames',{'maxDisp','beamVolumes'},...
        'CdesignvariableMapping',{'XdvA1' 'A1' 'parametervalue';...
                                  'XdvA2' 'A2' 'parametervalue';...
                                  'XdvA3' 'A3' 'parametervalue';...
                                  'XdvA4' 'A4' 'parametervalue';...
                                  'XdvA5' 'A5' 'parametervalue';...
                                  'XdvA6' 'A6' 'parametervalue'}...
        );
    
%% Create optimizer
% The optimization algorithm of choice is Sequential Quadratic Programming.
% Since no optional parameter is passed to the constructor, the default
% parameters values of the algorithm are used.

%Xoptimizer   = SequentialQuadraticProgramming;
Xoptimizer   = Cobyla;

%% Perform the analysis
% The optimization analysis is performed. The initial solution is set to
% the default values of the parameters defined for the inner loop model.

Xoptimum = XrobustDesign.optimize('Xoptimizer',Xoptimizer,...
    'VinitialSolution',[A1.value,A2.value,A3.value,A4.value,A5.value,A6.value]);

OpenCossan.setVerbosityLevel(3) % increase verbosity to show more info with display
display(Xoptimum)
% plot the objective function evolution
f1=Xoptimum.plotObjectiveFunction;
% plot the constraint evolution
f2=Xoptimum.plotConstraint;
% plot the design variable evolution
f3=Xoptimum.plotDesignVariable; 

%% Close figures and validate solution
close(f1); close(f2); close(f3);

% Validate Solution
assert(abs(Xoptimum.VoptimalScores -  2400)<10,...the optimum is around 4000
    'CossanX:Tutorials:TutorialAntennaTower',...
    'Reference Solution for the antenna tower does not match.')
