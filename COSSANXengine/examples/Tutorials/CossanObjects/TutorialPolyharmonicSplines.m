%**************************************************************************
% In this tutorial it is shown how to construct a PolyharmonicSplines object
% and how to use it for approximating of a function
%
% See Also: 
% https://cossan.co.uk/wiki/index.php/@PolyharmonicSplines
%
% Author: Matteo Broggi & Edoardo Patelli
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

% Reset the random number generator in order to always obtain the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)

% copy FE-input file with COSSAN-identifiers to working directory
StutorialPath = fileparts(which('TutorialPolyharmonicSplines.m'));

%%  Definition of Inputs

X1 = RandomVariable('Sdescription','random variable 1',...
    'Sdistribution','uniform','par1',-5,'par2',5);
X2 = RandomVariable('Sdescription','random variable 2',...
    'Sdistribution','uniform','par1',-5,'par2',5);
X3 = RandomVariable('Sdescription','random variable 2',...
    'Sdistribution','uniform','par1',-5,'par2',5);

Xrvset      = RandomVariableSet('Cmembers',{'X1','X2','X3'});
Xin         = Input('XRandomVariableSet',Xrvset);

%%  Create Mio to Rosenbrock function
Xmio = Mio('Spath',fullfile(OpenCossan.getCossanRoot,'examples','Models','MatlabFunctions','Rosenbrock'),...
    'Sfile','Rosenbrock.m',...
    'Lfunction',true,...
    'Liomatrix',true,...
    'Liostructure',false,...
    'Cinputnames',{'X1','X2','X3'},...
    'Coutputnames',{'out'});

%% Construct the Model
Xev = Evaluator('Xmio',Xmio);
Xmod = Model('Xevaluator',Xev,'Xinput',Xin);

%% Construction and Calibration of Polyharmonic Splines
% In this step, a linear Polyharmonic Splines model is created. 
Xps1 = PolyharmonicSplines('Sdescription','quadratic spline of Rosenbrock function',...
    'XfullModel',Xmod,...   %full model
    'Cinputnames',{'X1' 'X2','X3'},... 
    'Coutputnames',{'out'},...  %response to be extracted from full model
    'Stype','quadratic',...
    'Sextrapolationtype','quadratic');

Xlhs= LatinHypercubeSampling('Nsamples',400); % simulation obecjt for calibration samples
Xps1 = Xps1.calibrate('XSimulator',Xlhs); % calibrate spline

Xmc=LatinHypercubeSampling('Nsamples',20); % simulation object for validation samples
Xps1 = Xps1.validate('XSimulator',Xlhs); % validate spline

% regression plots for calibration and validation
% because of the nature of splines, the regression plot for calibration is
% perfect (the splines always pass from the support points)
f1 = Xps1.plotregression('Stype','calibration','Soutputname','out');
f2 = Xps1.plotregression('Stype','validation','Soutputname','out');

% In this step, a Polyharmonic Splines model of power 5 is created
Xps2 = PolyharmonicSplines('Sdescription','power 5 spline of Rosenbrock function',...
    'XfullModel',Xmod,...   %full model
    'Cinputnames',{'X1' 'X2','X3'},... 
    'Coutputnames',{'out'},...  %response to be extracted from full model
    'Stype','custom','Nexponent',5);   %type of response surface

Xps2 = Xps2.calibrate('XSimulator',Xlhs); % calibrate spline
Xps2 = Xps2.validate('XSimulator',Xlhs); % validate spline

% regression plots for calibration and validation
f3 = Xps2.plotregression('Stype','calibration','Soutputname','out');
f4 = Xps2.plotregression('Stype','validation','Soutputname','out');

%% Apply Polyharmonic Spline
MXX1 = repmat(linspace(-5,5,201),201,1);
MXX2 = MXX1';
MXX3 = ones(201,201);
Vx1=MXX1(:); Vx2 = MXX2(:);Vx3=MXX3(:);
Minput = [Vx1,Vx2,Vx3];
Xs = Samples('Xrvset',Xrvset,'MsamplesPhysicalSpace',Minput);
Xin = Xin.add('Xmember',Xs,'Sname','Xs');

Xoutreal = Xmio.run(Xin);
Xoutps1 = Xps1.apply(Xin);
Xoutps2 = Xps2.apply(Xin);

f5 = figure(5);
mesh(MXX1,MXX2,reshape(Xoutreal.getValues('Sname','out'),201,201));
f6 =  figure(6);
mesh(MXX1,MXX2,reshape(Xoutps1.getValues('Sname','out'),201,201));
f7 =  figure(7);
mesh(MXX1,MXX2,reshape(Xoutps2.getValues('Sname','out'),201,201));

