%**************************************************************************
% In this tutorial it is shown how to construct a PolyharmonicSplines object
% and how to use it for approximating of a function
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/@PolyharmonicSplines
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

import opencossan.common.inputs.*
import opencossan.workers.*
import opencossan.common.*
import opencossan.metamodels.*
import opencossan.simulations.*

% Reset the random number generator in order to always obtain the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(51125)

% copy FE-input file with COSSAN-identifiers to working directory
StutorialPath = fileparts(which('TutorialPolyharmonicSplines.m'));

%%  Definition of Inputs

X1 = opencossan.common.inputs.random.UniformRandomVariable('Description','random variable 1',...
    'bounds',[-5, 5]);
X2 = opencossan.common.inputs.random.UniformRandomVariable('Description','random variable 2',...
    'bounds',[-5,5]);
X3 = opencossan.common.inputs.random.UniformRandomVariable('Description','random variable 2',...
    'bounds',[-5,5]);

Xrvset      = opencossan.common.inputs.random.RandomVariableSet('Names',["X1","X2","X3"],'Members',[X1,X2,X3]);
Xin         = Input('Members', {Xrvset}, 'Names', "Xrvset");

%%  Create Mio to Rosenbrock function
Xmio = Mio('FullFileName',[fullfile(opencossan.OpenCossan.getRoot),'/lib/MatlabFunctions/Rosenbrock.m'],...
    'IsFunction',true,...
    'Format','matrix',...
    'Inputnames',{'X1','X2','X3'},...
    'Outputnames',{'out'});

%% Construct the Model
Xev = Evaluator('Xmio',Xmio);
Xmod = Model('Evaluator',Xev,'Input',Xin);

%% Construction and Calibration of Polyharmonic Splines
% In this step, a linear Polyharmonic Splines model is created.
Xps1 = PolyharmonicSplines('Description','quadratic spline of Rosenbrock function',...
    'XfullModel',Xmod,...   %full model
    'InputNames',{'X1' 'X2','X3'},...
    'OutputNames',{'out'},...  %response to be extracted from full model
    'Stype','quadratic',...
    'Sextrapolationtype','quadratic');

Xlhs= LatinHypercubeSampling('Nsamples',400); % simulation obecjt for calibration samples
Xps1 = Xps1.calibrate('XSimulator',Xlhs); % calibrate spline

Xmc=LatinHypercubeSampling('Nsamples',20); % simulation object for validation samples
Xps1 = Xps1.validate('XSimulator',Xlhs); % validate spline

% regression plots for calibration and validation
% because of the nature of splines, the regression plot for calibration is
% perfect (the splines always pass from the support points)
f1=figure(1);
Xps1.plotregression('Stype','calibration','Soutputname','out');
f2=figure(2);
Xps1.plotregression('Stype','validation','Soutputname','out');

% In this step, a Polyharmonic Splines model of power 5 is created
Xps2 = PolyharmonicSplines('Description','power 5 spline of Rosenbrock function',...
    'XfullModel',Xmod,...   %full model
    'InputNames',{'X1' 'X2','X3'},...
    'OutputNames',{'out'},...  %response to be extracted from full model
    'Stype','custom','Nexponent',5);   %type of response surface

Xps2 = Xps2.calibrate('XSimulator',Xlhs); % calibrate spline
Xps2 = Xps2.validate('XSimulator',Xlhs); % validate spline

% regression plots for calibration and validation
f3=figure(3);
Xps2.plotregression('Stype','calibration','Soutputname','out');
f4 =figure(4);
Xps2.plotregression('Stype','validation','Soutputname','out');

%% Apply Polyharmonic Spline
MXX1 = repmat(linspace(-5,5,201),201,1);
MXX2 = MXX1';
MXX3 = ones(201,201);
Vx1=MXX1(:); Vx2 = MXX2(:);Vx3=MXX3(:);
Minput = [Vx1,Vx2,Vx3];

samples = array2table(Minput);
samples.Properties.VariableNames = Xin.InputNames;

Xoutreal = Xmio.run(Minput);

Xoutps1 = Xps1.evaluate(samples);
Xoutps2 = Xps2.evaluate(samples);

f5 = figure(5);
mesh(MXX1,MXX2,reshape(Xoutreal.Samples.out,201,201));
f6 =  figure(6);
mesh(MXX1,MXX2,reshape(Xoutps1.out,201,201));
f7 =  figure(7);
mesh(MXX1,MXX2,reshape(Xoutps2.out,201,201));
%% Validate solution, close figures and delete simulation files

close(f7)
close(f6)
close(f5)
close(f4)
close(f3)
close(f2)
close(f1)



