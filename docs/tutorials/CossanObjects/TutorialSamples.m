%% TUTORIAL SAMPLES OBJECT
% This tutorial shows the basic usage of the Samples class.
%
% See Also: http://cossan.co.uk/wiki/index.php/@Samples
%
% $Copyright~1993-2016,~COSSAN~Working~Group,~University~of~Liverpool,~Austria$
% $Author: Edoardo-Patelli$ 
close all
clear
clc;

import opencossan.OpenCossan
import opencossan.common.Samples
import opencossan.common.inputs.*
% Reset Random number generator
OpenCossan.resetRandomNumberGenerator(51125)

%% Overview
% The Samples class is used to store realization of Random Variables and
% Design Variables (i.e. Design of Exeriment). 

%% Preparation of data 
% Create random variables
Xrv1    = opencossan.common.inputs.random.ExponentialRandomVariable('lambda',1);
Xrv2    = opencossan.common.inputs.random.NormalRandomVariable('mean',3,'std',1);
Xrv3    = opencossan.common.inputs.random.LognormalRandomVariable('mu',3,'sigma',0.1);
Xrv4    = opencossan.common.inputs.random.LognormalRandomVariable('mu',3,'sigma',0.1);
% Create random variable set
Mcorr   = [1.0,0.5;0.5,1.0];
Xrvs1   = opencossan.common.inputs.random.RandomVariableSet('names',{'Xrv1','Xrv2'}, ... 
    'members',[Xrv1; Xrv2],'Correlation',Mcorr);
Xrvs2   = opencossan.common.inputs.random.RandomVariableSet('names',{'Xrv3', 'Xrv4'}, 'members',[Xrv3; Xrv4]);

%% 3.   Create input object
Xin     = Input;
Xin     = add(Xin,'Name','Xrvs1','Member',Xrvs1);

Xin2     = Input;
Xin2     = add(Xin2,'Name','Xrvs1','Member',Xrvs1);
Xin2     = add(Xin2,'Name','Xrvs2','Member',Xrvs2);
%% 4.   Generate samples
newStream = RandStream('mt19937ar','Seed',0);
RandStream.setGlobalStream(newStream);

%% Use Samples within the Input Object 
% The Samples object is created automatically when the method sample@Input
% is involved. The Samples object is stored into the Input Object in the
% field Xsamples.

Xin     = Xin.sample('Nsamples',1e3);

% The Xin object contains the Samples object 
% Extract samples - matrix
MX      = getSampleMatrix (Xin);

MX=Xin.Samples.MsamplesPhysicalSpace;
MU=Xin.Samples.MsamplesStandardNormalSpace;

Xin2 = Xin2.sample('Nsamples',10);

%4.4.   Prepare Structures
Crvnames    = Xin.RandomVariableNames;
for i=1:size(MX,1),...
    for j=1:length(Crvnames),...
        TMX(i,1).(Crvnames{j})  = MX(i,j);...
        TMU(i,1).(Crvnames{j})  = MU(i,j);...
    end, ...
end %#ok<SAGROW>


%% 5.   Construct object Samples
% There are many different approaches for constructing an object of the 
% class Samples. 8 of these approaches are shown below. It should be noted
% that other combinations aside these 8 approaches are also valid
%5.1.   First approach - pass Input object and matrix of samples in physical space
Xsamp1  = Samples('Xinput',Xin,'MsamplesPhysicalSpace',MX);
display(Xsamp1)
%5.2.   Second approach - pass Input object and matrix of samples in standard normal space
Xsamp2  = Samples('Xinput',Xin,'MsamplesStandardNormalSpace',MU);
display(Xsamp2)
%5.3.   Third approach - pass Input object and structure of samples in physical space
Xsamp3  = Samples('Xinput',Xin,'TsamplesPhysicalSpace',TMX);
display(Xsamp3)
%5.4.   Fourth approach - pass Input object and structure of samples in standard normal space
Xsamp4  = Samples('Xinput',Xin,'TsamplesStandardNormalSpace',TMU);
display(Xsamp4)
%5.5.   Fifth approach - pass RandomVariableSet object and matrix of samples in physical space
Xsamp5  = Samples('Xrvset',Xrvs1,'MsamplesPhysicalSpace',MX);
display(Xsamp5)
%5.6.   Create samples from the random variable set
Xsamp6  = Xrvs1.sample(10);
display(Xsamp6)

%% 6. Samples object with Dataseries
Xds1=Dataseries('Mcoord',1:10,'Mdata',rand(4,10),'Sindexname','index','Sindexunit','myUnits');
Xds2=Dataseries('Mcoord',1:10,'Mdata',rand(4,10),'Sindexname','index','Sindexunit','myUnits');

% No names defined
Xsamp7  = Samples('Xdataseries',[Xds1 Xds2]);

% No names defined
Xsamp7  = Samples('Xdataseries',[Xds1 Xds2],'CnamesStochasticProcess',{'SP1' 'SP2'});
display(Xsamp7)

% Add samples to Input object
% This should return an error since the variable names do not match
Xinput=Input('Xsamples',Xsamp7,'CXmembers',{StochasticProcess StochasticProcess},'CSmembers',{'Stocaz' 'Stocaz'});



