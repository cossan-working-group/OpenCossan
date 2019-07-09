function Xop=prepareOptimizationProblem(Xcm,MValues)
    % This is a private function of the Convex Model used to tranform a
    % convex model reliability problem into a Optimization problem.
    % It requires only 1 input, the matrix of initial points provided in the
    % exact order as the order of the bounded variables.
    %
    % Author: Silvia Tolo
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
% name of the variables
XinputDV=Xcm.Xinput;
XinputDV.Xbset=struct; % Remove ConvexSet

% Name of the performance Function
Cmembers=strcat(Xcm.Xinput.CnamesIntervalVariable,'_DV');
Xdv=cell(1,length(Cmembers));
%% MValues matrix of values in delta space
for n=1:length(Cmembers)
    Xdv{n}=opencossan.optimization.DesignVariable('value',MValues(1,n),'Sdescription',['Design Variable associated to ' Cmembers{n} ]);
end
% XinputDV.XdesignVariable=Tdv;
XinputDV=opencossan.common.inputs.Input('CSmembers',Cmembers,'CXmembers',Xdv);
%% Redifine ConvexModel
XcmDesignPoint=Xcm;
XcmDesignPoint.Xinput=XinputDV;


%% Create objective function


Xobjfun = opencossan.optimization.ObjectiveFunction('Sdescription','ObjectiveFunction for design point identification (Automatically created by COSSAN)', ...
    'Sformat','matrix',...
    'Sscript','Moutput=sqrt(sum((Minput).^2,2));',...
    'Cinputnames',Cmembers,...
    'Coutputnames',{'fobj'});

%% Define inequality constraints
Xcon   = opencossan.optimization.Constraint('Sdescription','Constrain object for design point identification (Automatically created by COSSAN)', ...
    'Sscript','Moutput=Minput;',...
    'Cinputnames',{Xcm.PerformanceFunctionVariable},...
    'Coutputnames',{[Xcm.PerformanceFunctionVariable 'Constrain']}, ...
    'Sformat','matrix',...
    'Linequality',true);

%% Define a solution sequence object
% The SolutionSequence object will be used in the evaluation of the
% Constraints. It takes the values of the DesignVariable and set the values
% of the RandomVariable to the corresponding values in physical space of the
% DV.


% Extract Model and Input from ConvexModel
Sstring='Xinput=XconvexModel.Xinput;';
Sstring=strcat(Sstring, 'Xinput.Xsamples=opencossan.common.Samples(''Xinput'',Xinput,', ...
    '''Msampleshypersphere'',[varargin{[',...
    num2str(find(ismember(XinputDV.Cnames,XinputDV.CnamesDesignVariable))),']}]);');
% Run Analysis
Sstring=[Sstring 'Xoutput=XconvexModel.apply(Xinput.getTable);'];

% Store in the SimulationData the Input and Output of the solution sequence
Sstring=[Sstring 'COSSANoutput{1}=Xoutput.addData(''Mvalues'',[varargin{[',...
    num2str(find(ismember(XinputDV.CnamesDesignVariable,XinputDV.Cnames))),']}],',...
    '''Cnames'',XobjSolutionSequence.Cinputnames);'];

Xss= opencossan.workers.SolutionSequence('Sscript',Sstring,'CinputNames', XinputDV.CnamesDesignVariable, ...
    'CoutputNames',{Xcm.PerformanceFunctionVariable},... 
    'CobjectsNames',{'Xoutput'},...
    'CprovidedObjectTypes',{'opencossan.common.outputs.SimulationData'},...
    'Cobject2output',{'.TableValues.( Xobj.Coutputnames{iout})'},...
    'CXobjects',{Xcm},...
    'CobjectsTypes',{'opencossan.reliability.ConvexModel'},...
    'CobjectsNames',{'XconvexModel'} );

Xop = opencossan.optimization.OptimizationProblem('Sdescription','find Design Point (Automatically created by COSSAN)', ...
    'Xmodel',Xss,'Xinput',XinputDV,'XobjectiveFunction',Xobjfun,'Xconstraint',Xcon);
end