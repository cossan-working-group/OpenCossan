%% TutorialCantileverBeamAnsys
% Model Definition and Uncertainty Quantification
% This script run the Cantilever Beam Tutorial for Ansys in the COSSAN-X Engine
%
% See Also http://cossan.co.uk/wiki/index.php/Cantilever_Beam


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

%% Input files manipulation 

% Retrieve the directory where this tutorial is stored
StutorialPath = fileparts(which('TutorialCantileverBeamAnsys.m'));

% copy the FE-input files with COSSAN-identifiers to the working directory
copyfile(fullfile(StutorialPath,'cantileverBeamAnsys','BeamAnsys.txt.cossan'),...
    fullfile(OpenCossan.getCossanWorkingPath),'f');

disp('The input file for the FE solver has been copied to the following folder:')
disp(OpenCossan.getCossanWorkingPath)

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)



%% Perform optimization in Matlab
H=DesignVariable('Sdescription','Beam Height','lowerBound',10,'upperBound',50,'value',20);
W=DesignVariable('Sdescription','Beam Width','lowerBound',10,'upperBound',50,'value',20);
XmaxStress=Parameter('Sdescription','Maximum stress','value',200);

Xinput=Input('CXmembers',{H W XminStress XmaxStress},...
    'CSmembers',{'H' 'W' 'XminStress' 'XmaxStress'});


%% Create connector
Xi=Injector('Stype','scan','Sscanfilepath',OpenCossan.getCossanWorkingPath,'Sscanfilename','BeamAnsys.txt.cossan', ...
    'Srelativepath','./','Sfile','BeamAnsys.txt');

XrespVolume = Response(    'Sname', 'Volume', ...
    'Sfieldformat', '%e', ...
    'Ncolnum',1, ...
    'Nrownum',1);

XrespStress = Response(    'Sname', 'MaximumStress', ...
    'Sfieldformat', '%e', ...
    'Ncolnum',2, ...
    'Nrownum',1);

Xe=Extractor('Sdescription','Extract Volume and maximum stress', ...
    'Srelativepath','./', ... % this is the directory where the input and output are contained
    'Sfile','OutputMatlab.txt', ...
    'CXresponse',{XrespVolume XrespStress});

Xc=Connector('SpredefinedType','ansys','Sworkingdirectory','/tmp',...
    'Smaininputfile','BeamAnsys.txt',...
    'Smaininputpath',OpenCossan.getCossanWorkingPath, ...
    'Soutputfile','AnsysOutput.out','CXmembers',{Xe Xi}, ...
    'LkeepSimulationFiles',false);


Xeval=Evaluator('CXmembers',{Xc},'CSmembers',{'Xc'});

Xmodel=Model('Xevaluator',Xeval,'Xinput',Xinput);

%% Check FE solver
% A deterministic simulation is performed in order to check the connector and
% the FE solver

Xout=Xmodel.deterministicAnalysis;
% Show the value of the Volume
fprintf('Beam Volume; %e \n',Xout.getValues('Sname','Volume'))

% Show the value of the Volume
fprintf('Maximum stress: %e',Xout.getValues('Sname','MaximumStress'))

%% Design of Experiments
% The design of experiments allows to see the variability of the quantities of
% interest respect to the values of the design variables. 
% In this example the FullFactorial method for design of experiments with 3
% levels for each design variable is used.
         
Xdoe=DesignOfExperiments('Sdesigntype','FullFactorial',...
    'Vlevelvalues',[3 3],'Clevelnames',{'H' 'W'});

% Show summary of the design of experimemts 
display(Xdoe)

% and now, evaluate the model at the points defined by the DesignOfExperiment 
XoutDoe=Xdoe.apply(Xmodel);

% Show results
fprintf(' Results of the Design of Experiments\n')
fprintf('--------------------------------------------------------\n');
fprintf('     H      |      W      |   Volume  | Maximum Streess\n');
fprintf('--------------------------------------------------------\n');
for n=1:length(XoutDoe.Tvalues)
    fprintf(' %8.2e   |  %8.2e   |  %8.2e | %8.2e\n',XoutDoe.Tvalues(n).H,...
        XoutDoe.Tvalues(n).W,XoutDoe.Tvalues(n).Volume,XoutDoe.Tvalues(n).MaximumStress)
    
end

%% Perform Optimization of the Cantilever Beam
% The cantilever beam is now optimized respect to the volume (i.e. minimizing
% the volume) and the maximum stess allowed (i.e. constraint).

% Definition of the objective function
Xobjfun   = ObjectiveFunction('Sdescription','objective function', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).VolumeObj=Tinput(n).Volume;end',...
    'CoutputNames',{'VolumeObj'},...
    'CinputNames',{'Volume'});


% Create (inequality) constraint
XconMaxStress   = Constraint('Sdescription','constraint', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).DeltaStress=Tinput(n).MaximumStress-Tinput(n).XmaxStress; end',...
    'CoutputNames',{'DeltaStress'},...
    'CinputNames',{'MaximumStress' 'XmaxStress' },...
    'Linequality',true);

% Create object OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Optimization problem', ...
    'XobjectiveFunction',Xobjfun,'CXconstraint',{XconMaxStress},'Xmodel',Xmodel);

% Define Optimizer
%Xsqp=SequentialQuadraticProgramming('finitedifferenceperturbation',0.1);

%% Perform optimization
% The constrained optimization is performend adopting Cobyla algorithm with the
% default settings.
% This step requires few minutes to be completed. Please be patient :)

[Xoptimum Xout]=Xop.optimize('Xoptimizer',Cobyla);

%% Show results
% Plot the identified optimum
display(Xoptimum)

% Plot optimization evolution
f1=Xoptimum.plotObjectiveFunction;
f2=Xoptimum.plotDesignVariable;
f3=Xoptimum.plotConstraint;

% Please note that the strees in the cantilever beam is not negative. It is the
% difference between the stress in the beam and the maximum allowed stress to be
% negative (the values of the constraint).

Vstress=Xout.getValues('Sname','MaximumStress');
Vvolume=Xout.getValues('Sname','Volume');
disp('Detailes for the optimized cantilever beam')
fprintf('Maximum stress : %e\n',Vstress(end));
fprintf('Volume         : %e\n',Vvolume(end));

%% Close figure
close(f1),close(f2),close(f3)
