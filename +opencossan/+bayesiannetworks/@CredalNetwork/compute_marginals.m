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

    observed_low = zeros(length(states), 1);
    observed_hi = zeros(length(states), 1);
    
    prob_low = zeros(length(states),1);
    prob_hi = zeros(length(states),1);
    
    n = length(data);

    for i = 1:length(states)
        num = 0;
        for j = 1:length(data)
            if isequal(data{j},states{i})
                num = num +1;
            end
        end
        observed_low(i) = num;
    end
    
    num_unknown = 0;
    for j = 1:length(data)
        if isequal(data{j},'?')
            num_unknown = num_unknown +1;
        end
    end
    
    observed_hi = observed_low + num_unknown;
    
    for i = 1:length(prob_hi)
    
        k_lo = observed_low(i);
        k_hi = observed_hi(i);
    
        [c_lo, c_hi] = confidence([k_lo, k_hi], [n, n], conf);
        prob_low(i) = c_lo;
        prob_hi(i) = c_hi;
    end

end

