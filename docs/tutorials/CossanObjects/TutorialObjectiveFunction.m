%% Tutorial for the objective function
% The ObjectiveFunction object defines the objective function for the
% optimization problem. It is a subclass of the Mio object and inherits all
% the methods from this class. 
% Please refer to the Mio tutorial and Optimization tutorial  for more
% examples of objective function
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@ObjectiveFunction
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 
clear
close all
clc;
%% Constructor
Xofun   = opencossan.optimization.ObjectiveFunction('description','objective function', ...
         'IsFunction',true, ...
...         'Liostructure',true,'Liomatrix',false,...
          'InputNames',{'X1','X2'},... % Define the inputs 
          'function',@rastriginsfcn,...
          'OutputNames',{'fobj'}); % Define the outputs

% Show details of the ObjectiveFunction
display(Xofun)

% The ObjectFunction can also be defined as a script.

ScurrentPath=which('TutorialObjectiveFunction');
[Spath, ~ ]=fileparts(ScurrentPath);
Xofun1  = opencossan.optimization.ObjectiveFunction('description','objective function of optimization problem', ...
    'FullFileName',fullfile(Spath,'Files4Mio','ExampleMioStructure') ,...
...    'Sfile','ExampleMioStructure',...
...    'Liostructure',true,...
...    'Lfunction',true,...
    'InputNames',{'X1','X2'},...
    'OutputNames',{'mioout'});

display(Xofun1)


%% Use ObjectiveFunction
% In order to be able to use the method evaluate of ObjectiveFunction an
% OptimizationProblem needs to be defined.
Xofun1.evaluate
