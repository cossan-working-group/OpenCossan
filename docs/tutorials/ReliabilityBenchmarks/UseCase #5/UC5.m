%% Reliability analysis of a multiple beta-points performance function
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example #3 (pag.267-268) from the paper:
% "A benchmark study on importance sampling techniques in structural
% reliability" S.Engelung and R. Rackwitz. Structural Safety, 12 (1993)
% Reference solution Pf ~ 3e-7. Please note that the paper of Engelung
% reports a wrong value equal to 1.451e-6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The performance function is an hyperbola
%
%
% Author: Edoardo Patelli
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
%
disp('');
disp('--------------------------------------------------------------------------------------------------');
disp('USE CASE #5: Multiple design point');
disp('--------------------------------------------------------------------------------------------------');


%% Define the input parameters
% In this example there are 5 random variable (standard normal) and 4
% limit state functions. 
P=Parameter('Sdescription','P','value',14.614); 
L=Parameter('Sdescription','L','value',10.0); 
X1=RandomVariable('Sdistribution','normal','mean',78064.4,'std',11709.7); 
X2=RandomVariable('Sdistribution','normal','mean',0.01004,'std',1.56e-3); 
% Definition of Set of IID random variables 
Xrvs = RandomVariableSet('CXrv',{X1 X2},'Cmembers',{'X1','X2'});
% Define Input
Xin = Input('XRandomVariableSet',Xrvs,'Cxmembers',{P L},'CSmembers',{'P' 'L'});

%%  Definition of Mio objects
% The mio object contains the performance fucntion

Xmg4=Mio('Sdescription', 'Performance function g4', ...
        'Sscript','Moutput=Minput(:,1).*Minput(:,2)-Minput(:,3).*Minput(:,4);', ...
        'Lfunction',false,'Liostructure',false,'Liomatrix',true, ...
        'Coutputnames',{'g4'},...
        'Cinputnames',{'X1' 'X2' 'P' 'L'});	
			
% Define Performance Functions
XperfunG4=PerformanceFunction('Xmio',Xmg4);

% Construct the evaluators
% The evaluator is empty since there is no model to be evaluated.
Xev= Evaluator;

% Define the Models
Xmdl= Model('Xevaluator',Xev,'Xinput',Xin);

% Define Single Probabilistic Model 
% this probabilistic model contain the performance function defined by the
% intersection of the performance functions (i.e. max)
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',XperfunG4);

% %% Compute reference solution
% % This analysis might take up to 5 minutes on a resonable machines 
% Xmc=MonteCarlo('Nsamples',1e7,'Nbatches',10);
% XpfMC=Xpm.computeFailureProbability(Xmc);
% display(XpfMC)
NsamplesMC=1e7;
pfMC=3e-7;

CoV=sqrt(NsamplesMC*pfMC*(1-pfMC))/(NsamplesMC*pfMC);

XpfMC=FailureProbability('pf',pfMC,'variancePf',(pfMC*CoV)^2,'Nsamples',NsamplesMC,'Smethod','MonteCarlo');
% 
% %% Compute failure probability by means of Importance sampling 
% % compute the failure probability with the Importance sampling method
% Xis=ImportanceSampling('Nsamples', 1e4, 'LcomputeDesingPoint',true);
% XpfIS=Xpm.computeFailureProbability(Xis);
% display(XpfIS)
%% Compute failure probability by means of classic SubSet simulation
% compute the failure probability with the Importance sampling method
Xss=SubSet('Nmaxlevels',7,'target_pf',0.1,'Ninitialsamples',500,'Nbatches',1,'Vdeltaxi',.2);
[XpfSS,XoutSS]=Xpm.computeFailureProbability(Xss);
display(XpfSS)

% plot rejection rate
display(XoutSS.VrejectionRates)
sprinf('Rejected samples: %i',length(XoutSS.VrejectedSamplesIndices))

%% Plot figures
XoutSS.plotLevels('Smarker','.','Sfigurename','StandardSS_levels','Lseeds',false)
HfigureChains=XoutSS.plotMarkovChains('Smarker','.','Cnames',{'X1','X2'});
Haxes=get(HfigureChains,'CurrentAxes');

%% Create countour plot
% create mesh
[x,y]=meshgrid(-6:0.1:3,-6:0.1:3);
z=(x*11709.7+78064.4).*(y*0.00156+0.0104)-146.14;
V=linspace(min(min(z)),max(max(z)),10);
[C,h] =contour(Haxes,(x*11709.7+78064.4),(y*0.00156+0.0104),z,XoutSS.VsubsetThreshold,'ShowText','on');
saveas(HfigureChains,'StandardSS_levels_contour','eps')
saveas(HfigureChains,'StandardSS_levels_contour','fig')

% 
saveas(HfigureChains,'StandardSS_levels_contour6','eps')


%% Test new subset algorithms
XssVar=SubSet('Nmaxlevels',10,'target_pf',0.1, ...
    'Ninitialsamples',450, 'Nbatches',1,'VproposalVariance',[0.5]);
[XpfSSVar,XoutSSVar]=Xpm.computeFailureProbability(XssVar);
display(XpfSSVar)
% plot rejection rate
display(XoutSSVar.VrejectionRates)
XoutSSVar.VsubsetThreshold


% The figure shows the increase of dispersion due to the proposal variance
XoutSSVar.plotLevels('Smarker','.','Lseeds',false,'Stitle','Subset Canonical Algorithm')
HfigureChains=XoutSSVar.plotMarkovChains('Smarker','.','Cnames',{'X1','X2'},'Lconnectchains',false,'Stitle','Subset Canonical Algorithm');
Haxes=get(HfigureChains,'CurrentAxes');

%[x,y]=meshgrid(-6:0.1:3,-6:0.1:3);
%z=(x*11709.7+78064.4).*(y*0.00156+0.0104)-146.14;
%V=linspace(min(min(z)),max(max(z)),10);
[C,h] =contour(Haxes,(x*11709.7+78064.4),(y*0.00156+0.0104),z,XoutSSVar.VsubsetThreshold,'ShowText','on');
saveas(HfigureChains,'SSnew_levels_contour','eps')
saveas(HfigureChains,'SSnew_levels_contour','fig')

% Create figure for standard SS implementation
figure
[C,h] =contour(x,y,z,XoutSS.VsubsetThreshold,'ShowText','on');

% Compute and report summarry summary 
disp(sprintf('         | Monte Carlo   | SubSet MCMC   | SubSet Canonical'))
disp(sprintf(' Pf      |%e | %e  | %e ',XpfMC.pfhat,XpfSS.pfhat,XpfSSVar.pfhat))
disp(sprintf(' CoV     |%e | %e  | %e ',XpfMC.cov,XpfSS.cov,XpfSSVar.cov))
disp(sprintf(' Samples |%e | %e  | %e ',XpfMC.Nsamples,XpfSS.Nsamples,XpfSSVar.Nsamples))
