%% Tutorial for the Model object 
% 
%
% The Model object defines the user defined model compoused by an Input
% object and an Evaluator object.
%
% See Also: https://cossan.co.uk/wiki/index.php/Model
%
%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2019 COSSAN WORKING GROUP

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

% $Author:~Edoardo~Patelli$ 
clear
close all
clc;

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(56236)

%% Define Required object
%  user define model based on a Matlab function 
%
% Construct a Mio object
Xm=opencossan.workers.Mio( 'description', 'This is our Model', ...
    'Script','for j=1:length(Tinput), Toutput(j).out=-Tinput(j).RV1+Tinput(j).RV2; end', ... 
    'format','structure',...
    'OutputNames',{'out'},...
    'InputNames',{'RV1','RV2'},...
    'IsFunction',false); % This flag specify if the .m file is a script or a function.
            
%% Construct the Evaluator
% First mode (The object are passed by reference) 
Xeval1 = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','fist Evaluator');

% In order to be able to construct our Model an Input object must be
% defined

%% Define an Input
% Define RVs
RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',1,'std',1);  %#ok<SNASGU>
RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',3,'std',1);  %#ok<SNASGU>
% Define the RVset
Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'}, 'members', [RV1; RV2]); 
% Define Xinput
Xin = opencossan.common.inputs.Input('description','Input satellite_inp');
Xin = add(Xin,'member',Xrvs1,'name','Xrvs1');
Xin = sample(Xin,'Nsamples',10);

%%  Construct the Model
Xmdl=opencossan.common.Model('Input',Xin,'evaluator',Xeval1); %#ok<NASGU>
% or
Xmdl=opencossan.common.Model('input',Xin,'evaluator',Xeval1,'description','The Model');

% Show Model details
display(Xmdl)

%% Perform Analysis
% Perform a deterministic Analysis
Xo1=Xmdl.deterministicAnalysis;

% The output contains only 1 values
display(Xo1)

% Perform simulation (using the samples present in the Input 
Xo2=Xmdl.apply(Xin);

% The output contains now 10 values (The samples defined in the input)
display(Xo2)

%% Validate Tutorial
MX=Xo2.getValues('Cnames',Xo2.Cnames);
     
% % Check solution
assert(all(MX(:,3)-MX(:,2)==MX(:,1)),'openCOSSAN:Tutorial','wrong results');

disp('Tutorial terminated successfully')

