%% Tutorial for FUNCTION object
%   This tutorial shows the basics on how to define an object of the class
%   Function and how to evaluate it
%
%
%
% See Also:  https://cossan.co.uk/wiki/index.php/Function
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

% Author: Matteo Broggi

clear
close all
clc;
import opencossan.common.inputs.*

%% First Example

% Create Parameter object
Xpar1   = Parameter('value',2);

% Create Random Variable and Random Variable Set objects
Xrv1    = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
Xrvs1   = opencossan.common.inputs.random.RandomVariableSet('names',{'Xrv1'},'members',[Xrv1]);

%% Create Function object
% This function returns the sum of the random variable 1 plus the values of
% the paramter
Xfun1   = Function('Description','function #1', ...
    'Expression','<&Xrv1&>+<&Xpar1&>');

Xin = opencossan.common.inputs.Input();
Xin     = add(Xin,'Member',Xrvs1,'Name','Xrvs1');
Xin     = add(Xin,'Member',Xpar1,'Name','Xpar1');
Xin     = add(Xin,'Member',Xfun1,'Name','Xfun1');

%% Evaluate the Function
% the Input object must be sampled before function evaluation
Xin     = sample(Xin,'Nsamples',3);

%% Evaluate Function
values  =  evaluate(Xfun1,Xin);
disp(values)

%% Validate Solutions
VvaluesRV=Xin.getValues('VariableName','Xrv1');
Vreference=VvaluesRV+2;
assert(max(Vreference-values)<1e-10,'COSSAN:Tutorial','wrong results')

%%  getMembers
%retrieve the names of all objects that are associated with the Function
%object and their type

[Cmembers Ctypes] = getMembers(Xfun1);
disp(Cmembers)
disp(Ctypes)

%% Second example
% This second example involves functions that make use of parameters that
% contain array of values
%
%% Create Input
Xin     = Input;

% Create Parameter objects
Xpar1   = Parameter('value',2);
Xpar2   = Parameter('value',[1 2 3 4]);

% Create Function objects
Xfunction1 = Function('Description','Target function #1', ...
    'Expression','2 * <&Xpar1&>');

% The function can access to a specific value of the parameter object or it
% can use the entire values of the parameter. Hence, the function returs
% (when evaluated) a vector that contains the same number of samples present
% in the input.

Xfunction2 = Function('Description','Target function #2', ...
    'Expression','2 * <&Xpar2&>');

% Add objects to input
Xin     = add(Xin,'Member',Xpar1,'Name','Xpar1');
Xin     = add(Xin,'Member',Xpar2,'Name','Xpar2');
Xin     = add(Xin,'Member',Xfunction1,'Name','Xfunction1');
Xin     = add(Xin,'Member',Xfunction2,'Name','Xfunction2');

values1  =  Xfunction1.evaluate(Xin);
values2  =  Xfunction2.evaluate(Xin);

%% Third example: Dependent function
% Create Function object that depends on other function.
Xfunction3   = Function('Description','function #3', ...
    'Expression','.2 .* <&Xfunction1&>');

% Evaluate the function
values3  =  Xfunction3.evaluate(Xin);
disp(values3)

%% Forth example: Multidimensional Function object
% The function can also access a specific value of a multidimensional function.
Xfunction4   = Function('Description','function #2', ...
    'Expression','.5 .* <&Xfunction2&>(3)');

% Evaluate the function
values4  =  Xfunction4.evaluate(Xin);
disp(values4)

%% Fifth exmple
%   Create Input
Xin     = Input;

%   Create Parameter object
Xpar1   = Parameter('Value',[2;3]);
Xpar2   = Parameter('Value',[1 2 ; 3 4]);
Xin     = add(Xin,'Member',Xpar1,'Name','Xpar1');
Xin     = add(Xin,'Member',Xpar2,'Name','Xpar2');

%Create Function object
Xfun1   = Function('Description','function #1', ...
    'Expression','2 .* <&Xpar1&>(2)');

% Input object needn't to be sampled before function evaluation because it
% does not contains random variables
values1  =  evaluate(Xfun1,Xin);
% show the results
disp(values1)


%%  Function operation elements of multidimensional Parameters
Xfun3   = Function('Description','function #3', ...
    'Expression','<&Xpar2&>(2) .*<&Xpar1&>(1)');
values3  =  evaluate(Xfun3,Xin);

% show the results
disp(values3)


