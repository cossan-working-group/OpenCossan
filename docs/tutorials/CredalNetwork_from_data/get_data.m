%%%
%   Getting data from excell
%%%


import opencossan.bayesiannetworks.BayesianNetwork
import opencossan.bayesiannetworks.DiscreteNode
import opencossan.bayesiannetworks.CredalNetwork
import opencossan.bayesiannetworks.CredalNetwork.get_data_excell
import opencossan.bayesiannetworks.CredalNode
opencossan.OpenCossan.getInstance();    % Initialise and add to path

excelsheet = "sample_excell.xlsx";

[weather_states, weather_data] = get_data_excel(excelsheet, "Weather Conditions");

[hierarchy_states, hierarchy_data] = get_data_excel(excelsheet, "Maintenance Hierarchy");

[dist_type, dist_data] = get_data_excel(excelsheet, "Disruption Type");

[condition_type, condition_data] = get_data_excel(excelsheet, "Road Condition");

[distruption, distruption_data] = get_data_excel(excelsheet, "Disruption Caused");




% Sometimes further clean-up is required
for i = 1:length(weather_data)
    if weather_data{i} == "UNKNOWN"
        weather_data{i} = '?';
    end
end

weather_states = setdiff(weather_states, "UNKNOWN");

ids = distruption_data == "false";
dist_data(ids) = "6 - NO DISRUPTION";

dist_type = [dist_type; "6 - NO DISRUPTION"];