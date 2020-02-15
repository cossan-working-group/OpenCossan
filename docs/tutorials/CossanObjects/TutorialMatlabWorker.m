% Tutorial for MatlabWorker.
% This tutorial shows how to construct and use a MatlabWorker object.
%
clear
close all
clc;

import opencossan.workers.*
import opencossan.common.inputs.*
% Author: Edoardo Patelli
StutorialPath = fileparts(which('TutorialMatlabWorker.m'));

%% Define additional objects
% In order to use a MatlabWorker, it is necessary to create an Input object and
% create a Model with such an input and the MatlabWorker. Please refer to the
% relevant objects tutorials for additional help.

% Create random variables and random variable set
Nrv = 7;
RV=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
% Define a set of Random Variables of Nrv independent, identically
% distributed random variables
Xrvs1=opencossan.common.inputs.random.RandomVariableSet.fromIidRandomVariables('RandomVariable',RV,'Number',Nrv,'NamePrefix','RV_'); 

% Add a parameter
% The parameter is unnecessary here but it is used to test the behaviour of
% the MatlabWorker object.
Xpar=Parameter('value',5);

% Define Input object
Xinp  = Input;
Xinp  = add(Xinp,'Member',Xrvs1,'Name','Xrvs1');
Xinp  = add(Xinp,'Member',Xpar,'Name','Xpar');

% Add some samples to the Input
Xinp = Xinp.sample('Nsamples',10);

%% Define MatlabWorker 
% There are different ways to connect a Matlab function or a script with OpenCossan via the MatlabWorker class.
%
% Define Matlab Format
% The input and Output can be passed as:
% A) Matlab structures
% B) Matlab arrays (each array correspond to a variable)
% C) single array (each column of the array correspond to a variable)
% D) Matlab tables  

%% CASE A
% Matlab structures are used here for Input/Output. All the quantities
% contained in the input can be obtained in the input structure, in field
% names equal to the name of the input quantity.
%
% E.g.: Tinput(1).RV_1 contains the value of RV_1 for the first sample
%
% The Matlab function used is found in 'Files4MatlabWorker/ExampleMatlabWorkerStructure.m'

Xm  = MatlabWorker('Description', 'Performance function', ...
                'FullFileName',fullfile(StutorialPath,'Files4MatlabWorker','ExampleMatlabWorkerStructure.m'), ...
                'Format','structure',... % This flag specify the type of I/O
                'OutputNames',{'Out1';'Out2'},... % This field is mandatory
                'InputNames',{'RV_1';'RV_2'},...  % This field is mandatory
				'IsFunction',true); % This flag specify if the .m file is a script or a function. 
           
% The method evaluate is used yo execute the MatlabWorker. It requires a table
% input. 

% Test the MatlabWorker
TableOutput = evaluate(Xm,Xinp.getTable);
% The run MatlabWorker return a Matlab table containg only the results of the
% MatlabWorker
display(TableOutput)
            

%% First test - Use MonteCarlo simulation
%  Define Evaluator
Xev     = Evaluator('Solvers',Xm);
%  Define probmodel
Xmodel  = opencossan.common.Model('Input',Xinp,'Evaluator',Xev); 
%  Apply
opencossan.OpenCossan.cossanDisp('Test 1: 100 samples (20 batches) - Monte Carlo Simulation - MatlabWorker I/O Structures');
Xmc     = opencossan.simulations.MonteCarlo('Nsamples',100,'Nbatches',20);
Xo      = Xmc.apply(Xmodel);

% The SimulationOuput Xo contains now also the realization of the random
% variables the values of parameters and functions if defined in the Input
% object
display(Xo)

%% CASE B
% Multiple vectors are used here for Input/Output. The input values are
% passed as vectors in the order specified in the CinputNames field.
% Note that only mono-dimensional Parameters and Functions can be used with
% this input/output type.
%
% The Matlab function used is found in 'Files4MatlabWorker/ExampleMatlabWorkerFunction.m'
XmB  = MatlabWorker('Description', 'Performance function', ...
                'FullFileName',fullfile(StutorialPath,'Files4MatlabWorker','ExampleMatlabWorkerFunction.m'), ...
                'OutputNames',{'Out1' 'Out2'},... % This field is mandatory
                'InputNames',{'RV_1' 'RV_2' 'Xpar'},...    % This field is mandatory
                'Format','vectors',...     % This flag specify the type of I/O
				'IsFunction',true); % This flag specify if the .m file is a script or a function. 

% Test the MatlabWorker
TableOutput = evaluate(XmB,Xinp.getTable);
% The run MatlabWorker return a Matlab table containg only the results of the
% MatlabWorker
display(TableOutput)

    
%%  Second - Use MonteCarlo simulation
%   Define Evaluator
Xev     = Evaluator('Solvers',XmB);
%  Define probmodel
Xmodel  = opencossan.common.Model('Input',Xinp,'Evaluator',Xev); 
%   Apply
opencossan.OpenCossan.cossanDisp('Test 2: 100 samples (20 batches) - MCS - MatlabWorker Function');
Xmc     = opencossan.simulations.MonteCarlo('Nsamples',100,'Nbatches',20);
Xo      = Xmc.apply(Xmodel);

%% CASE C
% Matlab matrices are used here for Input/Output. Each row of the matrix
% correspond to a sample, and each column to an input quantity, in the
% order specified by the CinputNames field. As an example, the elements 
% (9,2) of the matrix in the MatlabWorker will contain the 9-th sampled value of
% RV_2.
% Please note that only random variables can be accessed with this
% input/output strategy.
%
% The Matlab function used is found in 'Files4MatlabWorker/ExampleMatlabWorkerMatrix.m'
XmC  = MatlabWorker('Description', 'Performance function', ...
                'FullFileName',fullfile(StutorialPath,'Files4MatlabWorker','ExampleMatlabWorkerMatrix.m'), ...
                'OutputNames',{'Out1';'Out2'},... % This field is mandatory
                'InputNames',{'RV_1';'RV_2'},...    % This field is mandatory
                'Format','matrix',...     % This flag specify the type of I/O
				'IsFunction',true); % This flag specify if the .m file is a script or a function. 

% Test the MatlabWorker
TableOutput = evaluate(XmC,Xinp.getTable);
% The run MatlabWorker return a Matlab table containg only the results of the
% MatlabWorker
display(TableOutput)

%% Define Matlab Script
% In this MatlabWorker, a script is used instead of a function. matlab script can be
% either passed from a file (not shown here), or passed in a single-line
% string, as shown here. 
% When using a script, either the structure or the matrix input/output can
% be used. When structure I/O is used, the "Tinput" and "Toutput" must
% mandatorily used as names of the input and output variables respectively.
% On the other hand, when matrix I/O is used, the names "Minput" and
% "Moutput" must be used.

Sscript=['for i=1:length(Tinput),'...
    'Toutput(i).Out1   = Tinput(i).RV_2;'...
    'Toutput(i).Out2   = Tinput(i).RV_1;'...
    'end'];

XmD  = MatlabWorker('Description', 'Performance function', ...
                'Script',Sscript, ... % Define the script
                'OutputNames',{'Out1';'Out2'},... % This field is mandatory
                'InputNames',{'RV_1';'RV_2'},...    % This field is mandatory
                'Format','structure',...     % This flag specify the type of I/O
				'IsFunction',false); % This flag specify if the .m file is a script or a function. 

% Test the MatlabWorker
TableOutput = evaluate(XmD,Xinp.getTable);
% The run MatlabWorker return a Matlab table containg only the results of the
% MatlabWorker
display(TableOutput)
% All the three different interface should produce 


%% Third test - Use MonteCarlo simulation
%8.1.   Define Evaluator
Xev     = Evaluator('Solvers',XmD);
%8.2.   Define probmodel
Xmodel  = opencossan.common.Model('Input',Xinp,'Evaluator',Xev); 
%8.3.   Apply
opencossan.OpenCossan.cossanDisp('Test 3: 100 samples (20 batches) - MCS - MatlabWorker Matrix');
Xmc     = opencossan.simulations.MonteCarlo('Nsamples',100,'Nbatches',20);
Xo      = Xmc.apply(Xmodel);


%% CASE D
% Matlab tables are used here for Input/Output. 
%
% The Matlab function used is found in 'Files4MatlabWorker/ExampleMatlabWorkerMatrix.m'
XmDfun  = MatlabWorker('Description', 'Performance function', ...
                'FullFileName',fullfile(StutorialPath,'Files4MatlabWorker','ExampleMatlabWorkerTable.m'), ...
                'OutputNames',{'Out1';'Out2'},... % This field is mandatory
                'InputNames',{'RV_1';'RV_2'},...    % This field is mandatory
                'Format','table',...     % This flag specify the type of I/O
				'IsFunction',true); % This flag specify if the .m file is a script or a function. 

% Test the MatlabWorker
TableOutput = evaluate(XmDfun,Xinp.getTable);
% The run MatlabWorker return a Matlab table containg only the results of the
% MatlabWorker
display(TableOutput)


Sscript=['Out1   = TableInput.RV_2+TableInput.RV_1;'...
         'Out2   = TableInput.RV_1;'...
         'TableOutput=array2table([Out1 Out2],''VariableNames'',{''Out1'',''Out2''})'];

            % The Matlab function used is found in 'Files4MatlabWorker/ExampleMatlabWorkerMatrix.m'
XmDscript  = MatlabWorker('Description', 'Performance function', ...
                'Script',Sscript, ... % Define the script
                'OutputNames',{'Out1';'Out2'},... % This field is mandatory
                'InputNames',{'RV_1';'RV_2'},...    % This field is mandatory
                'Format','table',...     % This flag specify the type of I/O
				'IsFunction',false); % This flag specify if the .m file is a script or a function. 
            
% Test the MatlabWorker
TableOutput = evaluate(XmDscript,Xinp.getTable);
% The run MatlabWorker return a Matlab table containg only the results of the
% MatlabWorker
display(TableOutput)


%% Third test - Use MonteCarlo simulation
%8.1.   Define Evaluator
Xev     = Evaluator('Solvers',XmDfun);
%8.2.   Define probmodel
Xmodel  = opencossan.common.Model('Input',Xinp,'Evaluator',Xev); 
%8.3.   Apply
opencossan.OpenCossan.cossanDisp('Test 3: 100 samples (20 batches) - MCS - MIO Matrix');
Xmc     = opencossan.simulations.MonteCarlo('Nsamples',100,'Nbatches',20);
Xo      = Xmc.apply(Xmodel);


