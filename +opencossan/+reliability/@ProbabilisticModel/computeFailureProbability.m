function pf = computeFailureProbability(Xpm,Xsimulation)
%COMPUTEFAILUREPROBABILITY this method estimate the failure probabilitiy of the
%probabilistic, Xpm, using a specific Simulations object passed as mandatory
%argument (Xsimulation).
%
% The method return a ProbabilisticModel as first output argument and a
% SimulationData as a second output argument.
%
%
% EXAMPLES:
% [Xopf] = Xpm.computeFailureProbability(Xmcs)
% [Xopf,Xout] = Xpm.computeFailureProbability(XimportanceSampling)
%
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/computeFailureProbability@ProbabilisticModel
%
% $Copyright~1993-2015,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
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

%% Check input
assert(isa(Xsimulation,'opencossan.simulations.Simulations'),...
    'openCOSSAN:ProbabilisticModel:computeFailureProbability',...
    ['The object ', inputname(2) ' must be a sub-class of Simulation'])

%% Estimate the FailureProbability
pf = Xsimulation.computeFailureProbability(Xpm);
