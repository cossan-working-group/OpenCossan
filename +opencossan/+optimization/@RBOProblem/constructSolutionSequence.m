function Xss=constructSolutionSequence(Xobj)
% CONSTUCTSOLUTIONSEQUENCE This function is used to create a
% SolutionSequence object required to evaluate the inner loop in the
% RBO analysis.
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/constructSolutionSequence@RBOproblem
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

% Predefine variables
Cinputs=Xobj.Cmapping(:,1);

% Extract Model and Input from ProbabilisticModel
Sstring='Xinput=XprobabilisticModel.Xmodel.Xinput;';
Sstring=[Sstring 'XperformanceFunction=XprobabilisticModel.XperformanceFunction;'];
Sstring=[Sstring 'Xmodel=XprobabilisticModel.Xmodel;'];
if isa(Xobj.XprobabilisticModel.Xmodel,'Model')
    Sstring=[Sstring 'Xevaluator=Xmodel.Xevaluator;'];
end

%% Update Input object
% The current values of the input objects are updated according to the
% values provided by the outer loop.
for n=1:size(Xobj.Cmapping,1)
    Sstring=[Sstring sprintf(['Xinput=Xinput.' ...
        'set(''SobjectName'',''%s'',' ...
        '''SpropertyName'',''%s'',''value'',varargin{%i});'],...
        Xobj.Cmapping{n,2}, Xobj.Cmapping{n,3},n)]; %#ok<AGROW>
end

%% Reconstruct Model
if isa(Xobj.XprobabilisticModel.Xmodel,'Model')
    Sstring=[Sstring 'Xmodel=Model(''Xinput'',Xinput,''Xevaluator'',Xevaluator);'];
elseif isa(Xobj.XprobabilisticModel.Xmodel,'MetaModel')
    Sstring=[Sstring 'Xmodel.Xinput=Xinput;'];
end

% Reconstruct ProbabilisticModel
Sstring=[Sstring 'XprobabilisticModel=ProbabilisticModel(''XperformanceFunction'',XperformanceFunction,''Xmodel'',Xmodel);'];

% Run Analysis
if isempty(Xobj.CSprobabilisticModelValues)
    Sstring=[Sstring 'COSSANoutput{1}=XprobabilisticModel.computeFailureProbability(Xsimulator);'];
    
    Xss=SolutionSequence('Sscript',Sstring,'CinputNames', Cinputs, ...
        'Coutputnames',{Xobj.SfailureProbabilityName },...
        'Cobject2output',{'.pfhat'}, ...
        'CobjectsNames',{'XfailureProbability'},...
        'CprovidedObjectTypes',{'FailureProbability'},...
        'CXobjects',{Xobj.XprobabilisticModel Xobj.Xsimulator},...
        'CobjectsTypes',{'ProbabilisticModel' 'Simulations'},...
        'CobjectsNames',{'XprobabilisticModel', 'Xsimulator'} );
else
    
    Sstring=[Sstring '[COSSANoutput{1} XsimulationData]=' ...
                'XprobabilisticModel.computeFailureProbability(Xsimulator);'];
    Cobject2output={'.pfhat'};
    
    % Cycle over all the others required inputs (extracted from the SimulationData object
    for n=2:length(Xobj.CSprobabilisticModelValues)+1
        Sstring=[Sstring 'COSSANoutput{' num2str(n) '}=XsimulationData;'];
        CprovidedObjectTypes(n) = {'SimulationData'};
        Cobject2output(n) = {['.getValues(''Sname'',''' Xobj.CSprobabilisticModelValues{n-1} ''')']};
    end
    
    Xss=SolutionSequence('Sscript',Sstring,'CinputNames', Cinputs, ...
        'Coutputnames',[{Xobj.SfailureProbabilityName} Xobj.CSprobabilisticModelValues],...
        'Cobject2output',Cobject2output, ...
        'CobjectsNames',{'XfailureProbability' 'XsimulationData'},...
        'CprovidedObjectTypes',CprovidedObjectTypes,...
        'CXobjects',{Xobj.XprobabilisticModel Xobj.Xsimulator},...
        'CobjectsTypes',{'ProbabilisticModel' 'Simulations'},...
        'CobjectsNames',{'XprobabilisticModel', 'Xsimulator'} );
end