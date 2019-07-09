%**************************************************************************
%
%   Tutorial mio
%   This tutorial show how to create a mIO object
%
%**************************************************************************
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics
% University of Innsbruck, Innsbruck, Austria, EU
% URL: http://cossan.cfd.liv.ac.uk
% =====================================================


%% Create random variables and randomvariable set
%   Create rv's
Nrv     = 7;
for i=1:Nrv
	evalin('base',['RV' num2str(i) '=RandomVariable(''Sdistribution'',''normal'', ''mean'',0,''std'',1);']);
end 
% Define a set of Random Variables
Xrvs1=RandomVariableSet('Cmembers',{'*all*'}); 

% Add a parameter
% The parameter is unnecessary here but it is used to test the behaviour of
% the Mio object.
Xpar=Parameter('value',[5 3]);

%% 3.   Define Input object
Xinp  = Input;
Xinp  = add(Xinp,Xrvs1);
Xinp  = add(Xinp,Xpar);

%% 5.   Generate samples of the rv's
Xinp  = Xinp.sample('Nsamples',10);

%% 4.   Define MIO 
% There are different ways to create a Mio object.
% The Mio can be a Matlab function or a Matlab script

%% Define Matlab Functions
% The input and Output can be passed as:
% A) Matlab structures
% B) Matlab arrays (each array correspond to a variable)
% C) single array (each column of the array correspond to a variable)

%% CASE A

Xm  = Mio('Sdescription', 'Performance function', ...
                'Spath','./', ...
                'Sfile','ExampleMioStructure', ...
                'Liostructure',true,...     % This flag specify the type of I/O
                'Liomatrix',false, ...  % This flag specify the type of I/O
                'Coutputnames',{'Out1';'Out2'},... % This field is mandatory
                'Cinputnames',{'RV1';'RV2'},...          % This field is mandatory
				'Lfunction',true); % This flag specify if the .m file is a script or a function. 

% Test the Mio function 
XoutA = run(Xm,Xinp);
% The run mio return a SimulationData containg only the results of the
% Mio
display(XoutA)

            

%%    First test - Use MonteCarlo simulation
%  Define Evaluator
Xev     = Evaluator('Xmio',Xm);
%  Define probmodel
Xmodel  = Model('XInput',Xinp,'XEvaluator',Xev); 
%  Apply
OpenCossan.cossanDisp('Test 1: 100 samples (20 batches) - MCS - MIO I/O Structures');
Xmc     = MonteCarlo('Nsamples',100,'Nbatches',20);
Xo      = Xmc.apply(Xmodel);

% The SimulationOuput Xo contains now also the realization of the random
% variables the values of parameters and functions if defined in the Input
% object
display(Xo)

%% CASE B
Xm  = Mio('Sdescription', 'Performance function', ...
                'Spath','./', ...
                'Sfile','ExampleMioFunction', ...
                'Coutputnames',{'Out1' 'Out2'},... % This field is mandatory
                'Cinputnames',{'RV1' 'RV2' 'Xpar'},...    % This field is mandatory
                'Liostructure',false,...     % This flag specify the type of I/O
                'Liomatrix',false, ...  % This flag specify the type of I/O
				'Lfunction',true); % This flag specify if the .m file is a script or a function. 

% Test the Mio function 
XoutB = run(Xm,Xinp);

    
%%  Second - Use MonteCarlo simulation
%   Define Evaluator
Xev     = Evaluator('Xmio',Xm);
%  Define probmodel
Xmodel  = Model('XInput',Xinp,'XEvaluator',Xev); 
%   Apply
OpenCossan.cossanDisp('Test 2: 100 samples (20 batches) - MCS - MIO Function');
Xmc     = MonteCarlo('Nsamples',100,'Nbatches',20);
Xo      = Xmc.apply(Xmodel);

%% CASE C
Xm  = Mio('Sdescription', 'Performance function', ...
                'Spath','./', ...
                'Sfile','ExampleMioMatrix', ...
                'Coutputnames',{'Out1';'Out2'},... % This field is mandatory
                'Cinputnames',{'RV1';'RV2'},...    % This field is mandatory
                'Liostructure',false,...     % This flag specify the type of I/O
                'Liomatrix',true, ...  % This flag specify the type of I/O
				'Lfunction',true); % This flag specify if the .m file is a script or a function. 

% Test the Mio function 
XoutC = run(Xm,Xinp);
display(XoutC)

%% CASE D
% Define Mio as a script.

Sscript='for i=1:length(Tinput), Toutput(i).Out1   = Tinput(i).RV2; Toutput(i).Out2   = Tinput(i).RV1; end';

XmD  = Mio('Sdescription', 'Performance function', ...
                'Sscript',Sscript, ... % Define the script
                'Coutputnames',{'Out1';'Out2'},... % This field is mandatory
                'Cinputnames',{'RV1';'RV2'},...    % This field is mandatory
                'Liostructure',true,...     % This flag specify the type of I/O
                'Liomatrix',false, ...  % This flag specify the type of I/O
				'Lfunction',false); % This flag specify if the .m file is a script or a function. 

% Test the Mio function 
XoutD = run(XmD,Xinp);
display(XoutD)
% All the three different interface should produce 


%% Third test - Use MonteCarlo simulation
%8.1.   Define Evaluator
Xev     = Evaluator('Xmio',Xm);
%8.2.   Define probmodel
Xmodel  = Model('XInput',Xinp,'XEvaluator',Xev); 
%8.3.   Apply
OpenCossan.cossanDisp('Test 3: 100 samples (20 batches) - MCS - MIO Matrix');
Xmc     = MonteCarlo('Nsamples',100,'Nbatches',20);
Xo      = Xmc.apply(Xmodel);

