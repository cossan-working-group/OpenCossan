%**************************************************************************
% In this tutorial it is shown how to construct a ResponseSurface object 
%
% See Also: 
% http://cossan.cfd.liv.ac.uk/wiki/index.php/@ResponseSurface

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
import opencossan.common.inputs.random.UniformRandomVariable
import opencossan.workers.*
import opencossan.common.*
import opencossan.metamodels.*
import opencossan.simulations.*
import opencossan.reliability.*

opencossan.OpenCossan.resetRandomNumberGenerator(0)

%%   Tutorial for the ResponseSurface

display(['Tutorial executed on: ',datestr(now)])

%%    Data on model
%   Here, 4 input parameters (namely load, length of the beam, second
%   moment of inertia of cross section of beam and Young's modulus) of the
%   cantilever beam model are defined
Xin = Input('Description','input parameters of cantilever beam model');
XP = opencossan.common.inputs.random.UniformRandomVariable('Description','load at tip of beam',...
    'bounds',[0.5e6 1.5e6]);
Xh = opencossan.common.inputs.random.UniformRandomVariable('Description','height of cross section of beam',...
    'bounds', [0.2 0.3]);
Xrvset      = opencossan.common.inputs.random.RandomVariableSet('Names',["Xh","XP"],'Members',[Xh, XP]);
Xin         = add(Xin,'Member',Xrvset,'Name','Xrvset');
XL = Parameter('description','length of beam','Value',1);
Xin = add(Xin,'Member',XL,'Name','XL');
XI = Function('description','second moment of inertia of beam',...
    'Expression','<&Xh&>.^4/12');
Xin = add(Xin,'Member',XI,'Name','XI');
XE  = Parameter('description','Young''s modulus of beam','value',2e11);
Xin = add(Xin,'Member',XE,'Name','XE');

% this parameters are used in the test computation of pf
Xthreshold1 = Parameter('description','Define threshold','value',0.01);
Xin = add(Xin,'Member',Xthreshold1,'Name','Xthreshold1');
Xthreshold2 = Parameter('description','Define threshold','value',0.017);
Xin = add(Xin,'Member',Xthreshold2,'Name','Xthreshold2');

%%    Evaluator
%   An evaluator based on a mio script is defined. This evaluator
%   calculates the displacement at the tip of a cantilever beam, i.e.
%   displacement = load * length^3 / (3 * Young's modulus * Inertia)
% 
%2.1. Definition of MIO object and construction of evaluator
Xmio = Mio('Description','displacement at tip of cantilever beam', ...
        'Script','for i=1:length(Tinput),    Toutput(i).disp  = Tinput(i).XP*Tinput(1).XL^3/(3*Tinput(1).XE*Tinput(i).XI);end',...
        'InputNames',{'XP','XL','XE','XI'},...
        'OutputNames',{'disp'},...
        'Format','structure');
%2.2. Add MIO to evaluator
Xev = opencossan.workers.Evaluator('sdescription','displacement at tip of cantilever beam','XMio',Xmio);
%2.3. Add Evaluator to a model
Xmod = Model('Evaluator',Xev,'Input',Xin);


%%    Construction and Training of response surface
%   In this step, the response surface model is created
Xrs     = opencossan.metamodels.ResponseSurface('sdescription',...
    'response surface of tip displacement of cantilever beam',...
    'XfullModel',Xmod,...   %full model
    'Cinputnames',{'XP' 'Xh'},... 
    'Coutputnames',{'disp'},...  %response to be extracted from full model
    'Stype','custom',...
    'Nmaximumexponent',4);   %type of response surface

Xmc=LatinHypercubeSampling('Nsamples',200);
Xrs = Xrs.calibrate('XSimulator',Xmc);

Xmc=MonteCarlo('Nsamples',40);
Xrs = Xrs.validate('XSimulator',Xmc);

%%  Apply trained response surface meta-model
% the accuracy of the response surface is tested by computing the failure
% probability of the tip-loaded beam. This result is compared with the
% real model
Xpf = PerformanceFunction('OutputName','Vg','Demand','disp','Capacity','Xthreshold1');
Xpm_real = ProbabilisticModel('Model',Xmod,'PerformanceFunction',Xpf);

Xmc=MonteCarlo('Sdescription','Mio evaluation','Nsamples',1000,'Nbatches',1);
Xo_real = Xpm_real.computeFailureProbability(Xmc)

%% Metamodel can also be also combined and used in a Evaluator
XevRS=Evaluator('Sdescription','displacement at tip of cantilever beam','Xmetamodel',Xrs);
XmodRS= Model('Evaluator',XevRS,'Input',Xin);
Xpm_metamodel = ProbabilisticModel('Model',XmodRS,'PerformanceFunction',Xpf);
Xo_metamodel = Xpm_metamodel.computeFailureProbability(Xmc)

Xrs.plotregression
