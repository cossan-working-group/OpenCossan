%%%%%% 
%   Bayesian netork from excell dataset
%%%%%%

get_data

% Import

import opencossan.bayesiannetworks.BayesianNetwork
import opencossan.bayesiannetworks.DiscreteNode
import opencossan.bayesiannetworks.CredalNode
import opencossan.bayesiannetworks.CredalNetwork
import opencossan.bayesiannetworks.CredalNetwork.compute_marginals
import opencossan.bayesiannetworks.CredalNetwork.compute_conditionals
import opencossan.bayesiannetworks.CredalNetwork.confidence_box

opencossan.OpenCossan.getInstance();    % Initialise and add to path

% Construct marginal input probabilities

c = 95;     % Desired confidence



%%%
%   Road  Hierarchy
%%%

[hierarchy_prob_low, hierarchy_prob_hi] = compute_marginals(hierarchy_states, hierarchy_data, c);


n = 0;

Num_hierarchy = length(hierarchy_states);

n = n + 1;
CPD_hier_lo = cell(1,Num_hierarchy);  
CPD_hier_hi = cell(1,Num_hierarchy);  

CPD_hier_lo(1, 1:Num_hierarchy )  = num2cell(hierarchy_prob_low);
CPD_hier_hi(1, 1:Num_hierarchy )  = num2cell(hierarchy_prob_hi);
Nodes(1,n) = CredalNode('Name', 'hierarchy', 'CPDLow', CPD_hier_lo, 'CPDUp', CPD_hier_hi);


%%%
%   Weather conditions
%%%

[weather_prob_low, weather_prob_hi] = compute_marginals(weather_states, weather_data, c);


Num_weather = length(weather_states);

n = n + 1;
CPD_weather_lo = cell(1,Num_weather);  
CPD_weather_hi = cell(1,Num_weather);  

CPD_weather_lo(1, 1:Num_weather )  = num2cell(weather_prob_low);
CPD_weather_hi(1, 1:Num_weather )  = num2cell(weather_prob_hi);
Nodes(1,n) = CredalNode('Name', 'weather', 'CPDLow', CPD_weather_lo, 'CPDUp', CPD_weather_hi);

%%%
% Children nodes 
%%%


parent_states = {hierarchy_states, weather_states};
parent_data = {hierarchy_data, weather_data};

[cond_lo, cond_hi] = compute_conditionals(parent_states, parent_data, dist_type, dist_data, c);


n = n + 1;

Nodes(1,n) = CredalNode('Name', 'Disruption', 'CPDLow', cond_lo, 'CPDUp', cond_hi, 'Parents', ["hierarchy", "weather"]);

credal_net = CredalNetwork('Nodes', Nodes);

credal_net.makeGraph


tic;    %%%% Compute marginal for disruption
dis_marg = credal_net.computeInference('MarginalProbability', "Disruption", ...
    'useBNT', true, 'Algorithm', "Junction Tree");
toc;
