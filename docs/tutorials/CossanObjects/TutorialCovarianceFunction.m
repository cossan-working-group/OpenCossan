%% TUTORIALCOVARIANCEFUNCTION
%
% In this tutorial it is shown how to construct a CovarianceFunction and
% how to evaluate the value for different time instances
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@CovarianceFunction
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Barbara~Goller$ 

clear;
close all
clc;

%% Define script for defining an exponential covariance matrix (for 1D-stochastic process)

Sscript1 = ['sigma = 1; b = 0.5;' ,... % standard deviation and correlation length
            'for i=1:length(Tinput)', ... % define for each entry of the covariance matrix the respective value
            '    Toutput(i).fcov = sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1));' ,... %exponential covariance function
            'end'];
        
%% Define CovarianceFunction object  

Xcovfun1  = opencossan.common.inputs.stochasticprocess.CovarianceFunction('Description','covariance function', ...
          'InputNames',{'t1','t2'},... % names of inputs 
          'Script',Sscript1,... % script with 1D exponential function
          'OutputNames',{'fcov'}); % name of output

%% Evaluate the values of the covariance function for time lags between 0 and 4

timesteps = linspace(0,4,100);
InputTable=array2table([zeros(1, 100); timesteps]','VariableNames',{'t1','t2'});

Vcov1 =  Xcovfun1.evaluate(InputTable);

%% Visualize and validate results

f1=figure;
plot(timesteps,Vcov1)
xlabel('\Delta t')
ylabel('covariance')

assert(all(all(abs(Vcov1(1:10)'-[1.0000, 0.9224, 0.8508, 0.7847, 0.7238, ...
                         0.6676, 0.6158, 0.5680, 0.5239, 0.4832])<1e-4)), ...
                         'CossanX:Tutorials:TutorialCovarianceFunction', ...
                         'Reference Solution does not match.')

%% Define script for defining an exponential covariance matrix (for 2D-stochastic process)

Sscript2 = ['sigma = 1; b = 1.0;' ,... % standard deviation and correlation length
            'for i=1:length(Tinput)', ... % define for each entry of the covariance matrix the respective value
            '    Toutput(i).fcov = sigma^2*exp(-1/b*sqrt(transpose(Tinput(i).x2-Tinput(i).x1)*(Tinput(i).x2-Tinput(i).x1)));' ,... %exponential covariance function
            'end'];
        
%% Define CovarianceFunction object  

Xcovfun2  = CovarianceFunction('Sdescription','covariance function', ...
          'format','structure', ... 
          'InputNames',{'x1','x2'},... % names of inputs 
          'Script',Sscript2,... % script with 1D exponential function
          'OutputNames',{'fcov'}); % name of output

      
%% Visualize and validate results

coordinates = meshgrid(linspace(0,4,100),linspace(0,4,100));
xcoordinates = coordinates(:)';
ycoordinates = repmat(linspace(0,4,100),1,100);

InputTable=array2table([zeros(2, 10000);xcoordinates;ycoordinates]','VariableNames',{'x1','x2'});

Vcov2 =  Xcovfun2.evaluate(InputTable);
f2 = figure;
plot3(xcoordinates,ycoordinates,Vcov2,'.')
grid on
xlabel('\Delta x')
ylabel('\Delta y')
zlabel('covariance')

assert(all(all(abs(Vcov2(1:10)'-[1.0000, 0.9604, 0.9224, 0.8858, 0.8508,...
                                 0.8171, 0.7847, 0.7536, 0.7238, 0.6951])<1e-4)), ...
                         'CossanX:Tutorials:TutorialCovarianceFunction', ...
                         'Reference Solution does not match.') 

%% end of tutorial - close figures

close(f1)
close(f2)     
 
