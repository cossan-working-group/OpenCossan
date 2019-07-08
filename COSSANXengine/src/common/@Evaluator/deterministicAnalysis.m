function XSimOut = deterministicAnalysis(Xobj,Xinput)
%DETERMINISTICANALYSIS Perform deterministic Analysis of the evaluater
%  This method execute the analysis of the connectors defined in the evaluator
%  with the default (deterministic) values.
% The methods required an Input object.


%% Check inputs
assert(isa(Xinput,'Input'), ...
    'openCOSSAN:Evaluator:deterministicAnalysis', ...
    'An input object is required to perform the deterministic analysis');

%% Retrieve default (nominal values)
if isempty(Xinput.Cnames)
    Tinput=struct;
else
    Tinput=Xinput.get('defaultvalues');
end

% Perform analysis
XSimOut=Xobj.apply(Tinput);
