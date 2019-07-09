function Output=computeBNInference(BN,varargin)
%COMPUTEBNINFERENCE method of the class BayesianNetwork allows to
%compute the inference on a traditional Bayesian Network (only discrete nodes) using exact
%inference algorithms. The inference is computed by the Bayes Toolbox
%for Matlab (available at:https://code.google.com/p/bnt/) or built-in methods.
%
%
%   EXAMPLE (see tutorialBayesianNetwork)
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

%% Input
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.BayesianNetwork.computeBNInference';

% Initialize input
p.addParameter('Algorithm',"Variable Elimination", @(s)isstring(s)); 
p.addParameter('MarginalProbability',string,@(s)isstring(s));
p.addParameter('Evidence',[],@(s)isnumeric(s));
p.addParameter('ObservedNodes',string,@(s)isstring(s)); 
p.addParameter('JointProbability',string,@(s)isstring(s));
p.addParameter('useBNT',false, @(s)islogical(s));

p.parse(varargin{:});
% Assign input 
Algorithm       = p.Results.Algorithm;
MarginalNodes   = p.Results.MarginalProbability;
ObservedNodes   = p.Results.ObservedNodes;
Evidence        = p.Results.Evidence;
JointNodes      = p.Results.JointProbability;
Lbnt            = p.Results.useBNT;

% build evidence for inference methods
[~,indObserved]=ismember(BN.NodesNames,ObservedNodes);
Vevidence = indObserved;
Vevidence(indObserved~=0) = Evidence(indObserved(indObserved~=0));

if sum(Vevidence)>0
    TableEvidence=array2table(Vevidence(Vevidence~=0),'RowNames',...
        {'ObservedState'},'VariableNames',cellstr(ObservedNodes));
else
    TableEvidence=table;
end

if Lbnt
    % Check if the Bayes' Toolbox for Matlab is installed
    if ~exist('mk_bnet','file')
        error('openCOSSAN:bayesiannetworks',...
            'To compute the inference of the BN the Bayes Toolbox (available at:https://code.google.com/p/bnt/) has to be included in the Matlab path')
    end
    
    [TableMarginal,TableJoint]=BN.computeInferenceBNT('Algorithm',Algorithm,...
        'MarginalProbability',MarginalNodes,...
        'Vevidence',Vevidence,'JointProbability',JointNodes);
    
    Output = opencossan.bayesiannetworks.InferenceOutput('MarginalProbability',TableMarginal,...
            'Evidence',TableEvidence,'JointProbability',TableJoint,...
            'Info', array2table(["Variable Elimination";"Built-in"],'VariableNames',...
            {'AnalysisDetails'}, 'RowNames',{'InferenceAlgorithm','InferenceTool'} ));
elseif ~Lbnt
    if ~all(MarginalNodes == '')
        MarginalProbability=BN.computeMarginal('NodesNames',MarginalNodes,'Vevidence',Vevidence);
       
        Output = opencossan.bayesiannetworks.InferenceOutput('MarginalProbability',MarginalProbability,...
            'Evidence',TableEvidence,...
            'Info', array2table(["Variable Elimination";"Built-in"],'VariableNames',...
            {'AnalysisDetails'}, 'RowNames',{'InferenceAlgorithm','InferenceTool'} ));
    end
    
    if ~all(JointNodes == '')
        [JointProbabilityValues,JointNodes]=BN.computeJointProbability('NodesNames',JointNodes,'Vevidence',Vevidence);
        TableJoint=cell2table({JointNodes,JointProbabilityValues},'VariableNames',{'NodesName','ProbabilityValues'});
        Output = opencossan.bayesiannetworks.InferenceOutput('JointProbability',TableJoint,...
            'Evidence',TableEvidence,...
            'Info', array2table(["Variable Elimination";"Built-in"],'VariableNames',...
            {'AnalysisDetails'}, 'RowNames',{'InferenceAlgorithm','InferenceTool'} ));
        
    end
end









