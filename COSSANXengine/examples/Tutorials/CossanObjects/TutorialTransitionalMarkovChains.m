%% TutorialTransitionalMarkovChains
% 
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@TransitionalMarkovChain
%
% $Copyright~1993-2013,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Diego Alvarez$ 
%

error('TO DO')

%% Ref. BISHOP, Pattern Recognition and Machine Learning. Exercise 2.40
% Consider a D-dimensional gaussian random variable x with PDF 
% mvnpdf(x,mu,Sigma), in which the covariance Sigma is known and for which 0.0
% we wish to infer the mean $\mu$ from a set of observations 
% $X = {x_1, x_2, ..., x_N}$. 
%
% Given the prior PDF:
% 
% p(mu) = mvnpdf(x,mu0,Sigma0), --> RandomVariableSet
%
% find the corresponding posterior PDF p(mu|X) --> Updated RandomVariableSet
%
% Solution:
% Likelihood:
% p(X|mu) = prod_{n=1}^N mvnpdf(x_n,mu,Sigma)
%
% Posterior PDF:
% invSigma = inv(Sigma) 
% invSigma0 = inv(Sigma0)
% muML = (1/N)*sum_{n=1}^N xn  % maximum likelihood estimator for the mean
%
% p(mu|X) = mvnpdf(x,muN,sigmaN)
% where:
% muN = inv(invSigma0 + N*invSigma)*(invSigma0*mu0 + invSigma*N*muML)
% invsigmaN = invSigma0 + N*invSigma

%% Implementation in OpenCossan
OpenCossan.reset;

%% Preparation of the Input
% Definition of the Parameters, unknown (parameter to be found)
Sigma = [1 .2 ; .2 3];   % known

% Definition of the Random Variables to simula1te synthetic data
mu1=Parameter('value',-5,'Sdescription','mean of x1'); %(prior information)
mu2=Parameter('value',8,'Sdescription','mean of x2'); %(prior information)
X1=RandomVariable('Sdistribution','normal','mean',mu1.value,'std',1.0,'Sdescription','X1');
X2=RandomVariable('Sdistribution','normal','mean',mu2.value,'std',1.0,'Sdescription','X2');
Xrvset=RandomVariableSet('CXrandomVariables',{X1 X2},...
    'Mcorrelation',Sigma,'CSmembers',{'perturbation1' 'perturbation2'});

%% Prepare Input Object
% The previously prepared Parameters and RV objects can be added together to an 'Xinput' Object
Xinput=Input('CXmembers',{m1 m2 Xrvset},'CSmembers',{'m1' 'm2' 'Xrvset'});
% Show summary of the Input Object
display(Xinput)


%% Generate samples from the true PDF
N = 1000;

%p_mu_truernd = @(N) mvnrnd(mu', Sigma, N);
%X = p_mu_truernd(N); % these are experimental observations

Xmodel=Model('Xevaluator',Evaluator,'Xinput',Xinput);
Xmc=MonteCarlo('Nsamples',1000);
XsyntheticData=Xmc.apply(Xmodel);


%% Parameters of the prior PDF  p(mu)
mu1=Parameter('value',-2,'Sdescription','mean of x1'); %(prior information)
mu2=Parameter('value',1,'Sdescription','mean of x2'); %(prior information)

mu0     = [-2; 1];             % known
Sigma0  = [3 -0.4 ; -0.4 5];   % known (prior information)

p_mu =    @(x) mvnpdf(x, mu0', Sigma0);
p_murnd = @(N) mvnrnd(mu0', Sigma0, N);

%% The posterior PDF:
invSigma  = inv(Sigma);
invSigma0 = inv(Sigma0);
muML = mean(X)';           % maximum likelihood estimator for the mean
muN  = (invSigma0 + N*invSigma)\(invSigma0*mu0 + N*invSigma*muML);
sigmaN = inv(invSigma0 + N*invSigma);

p_mu_X    = @(x) mvnpdf(x, muN', sigmaN);
p_mu_Xrnd = @(N) mvnrnd(muN', sigmaN, N);

%% Plot the prior PDF + experimental observations
figure
subplot(1,2,1);
hold on
plot(X(:,1), X(:,2), 'b.');
ax = axis;
[xx, yy] = meshgrid(linspace(ax(1),ax(2),100), linspace(ax(3), ax(4), 99));
%rr = reshape(p_mu_true([xx(:) yy(:)]), 99, 100);
rr = reshape(p_mu([xx(:) yy(:)]), 99, 100);
contour(xx, yy, rr, 50);
grid minor
plot(mu(1),mu(2),'v',     'MarkerEdgeColor','k',...
                          'MarkerFaceColor','g',...
                          'MarkerSize',10);

plot(muML(1),muML(2),'o', 'MarkerEdgeColor','k',...
                          'MarkerFaceColor','g',...
                          'MarkerSize',10);
title('Prior Gaussian PDF and samples from the true PDF');
legend('Samples of the true PDF ~ N(mu,Sigma)', ...
       'Prior PDF of "mu"', ...
       'Exact value of "mu"', ...       
       'ML estimate of "mu"');

%% Plot the posterior PDF + simulations
subplot(1,2,2);
hold on
r = p_mu_Xrnd(N);
plot(r(:,1), r(:,2), 'b.');
ax = axis;
[xx, yy] = meshgrid(linspace(ax(1),ax(2),100), linspace(ax(3), ax(4), 99));
rr = reshape(p_mu_X([xx(:) yy(:)]), 99, 100);
contour(xx, yy, rr, 50);
grid minor
axis tight
plot(mu(1),mu(2),'v',     'MarkerEdgeColor','k',...
                          'MarkerFaceColor','g',...
                          'MarkerSize',10);

plot(muML(1),muML(2),'o', 'MarkerEdgeColor','k',...
                          'MarkerFaceColor','g',...
                          'MarkerSize',10);
title('Posterior Gaussian PDF');
legend('Samples of the posterior PDF ~ N(muN,SigmaN)', ...
       'Posterior PDF of "mu"', ...
       'Exact value of "mu"', ...       
       'ML estimate of "mu"');

%% The loglikelihood of X given mu. Sigma is known
log_p_X_mu = @(mu) test1_log_p_X_mu(mu, X, Sigma);

%% Run TMCMC
tic
[theta_fT_D, log_fD] = tmcmc(log_p_X_mu, p_mu, p_murnd, 100);
toc

%% Plot the results of TMCMC
figure
hold on
plot(theta_fT_D(:,1), theta_fT_D(:,2), 'r.');
ax = axis;
[xx, yy] = meshgrid(linspace(ax(1),ax(2),100), linspace(ax(3), ax(4), 99));
rr = reshape(p_mu_X([xx(:) yy(:)]), 99, 100);
contour(xx, yy, rr, 50);
grid minor
axis tight
plot(mu(1),mu(2),'v',     'MarkerEdgeColor','k',...
                          'MarkerFaceColor','g',...
                          'MarkerSize',10);

plot(muML(1),muML(2),'o', 'MarkerEdgeColor','k',...
                          'MarkerFaceColor','g',...
                          'MarkerSize',10);

muTMCMC = mean(theta_fT_D)';  % Mean of points obtained with TMCMC
plot(muTMCMC(1),muTMCMC(2),'^', ...
                          'MarkerEdgeColor','k',...
                          'MarkerFaceColor','g',...
                          'MarkerSize',10);

title('Posterior Gaussian PDF + samples from TMCMC');
legend('Samples of the posterior PDF ~ provided by TMCMC', ...
       'Posterior PDF of "mu" (estimated analytically)', ...
       'Exact value of "mu"', ...       
       'ML estimate of "mu"', ...
       'Mean of points obtained with TMCMC');
   
%% Close figures
close(f1),close(f2),close(f3),close(f4)
