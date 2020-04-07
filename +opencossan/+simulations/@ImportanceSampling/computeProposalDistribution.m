function obj = computeProposalDistribution(obj, target)
%COMPUTEPROPOSALDISTRIBUTION method.
% This method is used to compute the proposal distribution for the
% ImportaceSampling object.
% The proposal distribution is computed adopting gaussian distributions
% centred on the design point. Hence, the design point of the target object
% is computed.
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/computeProposalDistribution@ImportanceSampling
%
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

validateattributes(target, ...
    {'opencossan.reliability.DesignPoint', ...
     'opencossan.reliability.ProbabilisticModel'}, {'scalar'});
 
if isa(target, 'opencossan.reliability.ProbabilisticModel')
    designPoint = target.designPointIdentification();
else
    designPoint = target;
end

% Define Proposal density from ass gaussian random variables centered around the design point.

mean = designPoint.VDesignPointPhysical;
[~, std] = designPoint.Xinput.getMoments();
names = designPoint.Xinput.RandomInputNames;

members = opencossan.common.inputs.random.RandomVariable.empty(length(mean), 0);
for irv =  1:length(mean)
    members(irv) = opencossan.common.inputs.random.NormalRandomVariable( ...
        'mean',mean(irv),'std',std(irv));
end

obj.ProposalDistribution = opencossan.common.inputs.random.RandomVariableSet('Members', members,...
    'Names', names);


