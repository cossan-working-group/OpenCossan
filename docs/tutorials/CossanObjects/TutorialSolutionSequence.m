%% Tutorial for the SolutionSequence object 
% This turorial show how to define and use a SolutionSequence Object
%
% The solution sequence allows the user to create customized solution sequences
% In order to do that, a script containing the solution (i.e. sequence of Matlab
% command) must be defined.
%
% In this tutorial a very simple SolutionSequence object is created. It perform
% a deterministic analysis of a model, plot a figure and return a SimulationData
% obect. The script can contains
% It is obvious that a more complex solution sequence can be define.
%
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@SolutionSequence
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 
close all
clear
clc;
% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(56236)

import workers.*
import common.inputs.*
%% Define required objects

% Construct a Mio object
Xm=opencossan.workers.Mio( 'description', 'This is our Model', ...
    'Script','for j=1:length(Tinput), Toutput(j).out=-Tinput(j).RV1+Tinput(j).RV2; end', ...
    'Format','structure',...
    'Outputnames',{'out'},...
    'Inputnames',{'RV1','RV2'}); % This flag specify if the .m file is a script or a function.
            
% Construct the Evaluator
Xeval1 = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','first Evaluator');

% Define Random Variables
RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);  %#ok<SNASGU>
RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1); %#ok<SNASGU>
% Define the Random Variable Set
Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'},'members',[RV1;RV2]); 
% Define input object
Xin = opencossan.common.inputs.Input('description','Input satellite_inp');
Xin = add(Xin,'member',Xrvs1,'name','Xrvs1');
% Add samples to the input object
Xin = sample(Xin,'Nsamples',10);

% Construct the Model
Xmdl=opencossan.common.Model('Xinput',Xin,'Xevaluator',Xeval1,'Sdescription','The Model');

%% Define the SolutionSequence object
% User Defined Analysis (SolutionSequence script)
% This script allows to create customized solution 
% The script is evaluated in the matlab base workspace and it can access to
% the properties and methods of the Object that the user defined analyis belong to. 
%
% The script has to follow specific input output convenctions.
% It can access to all the objects defined in the SolutionSequence field
% Cobjectsnames.
% It can assess to inputs values using the variable "varargin" 
% Returns the objects using the cell array COSSANoutput. Please remember to
% specify the field CprovidedObjectTypes otherwise it is expected that the solution sequence 
% returns a numberical values 
% 
%  In this examples we do not access to the values defined in the input but we
%  only use object and the script is the following:
%

Sscript='COSSANoutput{1}=Xmdl.deterministicAnalysis;scatter(varargin{1},varargin{2});hold on;';


% Include All
Xss=opencossan.workers.SolutionSequence('Sdescription', 'User defined solution sequence', ...
    'Sscript',Sscript, ...
    'Coutputnames',{'Xout'},...
    'Cinputnames',{'RV1' 'RV2'},...
    'Cobjectsnames',{'Xmdl','Xin'},...
    'CprovidedObjectTypes',{'common.outputs.SimulationData'},... % Specify the returned object type
    'CXobjects',{Xmdl,Xin}); % This flag specify if the .m file is a script or a function.

% Show object
display(Xss)

%% Use the object
% Since the Input object contains 10 samples the script included in the
% SolutionSequence object is evaluated 10 times. The values of the variables
% included in varargin change accordigly to the current evaluated sample
XsimData=Xss.apply(Xin);

%% Validate Tutorial
% Check solutions
% assert(XsimData.Nsamples==10,'openCOSSAN:Tutorial','wrong results')
assert(height(XsimData)==10,'openCOSSAN:Tutorial','wrong results')
% MX=XsimData.getValues('Cnames',{'out'});
MX=XsimData.Xout;

assert(max(abs(MX))<1e-10,'openCOSSAN:Tutorial','wrong results')
 

%% Use SolutionSequence to define a custom analysis
% The method userDefinedAnalysis of the object class SolutionSequence can be
% used to define a custom analysis.
% The SolutionSequence requires only the fields: 
% * CXobject 
% * Cobjectsname
% * CprovidedObjectTypes
% * Coutputnames


Sscript2=strcat('COSSANoutput{1}=Xmdl.deterministicAnalysis;', ... 
        'XlsFD = sensitivity.LocalSensitivityFiniteDifference(''Xtarget'',Xmdl);',...
        'COSSANoutput{2} = XlsFD.computeGradient;');

% Include All
Xss2=SolutionSequence('Sdescription', 'User defined solution sequence', ...
    'Sscript',Sscript2, ...
    'Coutputnames',{'Xout' 'Xgrad'},...
    'Cobjectsnames',{'Xmdl','Xin'},...
    'CprovidedObjectTypes',{'common.outputs.SimulationData' 'sensitivity.Gradient'},... % Specify the returned object type
    'CXobjects',{Xmdl,Xin}); % This flag specify if the .m file is a script or a function.

%% Use the object
% The object is used to perform the analysis in the following way. 
[Xout, Xgrad]=Xss2.userDefinedAnalysis;

% Show results
display(Xout)
display(Xgrad)
% The computed objects are assigned in the base workspace with the name defined
% by the field Coutputnames

disp('Tutorial terminated successfully')
