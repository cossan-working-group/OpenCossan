clear variables; clc; close all

Ndimensions = 2;

%% What time and date is it?
datetimenow = datestr(clock);
%% Defining the prior PDF p(theta)
%What is the syntax for doing it the new way?
p = opencossan.common.inputs.RandomVariable('Sdistribution','uniform','mean',0,'std',4/3); 
Prior = opencossan.common.inputs.RandomVariableSet('Xrv',p,'Nrviid',Ndimensions);

%% The loglikelihood of D given theta
Nsamples = 200;

    
std = 0.05;
weight = 0.5;


ft = @(theta) weight*mvnpdf(theta,0.5*ones(1,Ndimensions),std^2*eye(Ndimensions)) + ...
        (1-weight)*mvnpdf(theta,-0.5*ones(1,Ndimensions),std^2*eye(Ndimensions));

LogLike = opencossan.inference.LogLikelihood('CustomLog',ft);
Bayes = opencossan.inference.BayesianModelUpdating('Prior',Prior,'Nsamples',Nsamples,'XLogLikelihood',LogLike,'PlotGraphics',1);


%% Bayesian estimation of theta: bayesian model updating using TMCMC
tic;
samples_ftheta_D = Bayes.applyTMCMC();
% plotmatrix(samples_ftheta_D)
toc

plots = samples_ftheta_D.getValues('Cnames',{'p_1' 'p_2'});

plot(plots(:,1),plots(:,2),'.');

% diary off;
