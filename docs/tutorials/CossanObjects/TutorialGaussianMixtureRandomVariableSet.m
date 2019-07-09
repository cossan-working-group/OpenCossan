%% Tutorial for the GaussianMixtureRandomVariableSet object
%
% The class GaussianMixtureRandomVariableSet is used to create a Set of Gaussian Random
% Variables 
% This class is particolarly useful to crate a multivariate distrution starting
% from realizations. 
% 
% See Also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@GaussianMixtureRandomVariableSet
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 

clear
close all
clc;
%% Create GaussianMixtureRandomVariableSet from a Data-Set
% Create a data-set
% In this examples the data-set is creating using the matlab function
% gmdistribution. 

N = 20; % Number of samples
A1 = [2 -1.8 0; -1.8 2 0; 0 0 1]; % Covariance matrix
A2 = [2 -1.9 1.9; -1.9 2 -1.9; 1.9 -1.9 2];% Covariance matrix
A3 = [2 1.9 0;1.9 2 0; 0 0 1];% Covariance matrix

p = [0.03 0.95 0.02]; % Mixture proportion 
MU = [4 4 -4;-3 -5 4;4 -4 0]; % Mean
SIGMA = cat(3,A1,A2,A3);
obj = gmdistribution(MU,SIGMA,p);
% Create the data-set
MdataSet = random(obj,N); 

% Starting from this data-set a multivariate distribution can easily constructed
% invoking the following command
Xgrvset=opencossan.common.inputs.GaussianMixtureRandomVariableSet('MdataSet',MdataSet,'Cmembers',{'X1' 'X2' 'X3'});
% where Cmembers defines the names of the RandomVariables

% Show the summary of the GaussianMixtureRandomVariableSet
display(Xgrvset)

% This object can be used to generate samples:
% Like the RandomVariableSet, the sample method returns a Sample object. 

Xs=Xgrvset.sample(1000);

%% Check the samples
% The samples created can be nicely shown in a scatter plot
figure;
scatter(Xs.MsamplesPhysicalSpace(:,1),Xs.MsamplesPhysicalSpace(:,2),'b');
hold; box;
scatter(MdataSet(:,1),MdataSet(:,2),'r','sizedata',50);
 
%% Check the 2d density
% The 2d density plot can be visualized using the method plot2Ddensity
Xgrvset.plot2Ddensity('SxAxisVariable','X1','SyAxisVariable','X2')

%% User Defined GaussianMixtureRandomVariableSet
% The GaussianMixtureRandomVariableSet can be also used to construct a user
% defined multivariate distribution as shown in the following exampes

%% Example 1: Cross
% The GaussianMixtureRandomVariableSet requires the same inputs of the
% gmdistribution (see doc gmdistribution)

% Define the mean point 
mu=[-0.2 0; 0 0.2];
% Define the covariance matries
SIGMA2=[0.2^2, 0.936*0.8*0.2;  0.936*0.8*0.2 0.8^2;];
SIGMA1=[0.8^2, 0.936*0.8*0.1;  0.936*0.8*0.1 0.1^2;];
SIGMA=zeros(2,2,2);
SIGMA(:,:,2)=SIGMA2;
SIGMA(:,:,1)=SIGMA1;
% Contruct the object
Xg=GaussianMixtureRandomVariableSet('Mmeans',mu,'Mcovariance',SIGMA,'Cmembers',{'x1','x2'});

% The raw data can be samples using the random method of the gmdistribution:
MX=Xg.gmDistribution.random(100000);
% or using the sample method of the object GaussianMixtureRandomVariableSet
XS=Xg.sample(10000);

% Create samples from Xrvs
figure
scatterhist(XS.MsamplesPhysicalSpace(:,1),XS.MsamplesPhysicalSpace(:,2))
title('Example #1a: cross')

%% Example 2: islands
mu=[-4 -4; 4 4];
SIGMA=eye(2);
Xg=GaussianMixtureRandomVariableSet('Mmeans',mu,'Mcovariance',SIGMA,'Cmembers',{'x1','x2'});
MX=Xg.gmDistribution.random(100000);

figure
scatterhist(MX(:,1),MX(:,2))
title('Example #2 (islands)')


%% Example 3: doughnut
rho=9;
theta=linspace(-2*pi,2*pi,100);
x=rho*cos(theta);
y=rho*sin(theta);

mu=[x;y]';
SIGMA=eye(2);
Xg=GaussianMixtureRandomVariableSet('Mmeans',mu,'Mcovariance',SIGMA,'Cmembers',{'x1','x2'});
MX=Xg.gmDistribution.random(100000);

figure
scatterhist(MX(:,1),MX(:,2))
title('Example #3 (doughnut): Gaussian mixture')


%% Example #4: Spots
SIGMA1=[0.8^2, 0.936*0.8*0.1;  0.936*0.8*0.1 0.1^2;];
SIGMA2=[0.6^2, 0.936*0.6*0.7;  0.936*0.6*0.7 0.7^2;];
SIGMA3=[0.2^2, 0.536*0.7*0.2;  0.536*0.7*0.2 0.7^2;];
SIGMA4=[0.1^2, 0.936*0.8*0.1;  0.936*0.8*0.1 0.8^2;];
SIGMA5=eye(2);
SIGMA=zeros(2,2,5);
SIGMA(:,:,1)=SIGMA1;SIGMA(:,:,2)=SIGMA2;SIGMA(:,:,3)=SIGMA3;SIGMA(:,:,4)=SIGMA4;SIGMA(:,:,5)=SIGMA5;
Xg = GaussianMixtureRandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'MdataSet',[5 5; 5 -5; -5 5; -5 -5; 0 0],'Mcovariance',SIGMA);

% Generate samples form gmDistribution
Mx=Xg.gmDistribution.random(10000);
scatter(Mx(:,1),Mx(:,2),'.b')
hold;

%% Convert uncorrelated cdf to the physical space
% This method requires as an input a matrix of samples in a N+1 dimensional
% space!!!
% In this example the GaussianMixtureRandomVariableSet defines a bivariate
% distribution. Hence, a 3 dimensional uncorrelated values in the hypercure are
% required.
MU=rand(10000,3);
% Perform the mapping
MX=Xg.uncorrelatedCDF2PhysicalSpace(MU);
% Show the results
scatter(MX(:,1),MX(:,2),'.r')
box on;
xlabel('X1'); ylabel('X2');title('Example 6: Physical space')
legend('sample@GaussianRandomVariableSet','sample from the hypercube in N+1 dimensional space')

%% Using Ncomponents
mu1 = [1 2];
Sigma1 = [2 0; 0 .5];
mu2 = [-3 -5];
Sigma2 = [1 0; 0 1];
X = [mvnrnd(mu1,Sigma1,1000);mvnrnd(mu2,Sigma2,1000)];

Xg = GaussianMixtureRandomVariableSet('Cmembers',{'Xrv1','Xrv2'},...
    'MdataSet',X,'Ncomponents',2);

MX=Xg.gmDistribution.random(100000);
figure
scatterhist(MX(:,1),MX(:,2))
title('Example #4 Using Ncomponents')

%% Using Standard defiation for each components
Xg = GaussianMixtureRandomVariableSet('Cmembers',{'Xrv1','Xrv2'},...
    'VstandardDeviation',[4 5],'Mcorrelation',[1 0.2; 0.2 1],'Mdataset',X);

MX=Xg.gmDistribution.random(100000);
figure
scatterhist(MX(:,1),MX(:,2))
title('Example #5 Using Correlations and standard deviations')

%% Other methods
% The GaussianMixtureRandomVariableSet is an extension of the RandomVariableSet
% and supports the same methods available for the latter class.
% The user is inveted to refer to the Turorial of the RandomVaiableSet for the
% explenation of all the methods.

%% map2physical
%converts the values (given as as an input) from the (correlated) standard normal space
%to the physical space

%% map2stdnorm
%converts the values  from the physical space 
%to the (correlated) standtrd normal space

%% cdf2physical
%converts the values from the (correlated) hypercube
%to the physical space

%% cdf2stdnorm
%converts the values from the  (correlated) hypercube
%to  (correlated) standtrd normal space

%% stdnorm2cdf
%converts the values from the (correlated) standtrd normal space
%to the (correlated)  hypercube


