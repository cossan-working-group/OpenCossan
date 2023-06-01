function [Xout]=computeInference(CN,varargin)
%COMPUTEINFERENCE method of the class CredalNetwork allow to
%compute the inference on a Credal Networks using exact
%inference algorithms (combinatorial approach) or approximate methods. 
%
% MANDATORY ARGUMENTS:
%   -CN         CredalNetwork object (with only discrete nodes,
%               if continuous or bounded nodes are present the network
%               has to be reduced, see method reduceCN )
%
%  OPTIONAL ARGUMENTS:
%   -Evidence   1xn array (where n is the number of nodes of the network)
%               of the evidence values to be introduced in the network.
%               The location of the value in the cellarray has to be coherent with the
%               position of the node in the net.
%               
%   -MarginalProbability  Names of the nodes for which the computation of the marginal
%               distribution is required
%   -JointProbability Names of the nodes for which the computation of the
%               joint distribution is required
%   -Salgorithm Type of inference Algorithm
%
%   See TutorialCredalNetwork for an explicative application 
%
%   Author: Silvia Tolo
%   Institute for Risk and Uncertainty, University of Liverpool, UK
%   email address: openengine@cossan.co.uk
%   Website: http://www.cossan.co.uk
%
%   =====================================================================
%   This file is part of openCOSSAN.  The open general purpose matlab
%   toolbox for numerical analysis, risk and uncertainty quantification.
%   
%   openCOSSAN is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License.
%
%   openCOSSAN is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================


%% Check if the network is suitable for exact inference (only traditional BNs)
if ~isempty(CN.ProbabilisticNodes) || ~isempty(CN.IntervalNodes) || ~isempty(CN.HybridNodes)
    error('openCOSSAN:CredalNetwork:computeInference',...
        'To compute inference the network has to contain only DiscreteNodes and CredalNodes, please reduce the eBN')
end

%% Initialise variables
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.CredalNetwork.computeInference';

% Initialize input
p.addParameter('Algorithm',"JunctionTree", @(s)isstring(s)); 
p.addParameter('MarginalProbability',string,@(s)isstring(s));
p.addParameter('Evidence',[],@(s)isnumeric(s));
p.addParameter('CombLow',[],@(s)isnumeric(s));
p.addParameter('CombUp',[],@(s)isnumeric(s));
p.addParameter('ObservedNodes',string,@(s)isstring(s)); 
p.addParameter('JointProbability',string,@(s)isstring(s));
p.addParameter('useBNT',true, @(s)islogical(s));
p.addParameter('Approximate',false,@(s)islogical(s));
p.parse(varargin{:});

% Assign input 
Algorithm       = p.Results.Algorithm;
MarginalNodes   = p.Results.MarginalProbability;
ObservedNodes   = p.Results.ObservedNodes;
Evidence        = p.Results.Evidence;
JointNodes      = p.Results.JointProbability;
Lbnt            = p.Results.useBNT;
Lapproximate    = p.Results.Approximate;
CombLow         = p.Results.CombLow;
CombUp          = p.Results.CombUp;

%% Build evidence for inference methods
[~,indObserved]=ismember(CN.NodesNames,ObservedNodes);
Vevidence = indObserved;
Vevidence(indObserved~=0) = Evidence(indObserved(indObserved~=0));
if sum(Vevidence)>0
    TableEvidence=array2table(Vevidence(Vevidence~=0),'RowNames',...
        {'ObservedState'},'VariableNames',cellstr(ObservedNodes));
else
    TableEvidence=table;
end

%% Inference
if ~Lapproximate
    % Check if the Bayes' Toolbox for Matlab is installed
    if ~exist('mk_bnet','file')
        error('openCOSSAN:CredalNetwork',...
            'To compute exact inference with the Bayes Toolbox (available at:https://code.google.com/p/bnt/) please add it to the path')
    end
    
    Xout=CN.computeInferenceBNT('Algorithm',Algorithm,'MarginalProbability',MarginalNodes,...
        'Vevidence',Vevidence,'JointProbability',JointNodes,'CombLow',CombLow,'CombUp',CombUp);
    
else
    if ~(Salgorithm=="")

    if ~isempty(CSmarginal)
        Xout=CN.computeMarginal('Names',MarginalProbability);
        
    end
    
    if ~isempty(CSjoint)
        XoutJoint=CN.computeJointProbabilityBounds('Names',JointProbability,'Lnorm',true); 
        Xout.CSnames=XoutJoint.CSnames;
        Xout.MjointDistributionLowerBound=XoutJoint.MjointDistributionLowerBound;
        Xout.MjointDistributionUpperBound=XoutJoint.MjointDistributionUpperBound;
    end
    
    end
% elseif Lexact
%     if ~isempty(CSmarginal)
%         [Xout,Mcomb]=CN.computeExactMarginalBounds('Csquery',CSmarginal);
%     end
%     if ~isempty(CSjoint)
%         XoutJoint=CN.computeExactJointBounds('CSnames',CSjoint);
%         Xout.CSnames=XoutJoint.CSnames;
%         Xout.MjointDistributionLowerBound=XoutJoint.MjointDistributionLowerBound;
%         Xout.MjointDistributionUpperBound=XoutJoint.MjointDistributionUpperBound;
%     end
end









