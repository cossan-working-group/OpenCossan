function MarginalProbability=computeMarginal(BN,varargin)
%  Internal method for the class BayesianNetwork and
%  EnhancedBayesianNetwork for the computation of marginal probability of
%  network nodes

%% Process Input
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.BayesianNetwork.computeMarginal';
p.addParameter('NodesNames',@(s)isstring(s)); 
p.addParameter('Vevidence',@(s)isnumeric(s));
p.parse(varargin{:});
% Assign input 
NodesNames      = p.Results.NodesNames;
Vevidence       = p.Results.Vevidence;

ObservedNodes = BN.NodesNames(Vevidence~=0);
[ObservedInMarginal,MarginalInObserved]  = ismember(cellstr(ObservedNodes),NodesNames);

Marginal2Compute = setdiff(NodesNames,ObservedNodes);

RowNames=cell(1,max(BN.NodesSize(ismember(BN.NodesNames,NodesNames))));
RowNames(:)={'state'};
RowNames=matlab.lang.makeUniqueStrings(RowNames,'state');

MarginalProbability=table;

for imarg=1:length(Marginal2Compute)
    MarginalProbabilityValue=BN.computeJointProbability('NodesNames',Marginal2Compute(imarg),...
            'Vevidence',Vevidence);
    MarginalProbability=[MarginalProbability,table([MarginalProbabilityValue;NaN(length(RowNames)-length(MarginalProbabilityValue),1)],...
        'VariableNames',cellstr(Marginal2Compute(imarg)),'RowNames',RowNames)];
end

for iev = 1:length(NodesNames(ObservedInMarginal))
    MarginalProbabilityValue= zeros(BN.NodesSize(ismember(BN.NodesNames,NodesNames(ObservedInMarginal(iev)))),1);
    MarginalProbabilityValue(Vevidence(MarginalInObserved))=1;
    MarginalProbability=[MarginalProbability,table([MarginalProbabilityValue;NaN(length(RowNames)-length(MarginalProbabilityValue),1)],...
        'VariableNames',cellstr(NodesNames(ObservedInMarginal(iev))),'RowNames',RowNames)];
end

end