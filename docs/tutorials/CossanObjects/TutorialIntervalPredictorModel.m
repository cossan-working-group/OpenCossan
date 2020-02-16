%**************************************************************************
% In this tutorial it is shown how to construct a IntervalPredictorModel object 
%
% See Also: 
%  http://cossan.co.uk/wiki/index.php/@IntervalPredictorModel

% Author: Jonathan Sadeghi
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

opencossan.OpenCossan.resetRandomNumberGenerator(0)

%%   Tutorial for the IntervalPredictorModel

display(['Tutorial executed on: ',datestr(now)])

%%    Data on model
%   Here, 4 input parameters (namely load, length of the beam, second
%   moment of inertia of cross section of beam and Young's modulus) of the
%   cantilever beam model are defined
Xin = opencossan.common.inputs.Input('Description','input parameters of cantilever beam model');
XP = opencossan.common.inputs.random.UniformRandomVariable('Description','load at tip of beam',...
    'bounds',[0.5e6, 1.5e6]);
Xh = opencossan.common.inputs.random.UniformRandomVariable('Description','height of cross section of beam',...
    'bounds',[0.2, 0.3]);
Xrvset      = opencossan.common.inputs.random.RandomVariableSet('Names',["Xh","XP"],'Members',[Xh,XP]);
Xin         = add(Xin,'Member',Xrvset,'Name','Xrvset');
XL = opencossan.common.inputs.Parameter('description','length of beam','Value',1);
Xin = add(Xin,'Member',XL,'Name','XL');
XI = opencossan.common.inputs.Function('description','second moment of inertia of beam',...
    'Expression','<&Xh&>.^4/12');
Xin =add(Xin,'Member',XI,'Name','XI');
XE  = opencossan.common.inputs.Parameter('description','Young''s modulus of beam','value',2e11);
Xin =add(Xin,'Member',XE,'Name','XE');

% this parameters are used in the test computation of pf
Xthreshold1 = opencossan.common.inputs.Parameter('description','Define threshold','value',0.01);
Xin =add(Xin,'Member',Xthreshold1,'Name','Xthreshold1');
Xthreshold2 = opencossan.common.inputs.Parameter('description','Define threshold','value',0.017);
Xin =add(Xin,'Member',Xthreshold2,'Name','Xthreshold2');

%%    Evaluator
%   An evaluator based on a mio script is defined. This evaluator
%   calculates the displacement at the tip of a cantilever beam, i.e.
%   displacement = load * length^3 / (3 * Young's modulus * Inertia)
% 
%2.1. Definition of MIO object and construction of evaluator
Xmio = opencossan.workers.MatlabWorker('description','displacement at tip of cantilever beam', ...
        'Script','for i=1:length(Tinput),    Toutput(i).disp  = Tinput(i).XP*Tinput(1).XL^3/(3*Tinput(1).XE*Tinput(i).XI);end',...
        'InputNames',{'XP','XL','XE','XI'},...
        'OutputNames',{'disp'},...
        'Format','structure');
%2.2. Add MIO to evaluator
Xev = opencossan.workers.Evaluator('Description','displacement at tip of cantilever beam','Solver',Xmio);
%2.3. Add Evaluator to a model
Xmod = opencossan.common.Model('Evaluator',Xev,'Input',Xin);


%%    Construction and Training of Interval Predictor Model
%   In this step, the Interval Predictor Model model is created
Xipm     = opencossan.metamodels.IntervalPredictorModel('description',...
    'Interval Predictor Model of tip displacement of cantilever beam',...
    'XfullModel',Xmod,...   %full model
    'InputNames',{'XP' 'Xh'},... 
    'OutputNames',{'disp'},...  %response to be extracted from full model
    'Sbound','upper',... %Do we want to find the upper bound or the lower bound?
    'Nmaximumexponent',2);   %type of Interval Predictor Model
Xipm2     = opencossan.metamodels.IntervalPredictorModel('description',...
    'Interval Predictor Model of tip displacement of cantilever beam',...
    'XfullModel',Xmod,...   %full model
    'InputNames',{'XP' 'Xh'},... 
    'OutputNames',{'disp'},...  %response to be extracted from full model
    'Sbound','upper',... %Do we want to find the upper bound or the lower bound?
    'Nmaximumexponent',2,...%type of Interval Predictor Model
    'chanceConstraint',0.9);   %fraction of data to include in model

Xmc= opencossan.simulations.MonteCarlo('Nsamples',200);

Xipm = Xipm.calibrate('XSimulator',Xmc);
Xipm2 = Xipm2.calibrate('XSimulator',Xmc);

%%  Apply trained Interval Predictor Model meta-model
% the accuracy of the Interval Predictor Model is tested by computing the failure
% probability of the tip-loaded beam. This result is compared with the
% real model
Xpf = opencossan.reliability.PerformanceFunction('OutputName','Vg','Demand','disp','Capacity','Xthreshold1');
Xpm_real = opencossan.reliability.ProbabilisticModel('Model',Xmod,'PerformanceFunction',Xpf);

Xmc=opencossan.simulations.MonteCarlo('Sdescription','Mio evaluation','Nsamples',1000,'Nbatches',1);
Xo_real = Xpm_real.computeFailureProbability(Xmc);

%% Metamodel can also be also combined and used in a Evaluator
XevRS=opencossan.workers.Evaluator('Description','displacement at tip of cantilever beam','Solver',Xipm);
XmodRS= opencossan.common.Model('Evaluator',XevRS,'Input',Xin);
Xpm_metamodel =opencossan.reliability.ProbabilisticModel('Model',XmodRS,'PerformanceFunction',Xpf);
Xo_metamodel = Xpm_metamodel.computeFailureProbability(Xmc);

assert(Xo_metamodel.pfhat>Xo_real.pfhat,'Upperbound on failure probability should be above the actual value')

%Retry with the chance constraints
XevRS2=opencossan.workers.Evaluator('Description','displacement at tip of cantilever beam','Solver',Xipm2);
XmodRS2= opencossan.common.Model('Evaluator',XevRS2,'Input',Xin);
Xpm_metamodel2 = opencossan.reliability.ProbabilisticModel('Model',XmodRS2,'PerformanceFunction',Xpf);
Xo_metamodel2 = Xpm_metamodel2.computeFailureProbability(Xmc);


f1 = Xipm.plotregression();
f2 = Xipm.reliabilityPlot();

f3 = Xipm2.plotregression();
f4 = Xipm2.reliabilityPlot();

%% Close figures
close(f1,f2,f3,f4);