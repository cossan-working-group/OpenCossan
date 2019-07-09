%% Loop A
% The inner loop is a simple MonteCarlo simulations
%% Input definition
% Young's moduli - gaussian rvs, mean 1e7, cov 5%
E = RandomVariable('Sdistribution','normal','mean',1e7,'std',0.05*1e7);
% create a random variable set with 25 independent, identically distributed
% random variables
Xrvset1 = RandomVariableSet('CXrv',{E},'Cmembers',{'E'},'Nrviid',25);
% force spherical angle deviation: uniform, +- 5 degrees
theta = RandomVariable('Sdistribution','uniform','parameter1',-5/180*pi,'parameter2',5/180*pi);
phi = RandomVariable('Sdistribution','uniform','parameter1',-5/180*pi,'parameter2',5/180*pi);
Xrvset2 = RandomVariableSet('CXrv',{theta,phi},'Cmembers',{'theta','phi'});
Fx = Function('Sexpression','-100e3*cos(<&phi&>)*sin(<&theta&>)');
Fy = Function('Sexpression','-100e3*sin(<&phi&>)*sin(<&theta&>)');
Fz = Function('Sexpression','-100e3*cos(<&theta&>)');

% get the values of the design variables from the outer loop
A1 = Parameter('value',varargin{1});
A2 = Parameter('value',varargin{2});
A3 = Parameter('value',varargin{3});
A4 = Parameter('value',varargin{4});
A5 = Parameter('value',varargin{5});
A6 = Parameter('value',varargin{6});

XinpA = Input('CXmembers',{Xrvset1,Xrvset2,Fx,Fy,Fz,A1,A2,A3,A4,A5,A6},...
    'CSmembers',{'Xrvset1','Xrvset2','Fx','Fy','Fz','A1','A2','A3','A4','A5','A6'});

%% Mio definition
XmioA = Mio('Spath',[OpenCossan.getCossanRoot 'examples/Tutorials/SixSigma'],...
    'Sfile','TrussMaxDisp.m',...
    'Lfunction',true,...
    'LIOstructure',true,...
    'CinputNames',{'E_1','E_2','E_3','E_4','E_5','E_6','E_7','E_8','E_9','E_10',...
    'E_11','E_12','E_13','E_14','E_15','E_16','E_17','E_18','E_19','E_20',...
    'E_21','E_22','E_23','E_24','E_25','theta','phi'},...
    'CoutputNames',{'maxDisp','beamVolumes'});

%% Model definition
XevalA = Evaluator('CXmembers',{XmioA},'CSnames',{'XmioA'});
XmodelA = Model('Xevaluator',XevalA,'Xinput',XinpA);

%% Montecarlo
XmcA = MonteCarlo('Nsamples',1000);
XsimOut = XmcA.apply(XmodelA); 
COSSANoutput{1}= XsimOut; % this will be used to get the displacements
COSSANoutput{2}= XsimOut; % this will be used to get the volumes of the beams