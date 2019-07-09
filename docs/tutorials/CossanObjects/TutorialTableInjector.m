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
% See Also:  TutorialConnector
%
% $Copyright~1993-2015,~COSSAN~Working~Group,~University~of~Liverpool,~UK,EU$
% $Author:~Edoardo~Patelli$
% $email address: openengine@cossan.co.uk$
% $Website: http://www.cossan.co.uk$

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
close all
clear
clc;
%% Example script for the connector
%
% input file name testTableInjector.txt 
%

%%  Create the Injector
% The folder that contains the testTableInjector.txt should be in
% [COSSANROOT]/examples/Tutorials/CossanObjects/
Sfilename='testTableInjector.txt';
SfilePath= fullfile(opencossan.OpenCossan.getWorkingPath,Sfilename);

%% Define a TableInjector

Xin=opencossan.workers.ascii.TableInjector('Sfile','testTableInjector.txt','Stype','matlab8',...
    'CinputNames',{'mat1','mat2'});
display(Xin)

% Specify the path
Xin.Sworkingdirectory=opencossan.OpenCossan.getWorkingPath;


%% Example: Random Material
% In this example a random material (i.e. random field) is created
% injecting integer random numbers (1 or 2), and creating a plate where the
% material of the elements is randomly chosen between the two avaialable
% material. 

% Create Parameters
mat1=opencossan.common.inputs.Parameter('value',7E+7);
mat2=opencossan.common.inputs.Parameter('value',2E+7);
% Create uniform discrete random variable with value 1 and 2
rv=opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0, 2]);
% Create a set of 256 identically distributed random varaibles. The name of
% the random variable is automaticall set adding "_i" to the name of the
% original random variable (in this case rv -> rv_1 ... rv_256)
rvset1=opencossan.common.inputs.random.RandomVariableSet('names',{'rv'},'members',rv);

Xinp = opencossan.common.inputs.Input('members',{mat1,mat2,rvset1},...
    'membersnames',{'mat1','mat2','rvset1'});
Xinp = Xinp.sample('Nsamples',1);

% This object works only with structures
Tinput=Xinp.getStructure;
Xin.doInject(Tinput)

% Check the written file
assert(logical(exist(fullfile(OpenCossan.getCossanWorkingPath,Sfilename),'file')),...
    'OpenCossan:Tutorial:CossanObject:TableInject:nofilecreated',...
    'No table created')

% Check the file
VloadedTable=load(fullfile(OpenCossan.getCossanWorkingPath,Sfilename));

Vexpected=Xinp.getValues('Cnames',{'mat1' 'mat2'});
assert(all(Vexpected==VloadedTable),...
    'OpenCossan:Tutorial:CossanObject:TableInject:wrongWrittenValues',...
    'Written values : [%e %e]\nExpected values: [%e %e]',...
    Vexpected(1),Vexpected(2),VloadedTable(1),VloadedTable(2))

% Remove created file
delete(fullfile(OpenCossan.getCossanWorkingPath,Sfilename));

%% USAGE OF TABLEINJECTOT AND STOCHASTICPROCESS
% This part of the tutorial shows how to use a TableInjector Object to
% write the realization of a StochasticProcess in a ASCII file and in
% tabular format 

% define Input
Emod  = RandomVariable('Sdistribution','normal','mean',200.E9,'std',200E8);
density  = RandomVariable('Sdistribution','normal','mean',7800.,'std',780.);
Cmems   = {'Emod'; 'density'};
Xrvs1     = RandomVariableSet('Cmembers',Cmems);
Xin     = Input;
Xin     = add(Xin,'Xmember',Xrvs1,'Sname','Xrvs1');

% Definition of stochastic process
Xcovfun  = CovarianceFunction('Sdescription','covariance function', ...
    'Lfunction',false,'Sformat','structure',...
    'Cinputnames',{'t1','t2'},... % Define the inputs
    'Sscript', 'sigma = 1; b = 0.5; for i=1:length(Tinput), Toutput(i).fcov  = sigma^2*exp(-1/b*abs(Tinput(i).t2-Tinput(i).t1)); end', ...
    'Coutputnames',{'fcov'}); % Define the outputs
time   = 0:0.001:0.5;
SP1    = StochasticProcess('Sdistribution','normal','Vmean',1.0,'Xcovariancefunction',Xcovfun,'Mcoord',time,'Lhomogeneous',true);
SP1    = KL_terms(SP1,'NKL_terms',30,'Lcovarianceassemble',false);
Xin     = add(Xin,'Xmember',SP1,'Sname','SP1');


SP2    = StochasticProcess('Sdistribution','normal','Vmean',5.0,'Xcovariancefunction',Xcovfun,'Mcoord',time,'Lhomogeneous',true);
SP2    = KL_terms(SP2,'NKL_terms',20,'Lcovarianceassemble',false);
Xin     = add(Xin,'Xmember',SP2,'Sname','SP2');

% Define a TableInjector
XtableInjector=TableInjector('Sfile','testTableInjectorSP.txt','Stype','matlab16',...
    'CinputNames',{'SP1','SP2'});

% Specify the path
XtableInjector.Sworkingdirectory=OpenCossan.getCossanWorkingPath;


% Add the TableInjector into a connector
Xconn1 = Connector(...
    'Smaininputpath',fullfile(OpenCossan.getCossanRoot,'examples','Tutorials','CossanObjects','Connector','ABAQUS'),...
    'Smaininputfile','crane.cossan',...
    'Sexecmd','time', ...
    'Xinjector',XtableInjector);

% Generate sample
Xin=Xin.sample('Nsamples',3);

% Run a FAKE simulations 
XSimOut = run(Xconn1,Xin);
