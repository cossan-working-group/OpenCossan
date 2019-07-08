%% TUTORIALUSERDEFRANDOMVARIABLE
%
%   This tutorial shows how to create a UserDefRandomVariable object
%   A user defined random variable is a non-parameteric random variable
%   which can be created in three ways: 
%       -> By passing samples
%       -> By passing a pdf and support
%       -> By passing a cdf and support
%
% See Also: TutorialRandomVariable
%
% $Copyright~1993-2018,~COSSAN~Working~Group$
% $Author:~Edoardo Patelli$ 

%set random stream
OpenCossan.resetRandomNumberGenerator(31415)

%% providing realizations of the distribution
f1=figure;
nsamples=10000;
x = -2.9:0.1:2.9;
y = randn(nsamples,1);
n_elements = histc(y,x);
c_elements = cumsum(n_elements)/nsamples;
bar(gca(f1),x,c_elements,'BarWidth',1);
hold(gca(f1));
Xrv1=UserDefRandomVariable('Vdata',y);
% Plot CDF
plot(gca(f1),Xrv1.Vsupport,Xrv1.Vcdf,'r')

% Plot PDF
f2=figure;
plot(gca(f2),Xrv1.Vsupport,Xrv1.Vpdf,'r')

%% providing points at which the cdf value is known

x=-5:.001:5;
Xrv2=UserDefRandomVariable('Vcdf',normcdf(x),'Vdata',x);
plot(gca(f2),Xrv2.Vsupport,Xrv2.Vpdf,'r')

 %% providing points at which the pdf value is known
x=-5:.001:5;
Xrv3=UserDefRandomVariable('Vpdf',normpdf(x),'Vdata',x);
plot(gca(f2),Xrv3.Vsupport,Xrv3.Vpdf,'r')


%% cdfas an input
Xfun = Function('Sexpression','normcdf(<&xsb&>)');
x=-5:.001:5;
Xrv4=UserDefRandomVariable('Xcdf',Xfun','Vdata',x,'Vtails',[1e-3, 1-1e-3]);



%% evalpdf
% evaluates the pdf of the random variable at input points
% matrix of values
Vpdf01 = evalpdf(Xrv1,randn(3,3));

% array of values
Vpdf02 = evalpdf(Xrv1,0:.2:4);


%% different mappings


Vout1 = physical2cdf(Xrv4, [0 .1;.3 .2]); %physical space to the cdf space

Vout2 = RandomVariable.cdf2stdnorm(0:.1:1);%cdf space to the stdnorm space

Vout3 = cdf2physical(Xrv1, [0 0.1 0.5]);%cdf space to the physica space

Vout4 = RandomVariable.stdnorm2cdf(-3:3);%stdnorm space to the cdf space

Vout5 = map2stdnorm(Xrv1,[0.1 1 2]);%physical space to the stdnorm space



%% sample
% generate one sample from the random variable
s=sample(Xrv1);

% extract 5 samples from Xrv1
Vs1=sample(Xrv1,'Nsamples', 5);

% extract 100 samples from Xrv1, in a 2x3 matrix
Vs2=sample(Xrv1,'Vsamples', [2 3]);



%% adding UserDefRandomVariable to RVset
XrvRef = RandomVariable('Sdistribution','normal','mean',0,'std',1); %Gaussian random variable, to have mixed RVs in a RVset

Xrs = RandomVariableSet('Cmembers',{'Xrv1','Xrv2','Xrv3','XrvRef'});

%% reference solution
% chi-square test to see if samples are indeed accoring to the target
% distribution
x = sample(Xrv1,'Nsamples', 500);
h = chi2gof(x);
if h==0
    OpenCossan.cossanDisp('The 1st random variable passed the chi-2 test')
end

x = sample(Xrv2,'Nsamples', 500);
h = chi2gof(x);
if h==0
    OpenCossan.cossanDisp('The 2nd random variable passed the chi-2 test')
end

x = sample(Xrv3,'Nsamples', 500);
h = chi2gof(x);
if h==0
    OpenCossan.cossanDisp('The 3rd random variable passed the chi-2 test')
end

x = sample(Xrv4,'Nsamples', 500);
h = chi2gof(x);
if h==0
    OpenCossan.cossanDisp('The 4th random variable passed the chi-2 test')
end

%% Close figures
close(f1)
close(f2)
