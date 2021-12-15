%%%
%   Getting data for iris dataset
%%%


import opencossan.bayesiannetworks.BayesianNetwork
import opencossan.bayesiannetworks.DiscreteNode
import opencossan.bayesiannetworks.CredalNetwork
import opencossan.bayesiannetworks.CredalNetwork.get_data_excell
import opencossan.bayesiannetworks.CredalNode
opencossan.OpenCossan.getInstance();    % Initialise and add to path

xcellsheet = "../All_Flooding_RIS.xlsx";

[weather_states, weather_data] = CredalNetwork.get_data_excell(xcellsheet, "Weather Conditions");

[hierarchy_states, hierarchy_data] = get_data_excell(xcellsheet, "Maintenance Hierarchy");

[dist_type, dist_data] = get_data_excell(xcellsheet, "Disruption Type");

[condition_type, condition_data] = get_data_excell(xcellsheet, "Road Condition");

[distruption, distruption_data] = get_data_excell(xcellsheet, "Disruption Caused");




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