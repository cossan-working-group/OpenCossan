%% TUTORIALRANDOMVARIABLE
% This tutorial shows the how to use and create a random variable object
%
% See Also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@RandomVariable
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Pierre~Beaurepaire$ 
clear
close all
clc;
%% Constructor
% general aspect:
% distributions can be defined using the moments, parameters or realizations
% of the distribution
Xrv0    = opencossan.common.inputs.random.NormalRandomVariable('description','Normal Distribution',...
            'mean',10,'std',2);     
        
% Show details of Xrv0        
display(Xrv0)     

% Show attributes of the RandomVariable object
% CoV of the RandomVariable
disp(Xrv0.CoV) 
 % mean of the RandomVariable
disp(Xrv0.Mean)
% standard deviation of the RandomVariable
disp(Xrv0.Std)
% cell array of parameters  of the RandomVariable
disp(Xrv0.Bounds)
% lower Bound of the RandomVariable
... disp(Xrv0.lowerBound) 
% upper Bound of the RandomVariable
... disp(Xrv0.upperBound)
% distribution type of the RandomVariable
disp(Xrv0.Description) 

f1=figure;
%% Exponential Distribution
Xrv1    = opencossan.common.inputs.random.ExponentialRandomVariable('description','Exponential Distribution',...                                            % distribution name
            'Lambda',1);
% Show details of Xrv1        
display(Xrv1)    
MX=Xrv1.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv1.Description)

%% Gamma Distribution       
Xrv2 = opencossan.common.inputs.random.GammaRandomVariable('Description','Gamma Distribution','K',5,'Theta',4);
% Show details of      
display(Xrv2) 
% Generate and show realization
MX=Xrv2.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv2.Description)

%% normal distribitions
Xrv3    = opencossan.common.inputs.random.NormalRandomVariable('description','normal distribition',...
            'mean',10,'std',2);   
 
% Show details        
display(Xrv3) 
% Generate and show realization
MX=Xrv3.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv3.Description)

%% Lognormal
Xrv4    = opencossan.common.inputs.random.LognormalRandomVariable('description','lognormal distribition', 'mu',15,'sigma',0.5); 
% Show details of Xrv5       
display(Xrv4) 

% Generate and show realization
MX=Xrv4.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv4.Description)

%% Rayleigh
Xrv5    = opencossan.common.inputs.random.RayleighRandomVariable('description','rayleigh', 'sigma', 5); 
% Show details of the random variable       
display(Xrv5) 
% Generate and show realization
MX=Xrv5.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv5.Description)

%% SMALL-I
Xrv6    = opencossan.common.inputs.random.SmallIRandomVariable('description','small-i', 'mean',1,'std',2);
% Show details of the random variable       
display(Xrv6) 
% Generate and show realization
MX=Xrv6.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv6.Description)

%% LARGE-I
Xrv7    = opencossan.common.inputs.random.LargeIRandomVariable('description','large-i', 'mean',1,'std',2);
% Show details of the random variable       
display(Xrv7) 
% Generate and show realization
MX=Xrv7.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv7.Description)

%% CHI
Xrv8    = opencossan.common.inputs.random.ChiRandomVariable('description','Chi Distribution', 'nu',5);
% Show details of the random variable       
display(Xrv8) 
% Generate and show realization
MX=Xrv8.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv8.Description)

%% WEIBULL
Xrv9 = opencossan.common.inputs.random.WeibullRandomVariable('description','weibull','a',4,'b',6);
% Show details of the random variable       
display(Xrv9)
% Generate and show realization
MX=Xrv9.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv9.Description)

%% BETA
Xrv10    = opencossan.common.inputs.random.BetaRandomVariable('description','BETA distribition','beta',9,'alpha',4);
% Show details of the random variable       
display(Xrv10)
% Generate and show realization
MX=Xrv10.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv10.Description)

%% GAMMA
Xrv11    = opencossan.common.inputs.random.GammaRandomVariable('description','gamma', 'k',1,'theta',2); 
% Show details of the random variable       
display(Xrv11) 
% Generate and show realization
MX=Xrv11.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv11.Description)

%% F-distribution
Xrv12    = opencossan.common.inputs.random.FisherSnedecorRandomVariable('description','FisherSnedecorRandomVariable','p1',5,'p2',20);
% Show details of the random variable       
display(Xrv12) 
% Generate and show realization
MX=Xrv12.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv12.Description)

%% Student's distribution
Xrv13    = opencossan.common.inputs.random.StudentRandomVariable('description','Students', 'nu', 10); 
% Show details of the random variable       
display(Xrv13) 
% Generate and show realization
MX=Xrv13.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv13.Description)

%% LOGISTIC
Xrv14    = opencossan.common.inputs.random.LogisticRandomVariable('description','logistic', 'mu',1,'s',2); 
% Show details of the random variable       
display(Xrv14) 
% Generate and show realization
MX=Xrv14.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv14.Description)

%% GENERALIZED PARETO
Xrv15   = opencossan.common.inputs.random.GeneralizedParetoRandomVariable('description','GENERALIZED PARETO','k',0.2,'sigma',5,'theta',12);

% Show details of the random variable       
display(Xrv15) 
% Generate and show realization
MX=Xrv15.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv15.Description)

%% UNIFORM
Xrv16    = opencossan.common.inputs.random.UniformRandomVariable('description','uniform','bounds',[0,1]);

% Show details of the random variable       
display(Xrv16) 
% Generate and show realization
MX=Xrv16.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv16.Description)


%% discrete uniform distributions
Xrv17  =opencossan.common.inputs.random.UniformDiscreteRandomVariable('description','unid','bounds',[0,1]);

% Show details of the random variable       
display(Xrv17) 
% Generate and show realization
MX=Xrv17.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv17.Description)

%% Poisson distribution
Xrv18  =opencossan.common.inputs.random.PoissonRandomVariable('description','poisson','lambda',12);
% Show details of the random variable       
display(Xrv18) 
% Generate and show realization
MX=Xrv18.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv18.Description)

%% Binomial distribution
Xrv19  =opencossan.common.inputs.random.BinomialRandomVariable('description','binomial','p',0.4,'n',6);
% Show details of the random variable       
display(Xrv19) 
% Generate and show realization
MX=Xrv19.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv19.Description)

%% Geometric distribution
Xrv20  =opencossan.common.inputs.random.GeometricRandomVariable('description','geometric','lambda',.3);
% Show details of the random variable       
display(Xrv20) 
% Generate and show realization
MX=Xrv20.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv20.Description)

%% Hypergeometric
Xrv21  =opencossan.common.inputs.random.HypergeometricRandomVariable('description','hypergeometric','k',100,'m',300,'n',80);
% Show details of the random variable       
display(Xrv21) 
% Generate and show realization
MX=Xrv21.sample(1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv21.Description)



%% evalpdf
% evaluates the pdf of the random variable at input points
% matrix of values
Vpdf01 = evalpdf(Xrv1,randn(3,3));

% array of values
Vpdf02 = evalpdf(Xrv1,[0:.2:4]);

%% sample

% generate one sample from the random variable
sample(Xrv1)

% extract 5 samples from Xrv1
sample(Xrv1, 5)

% extract 100 samples from Xrv1, in a 10x10 matrix
sample(Xrv1,[10 10])

%% different mappings
%physical space to the cdf space
Vout1 = physical2cdf(Xrv4, [0 .1;.3 .2]); 
%cdf space to the stdnorm space
Vout2 = opencossan.common.inputs.random.RandomVariable.cdf2stdnorm(0:.1:1);
%cdf space to the physica space
Vout3 = cdf2physical(Xrv1, [0 0.1 0.5]);
%stdnorm space to the cdf space
Vout4 = opencossan.common.inputs.random.RandomVariable.stdnorm2cdf(-3:3);
%physical space to the stdnorm space
Vout5 = map2stdnorm(Xrv1,[0.1 1 2]);

%% transform a random variable into a DesignVariable
Xdv = Xrv1.transform2designVariable;
display(Xdv)

%% Close figure
close(f1)
