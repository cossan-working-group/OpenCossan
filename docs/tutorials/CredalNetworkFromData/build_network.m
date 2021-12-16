%%%
%   Get data from excell
%%%


import opencossan.bayesiannetworks.CredalNetwork.read_data

excelsheet = "sample_excell.csv";

%%%
%   read_data will get the unique states and data from "excelsheet". Variable
%   name must be as it appears on the sheet
%%%

[weather_states, weather_data] = read_data(excelsheet, "Weather Conditions");
[type_states, type_data] = read_data(excelsheet, "Road Type");
[dist_type, dist_data] = read_data(excelsheet, "Disruption Type");



%% Build network

import opencossan.bayesiannetworks.CredalNode
import opencossan.bayesiannetworks.CredalNetwork
import opencossan.bayesiannetworks.CredalNetwork.compute_marginals
import opencossan.bayesiannetworks.CredalNetwork.compute_conditionals

c = 95;     % Desired confidence


%%%
%   Road  Types
%%%

[type_prob_low, type_prob_hi] = compute_marginals(type_states, type_data, c);


n = 0;

Num_types = length(type_states);

n = n + 1;
CPD_type_lo = cell(1,Num_types);  
CPD_type_hi = cell(1,Num_types);  

CPD_type_lo(1, 1:Num_types )  = num2cell(type_prob_low);
CPD_type_hi(1, 1:Num_types )  = num2cell(type_prob_hi);
Nodes(1,n) = CredalNode('Name', 'Type', 'CPDLow', CPD_type_lo, 'CPDUp', CPD_type_hi);


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
Nodes(1,n) = CredalNode('Name', 'Weather', 'CPDLow', CPD_weather_lo, 'CPDUp', CPD_weather_hi);

%%%
%   Children nodes
%%%

% Disruption type

parent_states = {type_states, weather_states};
parent_data = {type_data, weather_data};

[cond_lo, cond_hi] = compute_conditionals(parent_states, parent_data, dist_type, dist_data, c);

n = n + 1;

Nodes(1,n) = CredalNode('Name', 'Disruption', 'CPDLow', cond_lo, 'CPDUp', cond_hi, 'Parents', ["Type", "Weather"]);


% Build network
credal_net = CredalNetwork('Nodes', Nodes);

% Visualise
credal_net.makeGraph

%%%
% Do some calculations
%%%

% Compute marginals

tic;    %%%% Compute marginal for disruption
dis_marg = credal_net.computeInference('MarginalProbability', "Disruption", ...
    'useBNT', true, 'Algorithm', "Junction Tree");
toc;

% Condition on some observations

observed_type = "Motorway";
evidence_type = find(type_states == observed_type);

observed_weather = "RAINING WITH HIGH WINDS";
evidence_weather = find(weather_states == observed_weather);

tic;
dis_cond = credal_net.computeInference('MarginalProbability', "Disruption", ...
    'useBNT', true, 'Algorithm', "Junction Tree", 'ObservedNode', ["Type", "Weather"], 'Evidence', [evidence_type, evidence_weather]);
toc;

% Plot distributions


figure('Position', [10 10 900 900])
X = categorical(dist_type);
bar(X,dis_marg.Disruption.UpperBound)
hold on
bar(X,dis_marg.Disruption.LowerBound)
ylabel("probs")
title("Disruption marginal")
h_gca=gca;
h_gca.FontSize=24;

saveas(gcf,"Disruption_marginal"+ string(c) + ".png")


figure('Position', [10 10 900 900])
X = categorical(dist_type);
bar(X,dis_cond.Disruption.UpperBound)
hold on
bar(X,dis_cond.Disruption.LowerBound)
ylabel("probs")
title("Disruption conditioned")
h_gca=gca;
h_gca.FontSize=24;

saveas(gcf,"Disruption_marginal_conditioned"+ string(c) + ".png")
