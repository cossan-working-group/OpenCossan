function Xss=constructSolutionSequence(Xobj)
%CONSTRUCTSOLUTIONSEQUENCE method. This method generate a SolutionSequence
%object necessary to perform Robust Design Analysis
% 
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/constructSolutionSequence@RobustDesign
%
% Author: Edoardo Patelli & Matteo Broggi
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theoptimization
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

import opencossan.workers.SolutionSequence

% Extract Model and Input from Model
Sstring='Xinput=Xmodel.Xinput;';
Sstring=[Sstring 'Xevaluator=Xmodel.Xevaluator;'];

% Update Input object 
for n=1:size(Xobj.Cmapping,1)
  Sstring=[Sstring sprintf(['Xinput=Xinput.' ...
      'set(''SobjectName'',''%s'',' ...
      '''SpropertyName'',''%s'',''value'',varargin{%i});'],...
      Xobj.Cmapping{n,2}, Xobj.Cmapping{n,3},n)]; %#ok<*AGROW>
end

% Reconstruct Model
Sstring=[Sstring 'Xmodel=opencossan.common.Model(''Xinput'',Xinput,''Xevaluator'',Xevaluator);'];

% % Construct Montecarlo object
% Sstring=[Sstring 'Xmontecarlo=MonteCarlo(''Nsamples'',' num2str(Xobj.Nsamples) ');'];
% Run Analysis
Sstring=[Sstring 'XsimulationData=Xsimulator.apply(Xmodel);'];
for ioutput=1:length(Xobj.CSinnerLoopOutputNames)
    Sstring=[Sstring 'COSSANoutput{' num2str(ioutput) '}=XsimulationData;'];
    CprovidedObjectTypes(ioutput) = {'opencossan.common.outputs.SimulationData'};
    Cobject2output(ioutput) = {['.getValues(''Sname'',''' Xobj.CSinnerLoopOutputNames{ioutput} ''')']};
end
Cinputs=Xobj.Cmapping(:,1);
    
Xss=SolutionSequence('Sscript',Sstring,...
    'CinputNames', Cinputs, ...
    'Coutputnames',Xobj.CSinnerLoopOutputNames,...
    'Cobject2output',Cobject2output, ...
    'CobjectsNames',{'Xmodel', 'Xsimulator'},...
    'CXobjects',{Xobj.XinnerLoopModel Xobj.Xsimulator},...
    'CobjectsTypes',{'opencossan.common.Model' 'opencossan.simulations.Simulations'},...
    'CprovidedObjectTypes',CprovidedObjectTypes);

end
