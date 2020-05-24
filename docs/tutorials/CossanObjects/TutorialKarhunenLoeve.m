%% TUTORIALKARHUNENLOEVE
%
% In this tutorial showns how to construct a KARHUNENLOEVE object and
% how to use it as an input to a dynamic, transient FE-analysis.
%
% KARHUNENLOEVE object is a subclass of STOCHASTIC PROCESS
%
% See Also: STOCHASTICPROCESS TutorialInput
%
% $Copyright~1993-2020,~COSSAN~Working~Group$
% $Author:~Barbara~Goller$
% $Author:~Edoardo~Patelli$

clear
close all
clc;

% Import the package stochasticprocess
import opencossan.common.inputs.CovarianceFunction.*
import opencossan.common.inputs.stochasticprocess.*
% Reset the random number generator in order to always obtain the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
%opencossan.OpenCossan.resetRandomNumberGenerator(51125)

%% 1D-STOCHASTIC PROCESS
% In this first example we want to simulate a random process function of
% time.
%
% First we define a covariance matrix using the object CovarianceFunction
% The covariance function must have be able to evaluate an input of 2
% variables. It is possible to overwrite the default values assigned to
% InputNames. Default values of the InputNames are x_1 and x_2.
Xcovfun  = CovarianceFunction('Description','covariance function', ...
    'IsFunction',false,'Format','structure',...
    'Script', strcat('sigma = 1; b = 0.5; for i=1:length(Tinput), ',...
    'Toutput(i).fcov  = sigma^2*exp(-1/b*abs(Tinput(i).x_2-Tinput(i).x_1));',...
    'end'), 'OutputNames',{'fcov'},'InputNames',{'x_1' 'x_2'}); % Define the outputs

% Define the time steps of the process
Vtime =  linspace(0,5,101); % time steps

% Now we create a KarhunenLoeve object that is able to generate the
% stochastic process based on the Karhunen-Loeve expansion.
SP1    = KarhunenLoeve('Distribution','normal',...
    'Mean',0,'CovarianceFunction',Xcovfun,...
    'Coordinates',Vtime,'IsHomogeneous',true);

% The terms of the Karhunen-Loeve need to be computed before being able to
% generate samples.
%
% The methods computeTerms is used to calculate the Karhunen-Loeve terms

SP1    = computeTerms(SP1,'NumberTerms',30,'AssembleCovariance',true); % compute 30  terms

% Generate 3 samples of stochastic process
ds1 = SP1.sample('Samples',3);
f1=figure;
plot(ds1.Xdataseries(1,1).Mcoord,cat(1,ds1.Xdataseries.Vdata));
grid on
xlabel('time [s]')
ylabel('function value')
legend('sample no. 1','sample no. 2','sample no. 3')
title('3 samples of 1D-stochastic process')

% compare covariance matrix of samples and analytical covariance matrix
ds1 = SP1.sample('Samples',1000); % use 1000 samples
Mcov = cov(cat(1,ds1.Xdataseries.Vdata));
f2=figure;
mesh(ds1.Xdataseries(1,1).Mcoord,ds1.Xdataseries(1,1).Mcoord,Mcov)
xlim([0 5])
ylim([0 5])
xlabel('\Delta t')
ylabel('\Delta t')
zlabel('covariance')
title('Covariance matrix of stationary 1D-stochastic process estimated from 1000 samples')


%% Define StochasticProcess object by passing the covariance function without assembling the matrix
Vtime =  0:0.1:5;
SP2    = KarhunenLoeve('Distribution','normal',...
        'Mean',0,'CovarianceFunction',Xcovfun,...
        'Coordinates',Vtime,'IsHomogeneous',false);
SP2    = computeTerms(SP2,'NumberTerms',30,'AssembleCovariance',true);

% Define StochasticProcess object by passing the covariance matrix
Vtime = 0:0.1:5;
[Mtime1, Mtime2]= meshgrid(Vtime,Vtime);
TableInput=array2table([Mtime1(:) Mtime2(:)],'VariableNames',Xcovfun.InputNames);
TableOutput = evaluate(Xcovfun,TableInput);
Mcovariance =  reshape(table2array(TableOutput),length(Vtime),length(Vtime));

SP3    = KarhunenLoeve('Distribution','normal',...
    'Mean',5,'CovarianceMatrix',Mcovariance,'Coordinates',Vtime);
SP3    = computeTerms(SP3,'NumberTerms',30);

f3=figure;
mesh(Mtime1,Mtime2,Mcovariance)
xlim([0 5])
ylim([0 5])
xlabel('\Delta t')
ylabel('\Delta t')
zlabel('covariance')
title('Analytical covariance matrix of stationary 1D-stochastic process')


%% close figures and validate solution

close(f1);
close(f2);
close(f3);

% samples of SP1
Vdata = ds1.Xdataseries(1,1).Vdata;
% assert(all(abs(Vdata(1:10)-[ -1.2414   -1.2026   -1.0508   -0.8726...
%     -0.7642   -0.7896   -0.9509   -1.1840   -1.3871   -1.4710])<1.e-4),...
%     'OpenCossan:TutorialKarhunenLoeve', ...
%     'Reference Solution ds1 does not match.');

% eigenvalues of covariance matrix of SP2
% assert(all(abs(SP2.VcovarianceEigenvalues(1:10)'-[9.4080, 7.8957, 6.1779, 4.6928, ...
%     3.5571, 2.7295, 2.1327, 1.6992, 1.3794, 1.1393])<1.e-4),...
%     'OpenCossan:TutorialKarhunenLoeve', ...
%     'Reference Solution SP2 does not match.');

% eigenvalues of covariance matrix of SP3
% assert(all(abs(SP3.VcovarianceEigenvalues(1:10)'-[9.4080, 7.8957, 6.1779, 4.6928, ...
%     3.5571, 2.7295, 2.1327, 1.6992, 1.3794, 1.1393])<1.e-4),...
%     'OpenCossan:TutorialKarhunenLoeve', ...
%     'Reference Solution SP3 does not match.');


%% 2D-STOCHASTIC PROCESS
% Define covariance matrix
Xcovfun  = CovarianceFunction('Description','covariance function', ...
    'IsFunction',false,'Format','structure',...
    'Script',strcat('sigma = 1; b = 0.5; for i=1:length(Tinput),',...
    'Toutput(i).fcov  = sigma^2*exp(-1/b*sqrt((Tinput(i).x_2-Tinput(i).x_1)*',...
    '(Tinput(i).x_2-Tinput(i).x_1)'')); end'), ...
    'OutputNames',{'fcov'},'InputNames',{'x_1','x_2'}); % Define the outputs

% Define StochasticProcess object by passing the covariance function and assembling the matrix
[Vx ,Vy]  = meshgrid(0:0.5:5,0:0.5:4);
Vx = Vx(:)';
Vy = Vy(:)';
Vxy = [Vx; Vy];
SP4    = KarhunenLoeve('Distribution','normal','Mean',0,...
    'CovarianceFunction',Xcovfun,...
    'CoordinateNames',{'x','y'},...
    'CoordinateUnits',{'',''},...
    'Coordinates',Vxy);
SP4    = computeTerms(SP4,'NumberTerms',30,'AssembleCovariance',true);

% Generate samples of the stochastic process and visualize them
ds1 = SP4.sample('Samples',1000);
plot(ds1.Xdataseries(1,1).Vdata)

% compare covariance matrix computed from samples and analytical one

[Mindex1, Mindex2]= meshgrid(1:length(Vx),1:length(Vx));

TableInput=array2table([Mindex1(:) Mindex1(:)],'VariableNames',Xcovfun.InputNames);
TableOutput = evaluate(Xcovfun,TableInput);
Mcovariance =  reshape(table2array(TableOutput),length(Mindex1),length(Mindex2));

f2=figure;
mesh(Mindex1,Mindex2,Mcovariance)
view(0,90)
title('Analytical covariance matrix of homogeneous 2D random field')
xlabel('\Delta x')
ylabel('\Delta y')

Mcov_stat = cov(cat(1,ds1.Xdataseries.Vdata));
f3=figure;
mesh(Mindex1,Mindex2,Mcov_stat)
view(0,90)
title('Covariance matrix of homogeneous, 2D random field estimated from 1000 samples')

%% close figures and validate solution (part of samples of SP1)

close(f1)
close(f2)
close(f3)

Vdata = ds1.Xdataseries(1,1).Vdata;
% assert(all(abs(Vdata(1:10)-[-0.0158   -0.1916   -0.5984   -0.8918  ...
%     -0.5872    0.2443    0.8785    0.7907    0.2702   -0.0833])<1.e-4),...
%     'CossanX:Tutorials:TutorialDataseries', ...
%     'Reference Solution ds1 does not match.');


%% 3D-STOCHASTIC PROCESS

Xcovfun  = CovarianceFunction('Description','covariance function', ...
    'IsFunction',false,'Format','structure',...
    'Script',strcat('sigma = 1; b = 0.5; for i=1:length(Tinput), ', ...
    'Toutput(i).fcov  = sigma^2*exp(-1/b*sqrt((Tinput(i).x_2-Tinput(i).x_1)',...
    '*(Tinput(i).x_2-Tinput(i).x_1)'')); end'),...
    'OutputNames',{'fcov'},'InputNames',{'x_1','x_2'}); % Define the outputs

% Define 3d-coordinates for random field
[Vx, Vy, Vz]  = meshgrid(0:0.5:5,0:0.5:5,0:0.5:5);
Vx = Vx(:)';
Vy = Vy(:)';
Vz = Vz(:)';
Vxyz = [Vx; Vy; Vz];

% Define random field
SP5    = KarhunenLoeve('Distribution','normal','Mean',0,...
    'CovarianceFunction',Xcovfun,'Coordinates',Vxyz,...
    'CoordinateNames',{'x','y','z'},...
    'CoordinateUnits',{'','',''});
SP5    = computeTerms(SP5,'NumberTerms',30,'AssembleCovariance',true);


% Generate 1 sample
ds1 = SP5.sample('Samples',1);

% visualization of volumetric evolution using 4 slices
[Vx, Vy, Vz]  = meshgrid(0:0.5:5,0:0.5:5,0:0.5:5);
Vv = ds1.Xdataseries(1,1).Vdata;
Vv = reshape(Vv, size(Vx));
xmin = min(Vx(:));
ymin = min(Vy(:));
zmin = min(Vz(:));

xmax = max(Vx(:));
ymax = max(Vy(:));
zmax = max(Vz(:));

% create 45 degrees slice
f1 = figure;
hslice = surf(linspace(xmin,xmax,20),...
    linspace(ymin,ymax,20),...
    2.5+zeros(20));
rotate(hslice,[-1,0,0],-45)
xd = get(hslice,'XData');
yd = get(hslice,'YData');
zd = get(hslice,'ZData');
delete(hslice)

h = slice(Vx,Vy,Vz,Vv,xd,yd,zd);
set(h,'FaceColor','interp',...
    'EdgeColor','none',...
    'DiffuseStrength',.8)

% create slices in x, y and z directions
hold on
hx = slice(Vx,Vy,Vz,Vv,xmax,[],[]);
set(hx,'FaceColor','interp','EdgeColor','none')

hy = slice(Vx,Vy,Vz,Vv,[],ymax,[]);
set(hy,'FaceColor','interp','EdgeColor','none')

hz = slice(Vx,Vy,Vz,Vv,[],[],zmin);
set(hz,'FaceColor','interp','EdgeColor','none')

% change the view and add light to make the plot prettier
daspect([1,1,1])
axis tight
box on
view(-38.5,16)
lightangle(-45,45)
set(gcf,'Renderer','zbuffer')
xlabel('x')
ylabel('y')
zlabel('z')
title('1 sample of 3D-stochastic process visualized on 4 planes')

%% close figures and validate solution (part of samples of SP5)

close(f1)
Vdata = ds1.Xdataseries(1,1).Vdata;
% assert(all(abs(Vdata(1:10)-[-0.2910   -0.3283   -0.2528   -0.1158...
%     0.0115    0.0839    0.0996    0.0856    0.0686    0.0565])<1.e-4),...
%     'CossanX:Tutorials:TutorialDataseries', ...
%     'Reference Solution ds1 does not match.');
% free some memory (2d and 3d processes use quite some...)
clear SP4 SP5
%% NON-HOMOGENEOUS STOCHASTIC PROCESS

Xcovfun  = CovarianceFunction('Description','covariance function', ...
    'IsFunction',false,'Format','structure',...
    'InputNames',{'t1','t2'},... % Define the inputs
    'Script','for i=1:length(Tinput),Toutput(i).fcov = min(Tinput(i).t1,Tinput(i).t2); end',...
    'Outputnames',{'fcov'}); % Define the outputs

% Create StochasticProcess object by passing the covariance function and assembling the matrix

Vtime =  linspace(0,5,100);

% Define random field
SP6    = KarhunenLoeve('Distribution','normal','Mean',0,...
    'CovarianceFunction',Xcovfun,'Coordinates',Vtime,...
    'CoordinateNames',{'x'},...
    'CoordinateUnits',{''});
SP6    = computeTerms(SP6,'NumberTerms',30,'AssembleCovariance',true);


% Generate 1000 samples
ds1 = SP6.sample('Samples',1000);

% Compare the analytical covariance to the statisctical covariance
[Mtime1, Mtime2]= meshgrid(Vtime,Vtime);

TableInput=array2table([Mtime1(:) Mtime2(:)],'VariableNames',Xcovfun.InputNames);
TableOutput = evaluate(Xcovfun,TableInput);
Mcovariance =  reshape(table2array(TableOutput),length(Vtime),length(Vtime));

f1=figure;
surf(Mtime1,Mtime2,Mcovariance)
view(0,90)
title('Analytical covariance matrix of non-homogeneous stochastic process')
xlabel('x')
ylabel('y')

Mcov_stat = cov(cat(1,ds1.Xdataseries.Vdata));
f2=figure;
surf(Mtime1,Mtime2,Mcov_stat)
view(0,90)
title('covariance matrix of non-homogeneous stochastic process estimated from 1000 samples')
xlabel('x')
ylabel('y')

%% close figures and validate solution (part of samples of SP6)

close(f1)
close(f2)

Vdata = ds1.Xdataseries(1,1).Vdata;
% assert(all(abs(Vdata(1,1:10)-[-0.0000,-0.3692,-0.6252,-0.7183,...
%     -0.6851,-0.6188,-0.6066,-0.6786,-0.7978,-0.8952])<1.e-4),...
%     'CossanX:Tutorials:TutorialDataseries', ...
%     'Reference Solution ds1 does not match.');


% Please check TutorialInput to see how to use the KarhunenLoeve object
% with an Input object
