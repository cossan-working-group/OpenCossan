%% Tutorial: create a PerformanceFunction object
% Create a user defined performance function 
% A user defined PerformaceFunction can be defined passing a Function
% object to the constructor of the Performance Function 
%
% See Also: https://cossan.co.uk/wiki/index.php/@PerformanceFunction
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
% $Author: Edoardo-Patelli~and~Barbara-Goller$ 
clear
close all
clc;
%% Create a performance function manipulating variable of the
% SimulationData object

% Create a fake SimulationData object
TableTest=table(5,11,'VariableNames',{'A' 'B'})
Xout=opencossan.common.outputs.SimulationData('Table',TableTest);

% define performace function as variableA-variableB
Xpf=opencossan.reliability.PerformanceFunction('OutputName','Vg1','description','variableA-variableB', ...
                        'Demand','B','Capacity','A');

% Show summary of the PerformanceFunction
disp(Xpf)
                
% Evaluate the PerformanceFunction                    
TableOutput=Xpf.evaluate(TableTest);

%% Construct User Defined Performance Function
% A Mio object is used to define a PerformanceFunction
XpfM1=opencossan.reliability.PerformanceFunction('Script','Moutput=Minput(:,1)+Minput(:,2);', ...
      'InputNames',{'A','B'},...
      'OutputName',{'Vg'},'Format','matrix');
  
% Show summary of the PerformanceFunction
disp(XpfM1)   
               
% Evaluate the PerformanceFunction                    
TableOutput=XpfM1.evaluate(TableTest);

%% Using smooth indicator function
% This section shows an important feature of the object  "PerformanceFunction"
% that allows calculating the probability of failure using a smooth indicator
% function. 
%
%   The concept of smooth indicator function implies that the traditional
%   indicator function (which is a heaviside or step function) is replaced
%   by a smooth version. The smooth version is modeled using the CDF of a
%   Gaussian distribution. Details on the theoretical aspects of this
%   smooth indicator function can be found at:
%   
%   Taflanidis, A. and J. Beck: 2008, `An efficient framework for optimal 
%   robust stochastic system design using stochastic simulation'. Computer 
%   Methods in Applied Mechanics and Engineering, 198(1), 88-101.

% In order to use the smooth indicator function it is necessary to define the
% field stdDeviationIndicatorFunction in the PerformanceFunction

XpfSmooth     = opencossan.reliability.PerformanceFunction('OutputName','Vg',...
    'Capacity','Xthreshold',...  %indicate threshold to be used
    'Demand','out1',...    %indicate parameter modeling the demand
    'stdDeviationIndicatorFunction',0.05);  %this parameter is used to define the standard
    %deviation of the Gaussian CDF used to define the indicator function

disp(XpfSmooth)
