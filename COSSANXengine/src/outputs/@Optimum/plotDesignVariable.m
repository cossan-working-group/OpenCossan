function varargout=plotDesignVariable(Xobj,varargin)
% plotDesignVariable This method plots the evolution of the design variable
%
% See Also: OPTIMUM, TutorialOptimum
% https://cossan.co.uk/wiki/index.php/plotDesignVariable@Optimum
%
% Author: Edoardo Patelli 

%{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.
    
    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

%% Prepare variable

% Check Design Variables
Cnames=[];

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'cnames'
            Cnames=varargin{k+1};
        case 'sname'
            Cnames=varargin(k+1);
    end
end

if isempty(Cnames)
    varargin{end+1}='Cnames';
    varargin{end+1}=Xobj.CdesignVariableNames;
else
    assert(all(ismember(Cnames,Xobj.CdesignVariableNames)),...
    'Optimum:plotDesignVaraible',...
    ['Design variable(s) not available\n', ...
    'Required variables: %s \nAvailable variables: %s'],sprintf('"%s" ',Cnames{:}),sprintf('"%s" ',Xobj.CdesignVariableNames{:}))

end

%% Prepare variables
varargin{end+1}='VXdata';
varargin{end+1}=Xobj.TablesValues.Iteration;

varargin{end+1}='MYdata';
varargin{end+1}=Xobj.TablesValues.DesignVariables;

varargin{end+1}='Sylabel';
varargin{end+1}='Design Variables';

% Plot figure
varargout{:}=plotOptimum(Xobj,varargin{:});

end

