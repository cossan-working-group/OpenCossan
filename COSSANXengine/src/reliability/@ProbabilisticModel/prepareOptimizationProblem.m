function Xop=prepareOptimizationProblem(Xpm,Mu0)
% This is a private function of the ProbabilisticModel used to tranform a
% Probabilistic problem into a Optimization problem.
% It requires only 1 input, the matrix of initial points (i.e. design
% variables) provided in the exact order as the random variables.
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


%% Extract information from Input
% name of the random variables
XinputDV=Xpm.Xmodel.Xinput;
XinputDV.Xrvset=struct; % Remove RandomVariableSet

% Name of the performance Function
Sperformancefunction=Xpm.XperformanceFunction.Soutputname;
% In order to avoid confusion among the original variables and the auxiliar
% variables used to solve the optimization problem, the design variable are
% have an appendix '_DV'
Cmembers=strcat(Xpm.Xmodel.Xinput.CnamesRandomVariable,'_DV');

% Replace RandomVariable with DesingVariable
% The DesignVariable are defined in Standard Normal Space.
for n=1:length(Cmembers)
    %Tdv.(Cmembers{n})=DesignVariable('value',Mu0(1,n),'Sdescription',['Design Variable associated to ' Cmembers{n} ]);
    Xdv{n}=DesignVariable('value',Mu0(1,n),'Sdescription',['Design Variable associated to ' Cmembers{n} ]);
end

XinputDV=Input('CSmembers',Cmembers,'CXmembers',Xdv);
%XinputDV.XdesignVariable=Tdv;

%% Redifine ProbabilisticModel
%XpmDesignPoint=Xpm;
%XpmDesignPoint.Xmodel.Xinput=XinputDV;


%% Create objective function
% The objective function it is defined in standard normal space. The design
% variables are also defined in standard normal space. Hence no
% transformation is required. 

Xobjfun = ObjectiveFunction('Sdescription','ObjectiveFunction for design point identification (Automatically created by OpenCossan)', ...
    'Liomatrix',true,'Liostructure',false,......
    'Sscript','Moutput=sqrt(sum(Minput.^2,2));',...
    'Cinputnames',Cmembers,...
    'Coutputnames',{'fobj'});

%% Define inequality constraints
% The inequality contraint is the value of the performance function. Here
% the contraint is simply defined as the output of the probabilisitic
% model (named strcat(XperformanceFunction.Soutputname,'Constraint'). 

Xcon   = Constraint('Sdescription','Constrain object for design point identification (Automatically created by OpenCossan)', ...
    'Sscript','Moutput=Minput;',...
    'Cinputnames',{Sperformancefunction},...
    'Liomatrix',true,'Liostructure',false,...
    'Coutputnames',{[Sperformancefunction 'Constraint']}, ...
    'Linequality',true);

%% Define a solution sequence object
% The SolutionSequence object will be used for the evaluation of the
% Constraint. The SolutionSequence takes the current values of the
% DesignVariables and create realizations (samples) of the RandomVariables
% (in standard normal space).  

% Extract Model and Input from ProbabilisticModel
Sstring='Xinput=XprobabilisticModel.Xmodel.Xinput;';
Sstring=strcat(Sstring, 'Xinput.Xsamples=Samples(''Xinput'',Xinput,', ...
    '''Msamplesstandardnormalspace'',[varargin{[',...
    num2str(find(ismember(XinputDV.Cnames,XinputDV.CnamesDesignVariable))),']}]);');

% Run Analysis
Sstring=[Sstring 'Xoutput=XprobabilisticModel.apply(Xinput);'];

% Store in the SimulationData the Input and Output of the solution sequence
Sstring=[Sstring 'COSSANoutput{1}=Xoutput.addData(''Mvalues'',[varargin{[',...
    num2str(find(ismember(XinputDV.Cnames,XinputDV.CnamesDesignVariable))),']}],',...
    '''Cnames'',XobjSolutionSequence.Cinputnames);'];

Xss=SolutionSequence('Sscript',Sstring,'CinputNames', XinputDV.Cnames, ...
    'CoutputNames',{Sperformancefunction},...
    'CobjectsNames',{'Xoutput'},...
    'CprovidedObjectTypes',{'SimulationData'},...
    'CXobjects',{Xpm},...
    'CobjectsTypes',{'ProbabilisticModel'},...
    'CobjectsNames',{'XprobabilisticModel'} );

% Solve probabilistic Model and returns Sperformancefunction
Xop = OptimizationProblem('Sdescription','find Design Point (Automatically created by OpenCossan)', ...
    'Xmodel',Xss,'Xinput',XinputDV,'XobjectiveFunction',Xobjfun,'Xconstraint',Xcon);
end