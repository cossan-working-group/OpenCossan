function [Cmembers,CXrandomVariables] = addall
% This is a private function for the RandomVariableSet class. It extract
% all the RandomVariables present in the base workspace. 
% It returns 2 cell variable:
% Cmembers: names of the RandomVariable
% CXrandomVariables: Cell array of RandomVariable object
% 
%
% See also: https://cossan.co.uk/wiki/index.php/@RandomVariable
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


%% Processing Inputs
% read the content of the basic workspace
Tv=evalin('base', 'whos'); 

ifound=0;
for ick=1:length(Tv)
    if strcmp(Tv(ick).class,'RandomVariable')
        ifound=ifound+1;
        Cmembers{ifound}=Tv(ick).name;					 %#ok<AGROW>
		CXrandomVariables{ifound}=evalin('base',Cmembers{ifound}); %#ok<AGROW>
    end
end
