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

%% First Example

% Create parameter and random variable
par1 = opencossan.common.inputs.Parameter('value',2);
rv = opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);

input = opencossan.common.inputs.Input('members', {par1, rv}, 'names', ["par", "rv"]);

% Create Function object. This function returns the sum of the random variable plus the values of
% the paramter
fun = opencossan.common.inputs.Function('Description', 'function #1', 'Expression','<&rv&>+<&par&>');

%% Evaluate the Function

samples = input.sample('samples',3); % sample from the input
values = evaluate(fun, samples); % evaluate the function for the given samples
disp(values)

% Validate solution
assert(all(values == samples.rv + samples.par), 'OpenCossan:Tutorial','Incorrect results.');

%% Automatically evaluate Function during sampling
input = input.add('member', fun, 'name', "fun");

samples = input.sample('samples', 3);

% Validate solution
assert(all(samples.fun == samples.rv + samples.par), 'OpenCossan:Tutorial','Incorrect results.');


%% Second example
% This second example involves functions that make use of parameters that
% contain array of values

%% Create Input
% Create Parameter objects
par1 = opencossan.common.inputs.Parameter('value',2);
par2 = opencossan.common.inputs.Parameter('value',[1 2 3 4]);

% Create Function objects
fun1 = opencossan.common.inputs.Function('Description','Target function #1', ...
    'Expression','2 * <&par1&>');

% The function can access to a specific value of the parameter object or it
% can use the entire values of the parameter. Hence, the function returs
% (when evaluated) a vector that contains the same number of samples present
% in the input.

fun2 = opencossan.common.inputs.Function('Description','Target function #2', ...
    'Expression','2 * <&par2&>');

% Add objects to input
input = opencossan.common.inputs.Input('members', {par1, par2, fun1, fun2}, ...
    'names', ["par1", "par2", "fun1", "fun2"]);

samples = input.sample('samples', 3);
disp(samples);

%% Third example: Dependent function
% Create Function object that depends on other function.
fun3 = opencossan.common.inputs.Function('Description','function #3', ...
    'Expression','.2 .* <&fun1&>');

input = input.add('member', fun3, 'name', "fun3");
samples = input.sample('samples', 3);
disp(samples);


