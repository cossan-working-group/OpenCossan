%% TutorialSamples
% This tutorials explains how to use the class Samples. 
% Samples class is used to store realisations from Input object. 

%% Create Input
% Define RandomVariables
Xrv1    = RandomVariable('Sdistribution','exponential','par1',1);
Xrv2    = RandomVariable('Sdistribution','normal','mean',3,'std',1);
Xrv3    = RandomVariable('Sdistribution','lognormal','mean',3,'std',1);
Xrv4    = RandomVariable('Sdistribution','lognormal','mean',3,'std',1);
%Create random variable set
Mcorr   = [1.0,0.5,0.2;...
    0.5,1.0,0.1;...
    0.2,0.1,1.0];
Xrvs1   = RandomVariableSet('Cmembers',{'Xrv1','Xrv2','Xrv3'},...
    'Mcorrelation',Mcorr);
Xrvs2   = RandomVariableSet('Cmembers',{'Xrv4'});
%   Create input object
Xin     = Input('Xrandomvariableset',Xrvs1);
Xin2     = Xin.add('Xmember',Xrvs2);

%% Generate samples
newStream = RandStream('mt19937ar','Seed',0);
RandStream.setGlobalStream(newStream);

% Generate samples
Xin     = Xin.sample('Nsamples',1e3);
% Display samples
display(Xin.Xsamples)

% Extract samples - matrix
MX      = getSampleMatrix (Xin);
MX=Xin.Xsamples.MsamplesPhysicalSpace;
MU=Xin.Xsamples.MsamplesStandardNormalSpace;

Xin2 = Xin2.sample('Nsamples',10);

%4.4.   Prepare Structures
Crvnames    = Xin.CnamesRandomVariable;
for i=1:size(MX,1),...
    for j=1:length(Crvnames),...
        TMX(i,1).(Crvnames{j})  = MX(i,j);...
        TMU(i,1).(Crvnames{j})  = MU(i,j);...
    end, ...
end %#ok<SAGROW>


%% Construct object Samples
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

%% Samples object with Dataseries
Xds1=Dataseries('Mcoord',1:10,'Mdata',rand(4,10),'Sindexname','index','Sindexunit','myUnits');
Xds2=Dataseries('Mcoord',1:10,'Mdata',rand(4,10),'Sindexname','index','Sindexunit','myUnits');

% Define names
Xsamp7  = Samples('Xdataseries',[Xds1 Xds2],'CnamesStochasticProcess',{'SP1' 'SP2'});
display(Xsamp7)

% Add samples to Input object
Xinput=Input('Xsamples',Xsamp7,'CXmembers',{StochasticProcess StochasticProcess},'CSmembers',{'SP1' 'SP2'});
display(Xinput)
