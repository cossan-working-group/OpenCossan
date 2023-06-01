function varargout=plotCandidateSolutions(Xobj,varargin)
% PLOTEVOLUTION This method plots the evolution of the objective and the
% search variables throughout the optimization process. If the user does
% not specify what extreme is to plot (e.g. the maximum of the objective),
% two plots will be produced: one for the maximum and one for the minimum.
% Every plot has the objective's evolution at the top and the variable's
% evolution just below. Variables evolution will be represented with no
% more than 5 variables on the same plot, meaning, for example, that if 8
% variables are defined 2 sub-plots with 5 and 3 varibles will be produced
% on the same plot. However the user is given the freedom to choose what
% variables and order to plot.

% Author:~Marco~de~Angelis
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
%% Default inputs
NfontSize=14;
LlogPlot=false;
LdoNotPlotObjective=false;
LdoNotPlotVariables=false;
%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'sfigurename'
            SfigureName=varargin{k+1};
        case 'sexportformat'
            Sexportformat=varargin{k+1};
        case 'nfontsize'
            NfontSize=varargin{k+1};
        case 'stitle'
            Stitle=varargin{k+1};
        case 'llogplot'
            LlogPlot=varargin{k+1};
        case 'csnames'
            CSnames=varargin{k+1};
        otherwise
            error('openCOSSAN:Extrema:plotDesignVariable',...
                ['PropetyName (' varargin{k} ') not allowed']);
    end
end

%%




















return