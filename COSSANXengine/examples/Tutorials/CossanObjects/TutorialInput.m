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
%
%% TUTORIALINPUT
% This tutorial shows how to create and use an Input object.
% The Input object is used to collect all the defined input quanities used
% in an analysis, i.e., random variables, multivariate distributions,
% parameters, function of random variables, and stochastic processes.
% Additionally, an Input object will also store the generated samples of
% the random quantities (Random variables, RV sets and stochasti processes)
%
% See Also:  https://cossan.co.uk/wiki/index.php/@Input
% Author:~Pierre~Beaurepaire


%% Create additional object
% Now we create 4 different parameter objects that will be included in the
% Input object. Please refer to the documentation of the Parameter for more
% details
Xmat1   = Parameter('Sdescription','material 1 E','value',7E+7);
Xmat2   = Parameter('Sdescription','material 2 E','value',2E+7);
Xmat3   = Parameter('Sdescription','material 3 E','value',1E+4);
Xconfiguration  = Parameter('Sdescription','material configuration','Mvalue',unidrnd(3,16,16));

% Now we create RandomVariable and RandomVariableSet
x1  = RandomVariable('Sdistribution','normal','mean',2.763,'std',0.4);
x2  = RandomVariable('Sdistribution','normal','mean',1.25,'std',0.4);
Xrvs1 = RandomVariableSet('Cmembers',{'x1','x2'},'Xrv',[x1 x2]);

% Create a second RandomVariableSet
% Definition of Random Variables
x3  = RandomVariable('Sdistribution','uniform','lowerbound',0,'upperbound',10);
x4  = RandomVariable('Sdistribution','uniform','mean',5,'std',1);

Xrvs2   = RandomVariableSet('Cmembers',{'x3','x4'},'Xrv',[x3 x4]);

% Create RandomVariableSet with IID RandomVariable
Xrvs3 = RandomVariableSet('Xrv',x1,'Nrviid',10);
    
%% Create Functions
Xfun1   = Function('Sdescription','function #1', ...
    'Sexpression','<&x3&>+<&x4&>');
Xfun2   = Function('Sdescription','function #2', ...
    'Sexpression','<&Xmat3&>./<&x1&>');
Xfun3   = Function('Sdescription','function #2', ...
    'Sexpression','<&Xmat3&>+1');

%% Create an Input object that contains all the object already prepared
Xin=Input('Sdescription','My first Input'); % initialize Input object

% Add parameters to the input object
Xin = Xin.add('Sname','Xconfiguration','Xmember',Xconfiguration);
Xin = Xin.add('Xmember',Xmat1,'Sname','Xmat1');
Xin = Xin.add('Xmember',Xmat2,'Sname','Xmat2');
Xin = Xin.add('Xmember',Xmat3,'Sname','Xmat3');
% Add RandomVariable
Xin     = Xin.add('Xmember',Xrvs1,'Sname','Xrvs1');
Xin     = Xin.add('Xmember',Xrvs2,'Sname','Xrvs2');
Xin     = Xin.add('Xmember',Xrvs3,'Sname','Xrvs3');

% Add Functions
Xin = Xin.add('Xmember',Xfun1,'Sname','Xfun1');
Xin = Xin.add('Xmember',Xfun2,'Sname','Xfun2');
Xin = Xin.add('Xmember',Xfun3,'Sname','Xfun3');

%% Show summary of the Input object
display(Xin)

%% Generate samples from the Xinput object
Xin = Xin.sample; % Generate a single sample
display(Xin)

Xin = Xin.sample('Nsamples',20); % Generate 20 samples and replace the 
                                     % previous generated sample
display(Xin)

% Add additional samples to the previous sample                                     
Xin = Xin.sample('Nsamples',25,'Ladd',true);
display(Xin)

%% Using get and dependent field to retrieve information from Xinput
% get the list of the  RandomVariableSet
Cname=Xin.CnamesRandomVariableSet;
disp('Name of the RandomVariableSet')
display(Cname')
% get the list of the Parameter
Cname=Xin.CnamesParameter;
disp('Name of the Parameter')
display(Cname')
% get the list of Function
Cname=Xin.CnamesFunction;
disp('Name of the Function')
display(Cname')
% get the list of StochasticProcess
Cname=Xin.CnamesStochasticProcess;
disp('Name of the StochasticProcess')
display(Cname')
% get the list of all variables
Cname=Xin.Cnames;
disp('Name of the Variable present in the Input')
display(Cname')

%% Retrieve values from the Input object
% recompute the values of the function
Vfvalues=get(Xin,'Xfunctionvalue');
display(Vfvalues)

% The function returns a cell array
Cvalue=Xin.getValues('Sname','Xfun1');
display(Cvalue)

% retrive the values of the input (as a structure)
Tstruct=Xin.getStructure;
display(Tstruct)

% or as a matrix (rvs and functions only)
Msamples=Xin.getSampleMatrix;
display(Msamples);

% retrieve default values of the Xinput (i.e. mean values of the rvs)
get(Xin,'defaultvalues')

OpenCossan.cossanDisp('End of the Tutorial, bye bye! ')

