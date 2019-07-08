%**************************************************************************
% In this tutorial it is shown how to construct a ResponseSurface object and
% how to use it for approximating the response computed by a FE-analysis
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

%% THIS TUTORIAL REQUIRES FEAP!!!!

% Please use the tutorial TutorialPolyharmonicSplines for creating a 
% metamodel without a 3rd party solver.

% Reset the random number generator in order to always obtain the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)

% copy FE-input file with COSSAN-identifiers to working directory
StutorialPath = fileparts(which('TutorialResponseSurface.m'));
copyfile(fullfile(StutorialPath, 'Connector','FEAP','Ibeam.cossan'),...
    fullfile(OpenCossan.getCossanWorkingPath),'f');


%%  Definition of the Input
% Random variables

Xh          = RandomVariable('Sdescription','height of cross section of beam',...
    'Sdistribution','uniform','par1',0.2,'par2',0.3);
XP          = RandomVariable('Sdescription','load at tip of beam',...
    'Sdistribution','uniform','par1',0.5e6,'par2',1.5e6);

Xrvset      = RandomVariableSet('Cmembers',{'Xh','XP'});
Xin         = Input;            %Create empty Input object
Xin         = Xin.add('Xmember',Xrvset,'Sname','Xrvset');  %add RandomVariableSet to Input object

% this parameters are used in the test computation of pf
Xthreshold = Parameter('Sdescription','Define threshold','value',0.022);
Xin         = Xin.add('Xmember',Xthreshold,'Sname','Xthreshold'); 

%% Definition of the interface for with 3rd party solver  
% Create Injector
Xi  = Injector('Sscanfilepath', OpenCossan.getCossanWorkingPath, ...
               'Sscanfilename','Ibeam.cossan', ...
               'Sfile','Ibeam');

%  Create Response & Extractor
% Response related with displacement at tip of the beam
Xresp1  = Response('Sdescription','displacement at tip of the beam',...
    'Sname', 'disp', ...
    'Sfieldformat', '%e', ...
    'Clookoutfor',{'N o d a l   D i s p l a c e m e n t s'}, ...
    'Ncolnum',46, ...
    'Nrownum',5);

% Extractor object
Xe      = Extractor('Sdescription','object for extracting response of cantilever beam', ...
    'Lverbose',true,'Sfile','Obeam','Xresponse',Xresp1);

%  Create Connector
% Basic set up
Xc  = Connector('SpredefinedType','feap','Lkeepsimulationfiles',false,...
    'Smaininputpath',OpenCossan.getCossanWorkingPath,'Smaininputfile','Ibeam');

% Add injector
Xc      = add(Xc,Xi);
% Add extractor to the connector
Xc      = add(Xc,Xe);

Xout=Xc.deterministicAnalysis;
Xout.Tvalues
%% Construct the Evaluator and Model object
Xev     = Evaluator('Xconnector',Xc);
Xmod    = Model('Xevaluator',Xev,'Xinput',Xin);


%% Construction and Calibration of Response surface
% In this step, the response surface model is created
Xrs     = ResponseSurface('Sdescription',...
    'response surface of tip displacement of cantilever beam',...
    'XfullModel',Xmod,...   %full model
    'Cinputnames',{'Xh' 'XP'},... 
    'Coutputnames',{'disp'},...  %response to be extracted from full model
    'Stype','custom',...
    'Nmaximumexponent',4);   %type of response surface

Xmc=MonteCarlo('Nsamples',20); % simulation obecjt for calibration samples
Xrs = Xrs.calibrate('XSimulator',Xmc); % calibrate response surface

% alternatively it is possible to pass the SimulationData to the calibrate
% method
XsimData=Xmc.apply(Xmod);
Xrs = Xrs.calibrate('XsimulationData',XsimData); % calibrate response surface

Xmc=MonteCarlo('Nsamples',20); % simulation object for validation samples
Xrs = Xrs.validate('XSimulator',Xmc); % validate response surface

% regression plots for calibration and validation
Xrs.plotregression('Stype','calibration','Soutputname','disp');

Xrs.plotregression('Stype','validation','Soutputname','disp');


%% Apply response surface
% the accuracy of the neural network is tested by computing the failure
Xrs     = ResponseSurface('XfullModel',XrboProblem.Xmodel,...   %full model
    'Cinputnames',{'XdvA1' 'XdvA2' 'XdvA3'},... 
    'Coutputnames',{'pf'},...  %response to be extracted from full model
    'Stype','quadratic');   %type of response surface% probability of the tip-loaded beam. This result is compared with the
% real model

% performance function (threshold value defined above as maximum displacement)
Xpf = PerformanceFunction('Sdemand','disp','Scapacity','Xthreshold','SoutputName','Vg');

% probabilistic model using full model
Xpm_real = ProbabilisticModel('XModel',Xmod,'XPerformanceFunction',Xpf);

% probabilistic model using response surface
Xpm_metamodel = ProbabilisticModel('XModel',Xrs,'XPerformanceFunction',Xpf);

% simulation object (failure probability is computed by using direct MCS)
Xmc=MonteCarlo('Nsamples',1000,'Nbatches',1);

Xpf_real = pf(Xpm_real,Xmc); % compute failure probability of full model
Xpf_metamodel = pf(Xpm_metamodel,Xmc); % compute failure probability using response surface

display(Xpf_real)
display(Xpf_metamodel)

%% Validate solution, close figures and delete simulation files

close(f1)
close(f2)

delete([OpenCossan.getCossanWorkingPath '/Ibeam.*']);

assert(abs(Xpf_real.pfhat-Xpf_metamodel.pfhat)<5.e-3, ...
       'CossanX:Tutorials:TutorialDataseries', ...
       'Accuracy of output of metamodel too low')
   
   
