%% TUTORIALRANDOMVARIABLE
% This tutorial shows the how to use and create a random variable object
%
% See Also:  https://cossan.co.uk/wiki/index.php/@RandomVariable
%
% $Copyright~1993-2018,~COSSAN~Working~Group$
% $Author:~Pierre~Beaurepaire$ 
% $Author:~Edoardo~Patelli$ 

%% Constructor
% general aspect:
% distributions can be defined using the moments, parameters or realizations
% of the distribution
Xrv1    = RandomVariable('Sdescription','rv 1','Sdistribution','normal',...
            'mean',10,'std',2);     
        
% Show details of Xrv1        
display(Xrv1)     

% Show attributes of the RandomVariable object
% CoV of the RandomVariable
disp(Xrv1.CoV) 
 % mean of the RandomVariable
disp(Xrv1.mean)
% standard deviation of the RandomVariable
disp(Xrv1.std)
% cell array of parameters  of the RandomVariable
disp(Xrv1.Cpar)
% lower Bound of the RandomVariable
disp(Xrv1.lowerBound) 
% upper Bound of the RandomVariable
disp(Xrv1.upperBound)
% distribution type of the RandomVariable
disp(Xrv1.Sdistribution) 

f1=figure;
%% Exponential Distribution
Xrv    = RandomVariable('Sdescription','rv 2','Sdistribution','exponential',...                                            % distribution name
            'parameter1',1);
% Show details of Xrv2        
display(Xrv)    

MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% Gamma Distribution       
Xrv = RandomVariable('Sdistribution','GAMMA','Vdata',[1 5 6 3 1 20],'Vfrequency',[1 5 6 3 1 22],'Vcensoring',[1 1 0 1 1 0],'confidencelevel',.1);
% Show details of      
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% normal distribitions
Xrv    = RandomVariable('Sdescription','rv 1','Sdistribution','normal',...
            'mean',10,'cov',2);  
 
% Show details        
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% Lognormal
Xrv5    = RandomVariable('Sdistribution','lognormal', 'mean',1,'cov',2); 
% Show details of Xrv5       
display(Xrv5) 

% Generate and show realization
MX=Xrv5.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv5.Sdistribution)

%% Rayleigh
Xrv    = RandomVariable('Sdistribution','rayleigh', 'parameter1', 1); 
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% SMALL-I
Xrv    = RandomVariable('Sdistribution','small-i', 'mean',1,'std',2);
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% LARGE-I
Xrv    = RandomVariable('Sdistribution','large-i', 'mean',1,'std',2);
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% GUMBEL
Xrv    = RandomVariable('Sdistribution','gumbel', 'mean',1,'std',2);
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% WEIBULL
Xrv    = RandomVariable('Sdistribution','weibull','Cpar',{'par1', 1; 'par2',2.});
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% BETA
Xrv    = RandomVariable('Sdistribution','beta','parameter1',2,'parameter2',2);
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% GAMMA
Xrv    = RandomVariable('Sdistribution','gamma', 'mean',1,'cov',2); 
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% F-distribution
Xrv    = RandomVariable('Sdistribution','f','parameter1',2,'parameter2',2);
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% Student's distribution
Xrv    = RandomVariable('Sdistribution','t', 'parameter1', 1); 
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% LOGISTIC
Xrv    = RandomVariable('Sdistribution','logistic', 'mean',1,'cov',2); 
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% GENERALIZED PARETO
Xrv   = RandomVariable('Sdistribution','GENERALIZEDPARETO','par1',12,'par2',1,'par3',1);

% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% UNIFORM
Xrv    = RandomVariable('Sdistribution','uniform','lowerbound',0,'upperbound',1);

% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)


%% discrete uniform distributions
Xrv  =RandomVariable('Sdistribution','unid','lowerbound',-2,'upperbound',4);

% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% Poisson distribution
Xrv  =RandomVariable('Sdistribution','poisson','par1',12);
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% Binomial distribution
Xrv  =RandomVariable('Sdistribution','binomial','par1',12,'par2',.6);
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% Geometric distribution
Xrv  =RandomVariable('Sdistribution','geometric','par1',.3);
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)

%% Hypergeometric
Xrv  =RandomVariable('Sdistribution','hypergeometric','par1',20,'par2',9,'par3',10);
% Show details of the random variable       
display(Xrv) 
% Generate and show realization
MX=Xrv.sample('Nsamples',1000);
hist(gca(f1),MX,100)
title(gca(f1),Xrv.Sdistribution)



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
sample(Xrv1,'Nsamples', 5)

% extract 100 samples from Xrv1, in a 10x10 matrix
sample(Xrv1,'Vsamples', [10 10])

%% different mappings
%physical space to the cdf space
Vout1 = physical2cdf(Xrv5, [0 .1;.3 .2]); 
%cdf space to the stdnorm space
Vout2 = RandomVariable.cdf2stdnorm(0:.1:1);
%cdf space to the physica space
Vout3 = cdf2physical(Xrv1, [0 0.1 0.5]);
%stdnorm space to the cdf space
Vout4 = RandomVariable.stdnorm2cdf(-3:3);
%physical space to the stdnorm space
Vout5 = map2stdnorm(Xrv1,[0.1 1 2]);

%% transform a random variable into a DesignVariable
Xdv = Xrv1.randomVariable2designVariable;
display(Xdv)

%% Close figure
close(f1)
