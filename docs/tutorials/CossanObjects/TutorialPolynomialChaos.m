%% TUTORIALPOLYNOMIALCHAOS
%
% In this tutorial it is shown how to construct and use a PolynomialChaos object
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@PolynmialChaos
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~HMP$ 
clear
close all
clc;

%% load the previously calculated SfemPC object 

load ([opencossan.OpenCossan.getRoot '/examples/Tutorials/CossanObjects/Xsfem'])

display(Xsfem);
Xpc   = PolynomialChaos('Xsfem',Xsfem,'Norder',3); 
display(Xpc);

%% Calculate the P-C coefficients
%
% Calibrate method calculates the P-C coefficients for the whole
% displacement vector of the FE model defined in the Sfem object, i.e.
% currently PC object is only developed to work with SFEM

Xpc = calibrate(Xpc);

%% Generate more samples using the PC as the meta model
%
% Once the P-C exp. is constructed, it can be used to generate more samples
% of the displacement vector

% For this purpose, first an RVSET involving std. normal RV's 
% (as many as the dimension of the PC exp.) should be constructed
rv1     = RandomVariable('Sdistribution','normal','mean',0,'std',1);
rv2     = RandomVariable('Sdistribution','normal','mean',0,'std',1);
rv3     = RandomVariable('Sdistribution','normal','mean',0,'std',1);
Xrvs    = RandomVariableSet('Cmembers',{'rv1','rv2','rv3'},'CXrandomvariables',{rv1 rv2 rv3});
Xinp    = Input('Sdescription','Xinput object');
Xinp    = add(Xinp,Xrvs);

% Then generate samples of this RVs
% Fix the seed in order to generate same samples => to validate results
opencossan.OpenCossan.resetRandomNumberGenerator(1);
Xinp    = Xinp.sample('Nsamples',5000);

% Using the samples of the RVs, obtain the samples of the displacement vector
Xsimout = apply(Xpc,Xinp);
display(Xsimout);

%% Validate results

% statistics of the first entry of the displacement vector is checked here
% reference results are as follows
referenceMean = 0.9040;
referenceStd  = 0.0917;

% calculated mean & CoV
calculatedMean = mean(Xsimout.Mvalues);
calculatedStd  = std(Xsimout.Mvalues);

assert(abs(calculatedMean-referenceMean)<1e-2,'CossanX:Tutorials:TutorialPC', ...
      'Reference mean value does not match.')

assert(abs(calculatedStd-referenceStd)<1e-2,'CossanX:Tutorials:TutorialPC', ...
      'Reference Std value does not match.')