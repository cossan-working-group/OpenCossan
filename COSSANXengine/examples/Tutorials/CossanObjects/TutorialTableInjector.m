%% Tutorial for the TableInjector object
%
% This turorial shows how to create and use an TableInjector object
% The TableInjector is used to store variable in a tabular format.
% 
% WARNING: All the existing data to an file will be overwritten
%
% The injector is never used directly but it is embedded in a Connector
% object.
%
% See Also:  TutorialConnector TutorialInjector TutorialExtractor 
%
% $Copyright~2006-2018,~COSSAN~Working~Group$
% $Author: Edoardo-Patelli$ 

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

%% Example script for the connector
%
% input file name testTableInjector.txt 
%

%% WARNING
Sfolder=fileparts(mfilename('fullpath'));% returns the current folder

%%  Create the Injector
SfilePath= fullfile(Sfolder,'Connector','testTableInjector.txt');

%% Define a TableInjector

Xin=TableInjector('Sfile','testTableInjector.txt','Stype','matlab8',...
    'CinputNames',{'mat1','mat2'});
display(Xin)

%% Example: Random Material
% In this example a random material (i.e. random field) is created
% injecting integer random numbers (1 or 2), and creating a plate where the
% material of the elements is randomly chosen between the two avaialable
% material. 

% Create Parameters
mat1=Parameter('value',7E+7);
mat2=Parameter('value',2E+7);
% Create uniform discrete random variable with value 1 and 2
rv=RandomVariable('Sdistribution','uniformdiscrete','parameter1',0,'Parameter2',2);
% Create a set of 256 identically distributed random varaibles. The name of
% the random variable is automaticall set adding "_i" to the name of the
% original random variable (in this case rv -> rv_1 ... rv_256)
rvset1=RandomVariableSet('Cmembers',{'rv'},'Nrviid',256);

Xinp = Input('CXmembers',{mat1,mat2,rvset1},...
    'CSmembers',{'mat1','mat2','rvset1'});
Xinp = Xinp.sample('Nsamples',1);

Tinput=Xinp.getStructure;

% Write testTableInjector.txt in CWD
Xin.inject(Tinput)

%% Use TableInjector with stochastic process
% This part of the tutorial shows how to use a TableInjector Object to
% write realizations of  StochasticProcess in a ASCII file and in
% tabular format 

% define Input
Emod  = RandomVariable('Sdistribution','normal','mean',200.E9,'std',200E8);
density  = RandomVariable('Sdistribution','normal','mean',7800.,'std',780.);
Cmems   = {'Emod'; 'density'};
Xrvs1     = RandomVariableSet('Cmembers',Cmems);
Xin     = Input('CXmembers',{Xrvs1},'CSmembers',{'Xrvs1'});


% Definition of stochastic process
Xcovfun  = CovarianceFunction('Sdescription','covariance function', ...
    'Lfunction',false,'Liostructure',true,'Liomatrix',false,...
    'Cinputnames',{'t1','t2'},... % Define the inputs
    'Sscript', 'sigma = 1; b = 0.5; for i=1:length(Tinput), Toutput(i).fcov  = sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1)); end', ...
    'Coutputnames',{'fcov'}); % Define the outputs
time   = 0:0.001:0.5;
SP1    = StochasticProcess('Sdistribution','normal','Vmean',1.0,'Xcovariancefunction',Xcovfun,'Mcoord',time,'Lhomogeneous',true);
SP1    = KL_terms(SP1,'NKL_terms',30,'Lcovarianceassemble',false);
Xin    = add(Xin,'Xmember',SP1,'Sname','SP1');

SP2    = StochasticProcess('Sdistribution','normal','Vmean',5.0,'Xcovariancefunction',Xcovfun,'Mcoord',time,'Lhomogeneous',true);
SP2    = KL_terms(SP2,'NKL_terms',20,'Lcovarianceassemble',false);
Xin    = add(Xin,'Xmember',SP2,'Sname','SP2');

% Define a TableInjector
XtableInjector=TableInjector('Sfile','testTableInjector.txt',...
    'CSheaderlines',{'% Example of header (line 1)', '% Line 2'},...
    'Stype','matlab16',...
    'Linjectcoordinates',true,...
    'CinputNames',{'SP1'});

% Add the TableInjector into a connector
Xconn1 = Connector('Smaininputpath',pwd,...
'Smaininputfile','testTableInjector.txt',...
    'Sexecmd','time','Xinjector',XtableInjector);

% Generate sample
Xin=Xin.sample('Nsamples',3);

% Run a FAKE simulations 
XSimOut = run(Xconn1,Xin);

% Testing different TableInjectors
Tinput=Xin.getStructure;

% The stochastic process has 501 points for each realisation. 
XtableInjector1=TableInjector('Sfile','testTableInjector.txt',...
    'CSheaderlines',{'% Example of header (line 1)', '% Coordinates and values'},...
    'Stype','matlab16',...
    'Linjectcoordinates',false,...
    'CinputNames',{'SP1' 'SP2'});

% Write testTableInjector.txt in CWD
XtableInjector1.inject(Tinput(1))

% Write testTableInjector.txt with coordinates
XtableInjector1.LinjectCoordinates=true;
XtableInjector1.inject(Tinput(1))
