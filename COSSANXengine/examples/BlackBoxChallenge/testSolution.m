%% Reliability Problem 14
%  
% Target: pF=7.564e-4, beta=3.17
% https://rprepo.readthedocs.io/en/latest/reliability_problems.html#sec-rp-14

Sfolder = fileparts(mfilename('fullpath'));% returns the current folder
SproblemName='RP14';


% Monte Carlo simulation 
% Calculare reference solution
Nsamples=500000;
Xsimulator=MonteCarlo('Nsamples',Nsamples);
% Define the model
run(fullfile(Sfolder,SproblemName,[SproblemName '.m']))
% Here we go
[XpF, ~] = Xpm.computeFailureProbability(Xsimulator);
fprintf('* OpenCossan    : Failure probability %6.2e (Beta: %4.2f)\n',XpF.pfhat,XpF.reliabilityIndex);

% test with MATLAB functions only - reference solution
Minput = [unifrnd(70,80,Nsamples*40,1)...
    normrnd(39,0.1,Nsamples*40,1)...
    -evrnd(-1342,272.9,Nsamples*40,1)...
    normrnd(400,0.1,Nsamples*40,1),...
    normrnd(250000,35000,Nsamples*40,1)];
Moutput = gRP14(Minput);

pf = sum(Moutput<0)/(Nsamples*40);
std_pf = sqrt(pf/(Nsamples*40)); CoV_pf = std_pf/pf;
fprintf('* Matlab built-in: Failure probability %6.2e (Beta: %4.2f)\n',pf,-norminv(pf))
