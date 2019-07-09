%%   Tutorial for the NeuralNetwork 
%
%   A meta model for the displacement at the tip of a cantilever beam is
%   created. This tutorial shows how to calibrate and validate the
%   meta-model and finally how to used it as a workers. 
%
% See Also: http://cossan.co.uk/wiki/index.php/@NeuralNetwork
%
%
%   Copyright 2015 Cossan Working Group, University of Liverpool, UK
%
% Contact: *Edoardo Patelli*
% email   : openengine@cossan.co.uk
% website : http://www.cossan.co.uk
clear
close all
clc;

import common.inputs.*
import common.Model.*
import metamodels.*
import workers.*
import simulations.*
import reliability.*


display(['Tutorial executed on: ',datestr(now)])

%%    Data on model
%   Here, 4 input parameters (namely load, length of the beam, second
%   moment of inertia of cross section of beam and Young's modulus) of the
%   cantilever beam model are defined
Xin = opencossan.common.inputs.Input('description','input parameters of cantilever beam model');
XP = opencossan.common.inputs.random.UniformRandomVariable('description','load at tip of beam',...
    'Bounds',[0.5e6, 1.5e6]);
Xh = opencossan.common.inputs.random.UniformRandomVariable('description','height of cross section of beam',...
    'Bounds',[0.2, 0.3]);
Xrvset      = opencossan.common.inputs.random.RandomVariableSet('names',{'Xh','XP'},'members',[Xh;XP]);
Xin         = add(Xin,'member',Xrvset,'name','Xrvset');
XL = opencossan.common.inputs.Parameter('description','length of beam','value',1);
Xin = add(Xin,'member',XL,'name','XL');
XI = opencossan.common.inputs.Function('description','second moment of inertia of beam',...
    'expression','<&Xh&>.^4/12');
Xin = add(Xin,'member',XI,'name','XI');
XE  = opencossan.common.inputs.Parameter('description','Young''s modulus of beam','value',2e11);
Xin = add(Xin,'member',XE,'name','XE');

% this parameters are used in the test computation of pf
Xthreshold1 = opencossan.common.inputs.Parameter('description','Define threshold','value',0.016);
Xin = add(Xin,'member',Xthreshold1,'name','Xthreshold1');
Xthreshold2 = opencossan.common.inputs.Parameter('description','Define threshold','value',0.017);
Xin = add(Xin,'member',Xthreshold2,'name','Xthreshold2');

%%    Evaluator
%   An evaluator based on a mio script is defined. This evaluator
%   calculates the displacement at the tip of a cantilever beam, i.e.
%   displacement = load * length^3 / (3 * Young's modulus * Inertia)
% 
%2.1. Definition of MIO object and construction of evaluator
Xmio = opencossan.workers.Mio('description','displacement at tip of cantilever beam', ...
        'Script','for i=1:length(Tinput),    Toutput(i).disp  = Tinput(i).XP*Tinput(1).XL^3/(3*Tinput(1).XE*Tinput(i).XI);end',...
        'InputNames',{'XP','XL','XE','XI'},...
        'OutputNames',{'disp'},...
        'Format','structure');
%2.2. Add MIO to evaluator
Xev = opencossan.workers.Evaluator('Sdescription','displacement at tip of cantilever beam','XMio',Xmio);
%2.3. Add Evaluator to a model
Xmod = opencossan.common.Model('XEvaluator',Xev,'Xinput',Xin);


%%    Construction and Training of Neural network
%   In this step, the response surface model is created
Xnn = opencossan.metamodels.NeuralNetwork('description','Neural network of tip displacement of cantilever beam',...
    'Stype','HyperbolicTangent',...
    'OutputNames',{'disp'},...  %response to be extracted from full model
    'InputNames',{'XP' 'Xh'},...
    'XFullmodel',Xmod,...
    'Vnnodes',[2, 3, 1],...
    'Vnormminmax',[-0.8 0.8]);

Xmc=LatinHypercubeSampling('Nsamples',200);
Xnn = Xnn.calibrate('XSimulator',Xmc);

Xmc=MonteCarlo('Nsamples',40);
Xnn = Xnn.validate('XSimulator',Xmc);

%%  Apply trained Neural network meta-model
% the accuracy of the neural network is tested by computing the failure
% probability of the tip-loaded beam. This result is compared with the
% real model
Xpf = PerformanceFunction('OutputName','Vg','Demand','disp','Capacity','Xthreshold1');
Xpm_real = ProbabilisticModel('XModel',Xmod,'XPerformanceFunction',Xpf);
Xev_metamodel= Evaluator('Sdescription','displacement at tip of cantilever beam','Xmetamodel',Xnn);
Xmetamodel = Model('XEvaluator',Xev_metamodel,'Xinput',Xin);
Xpm_metamodel = ProbabilisticModel('Xmodel',Xmetamodel,'XPerformanceFunction',Xpf);

Xmc=MonteCarlo('Sdescription','Mio evaluation','Nsamples',1000,'Nbatches',1);
Xo_real = Xpm_real.computeFailureProbability(Xmc)
Xmc=MonteCarlo('Sdescription','NN evaluation','Nsamples',1000,'Nbatches',1);
Xo_metamodel = Xpm_metamodel.computeFailureProbability(Xmc)
