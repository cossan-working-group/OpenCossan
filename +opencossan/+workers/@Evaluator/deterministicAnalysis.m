function XSimOut = deterministicAnalysis(Xobj,Xinput)
%DETERMINISTICANALYSIS Perform deterministic Analysis of the evaluater
%  This method execute the analysis of the connectors defined in the evaluator
%  with the default (deterministic) values.
% The methods required an Input object.
%
% See also: http://www.cossan.co.uk/wiki/index.php/deterministicAnalysis@Evaluator
%
% Author: Edoardo Patelli 
% Copyright~1993-2015, COSSAN Working Group, University of Liverpool, UK
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

%% Check inputs
assert(isa(Xinput,'opencossan.common.inputs.Input'), ...
    'Evaluator:deterministicAnalysis', ...
    'An input object is required to perform the deterministic analysis');

%% Retrieve default (nominal values)
if isempty(Xinput.Names)
    TableInput=table;
else
    TableInput=Xinput.getDefaultValuesTable;
end

% Perform analysis
XSimOut=Xobj.apply(TableInput);
