%% TUTORIALUSERDEFRANDOMVARIABLE
%
%   This tutorial shows how to create and use a UserDefRandomVariable object
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
close all
clear
clc;
%set random stream

opencossan.OpenCossan.resetRandomNumberGenerator(31415)

import opencossan.common.inputs.random.UserDefinedRandomVariable;
import opencossan.common.inputs.random.NormalRandomVariable;
import opencossan.common.inputs.random.RandomVariableSet;

%% providing realizations of the distribution
% Here we create same realizations and plot the corresponding PDF and CDF 

nsamples=10000;
x = -2.9:0.1:2.9;
y = randn(nsamples,1);

% Construct an UserDefinedRandomVariable starting from realizations 
Xrv1=UserDefinedRandomVariable('data',y);

% Plot CDF and
n_elements = histc(y,x);
c_elements = cumsum(n_elements)/nsamples;

% Plot CDF
f1=figure;bar(gca(f1),x,c_elements,'BarWidth',1);
hold(gca(f1));
plot(gca(f1),Xrv1.support,Xrv1.cdf,'r')

f2=figure;
plot(gca(f2),Xrv1.support,Xrv1.pdf,'r')

%% providing points at which the cdf (or PDF) value is known
% A UserDefinedRandomVariable can be constructed starting from the values
% of the CDF and their support points 

x=-5:.001:5;
Xrv2=UserDefinedRandomVariable('cdf',normcdf(x),'support',x);
% Plot PDF
plot(gca(f2),Xrv2.support,Xrv2.pdf,'r')
 % providing points at which the pdf value is known
x=-5:.001:5;
Xrv3=UserDefinedRandomVariable('pdf',normpdf(x),'support',x);
plot(gca(f2),Xrv3.support,Xrv3.pdf,'r')



%% evalpdf
% evaluates the pdf of the random variable at input points
% matrix of values
Vpdf01 = evalpdf(Xrv1,randn(3,3));

% array of values
Vpdf02 = evalpdf(Xrv1,0:.2:4);


%% different mappings

Vout1 = Xrv1.physical2cdf([0 .1;.3 .2]); %physical space to the cdf space

Vout2 = Xrv1.cdf2stdnorm(0:.1:1); %cdf space to the stdnorm space

Vout3 = Xrv1.cdf2physical([0 0.1 0.5]); %cdf space to the physical space

Vout4 = Xrv1.stdnorm2cdf(-3:3); %stdnorm space to the cdf space

Vout5 = Xrv1.map2stdnorm([0.1 1 2]);%physical space to the stdnorm space



%% sample
% generate one sample from the random variable
s=sample(Xrv1);

% extract 5 samples from Xrv1
Vs1=sample(Xrv1, 5);

% extract 100 samples from Xrv1, in a 10x10 matrix
Vs2=sample(Xrv1, [2 3]);



%% adding UserDefRandomVariable to RVset
%Gaussian random variable, to have mixed RVs in a RVset
XrvRef =    opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1); 

Xrs = opencossan.common.inputs.random.RandomVariableSet('members',[Xrv1; Xrv2; Xrv3; XrvRef],'names',{"Xrv1", "Xrv2", "Xrv3", "XrvRef"});
