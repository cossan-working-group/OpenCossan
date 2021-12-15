%%%
%   Getting data from excell
%%%


import opencossan.bayesiannetworks.BayesianNetwork
import opencossan.bayesiannetworks.DiscreteNode
import opencossan.bayesiannetworks.CredalNetwork
import opencossan.bayesiannetworks.CredalNetwork.read_data
import opencossan.bayesiannetworks.CredalNode
opencossan.OpenCossan.getInstance();    % Initialise and add to path

excelsheet = "sample_excell.xlsx";

[weather_states, weather_data] = read_data(excelsheet, "Weather Conditions");

[type_states, type_data] = read_data(excelsheet, "Road Type");

[dist_type, dist_data] = read_data(excelsheet, "Disruption Type");

[condition_type, condition_data] = read_data(excelsheet, "Road Condition");