function [prob_low, prob_hi] = compute_marginals(states, data, conf)
    %%%
    %   Given an array of states, and an of data (samples), returns the marginal
    %   probabilities. Samples may have missing data in the form of "?".
    %   Uses c-boxes to compute the confidence interval.   
    %
    %   - states: string array of states
    %   - data: string array of data
    %   - conf: desired confidence level between [0, 1]
    %%%

    import opencossan.bayesiannetworks.CredalNetwork.confidence_box

    num_data = length(data);
    num_states = length(states);

    observed_low = zeros(num_states, 1);
    observed_hi = zeros(num_states, 1);
    
    prob_low = zeros(num_states,1);
    prob_hi = zeros(num_states,1);
    
    
    for i = 1:num_states

        num = sum(data(:) == states{i});
        observed_low(i) = num;

    end
    
    num_unknown = sum(data == "?");
    
    observed_hi = observed_low + num_unknown;
    
    for i = 1:length(prob_hi)
    
        k_lo = observed_low(i);
        k_hi = observed_hi(i);
    
        [c_lo, c_hi] = confidence_box([k_lo, k_hi], [num_data, num_data], conf);
        prob_low(i) = c_lo;
        prob_hi(i) = c_hi;
        
    end
end

