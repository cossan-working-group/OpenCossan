function [prob_low, prob_hi] = compute_conditionals(parent_states, parent_data, node_states, node_data, conf)
    %%%
    %   Given a call array of states, a call array of data (samples), node states,
    %   and node data, computes the CPT. Samples may have missing data in the form of "?", in
    %   both node data and parent data
    %   Uses c-boxes to compute the confidence interval.   
    %
    %   - parent_states: cell of string array
    %   - parent_data: cell of string array
    %   - node_states: cell of string array
    %   - node_data: cell of string array
    %   - conf: desired confidence level between [0, 1]
    %
    %%%

    import opencossan.bayesiannetworks.CredalNetwork.confidence_box

    num_states = [];
    num_states_node = length(node_states);
    num_samples = length(parent_data{1});
    for i = 1:length(parent_states)
        num_states = [num_states, length(parent_states{i})];
    end

    prob_low = cell([num_states, length(node_states)]);
    prob_hi = cell([num_states, length(node_states)]);
    

    for ii = 1:length(parent_states)
        elems{ii} = 1:num_states(ii);
    end
    
    combinations = cell(1, numel(elems));
    [combinations{:}] = ndgrid(elems{:});
    
    combinations = cellfun(@(x) x(:), combinations,'uniformoutput',false);
    combins = [combinations{:}];
    
    for i = 1:length(parent_states)
        misses{i} = parent_data{i} == "?";
    end

    for i = 1:length(combins)

        for j = 1:length(parent_states)
            bools1{j} = parent_data{j} == parent_states{j}(combins(i,j));
            bools2{j} = bools1{j} | misses{j};
        end

        bools_only = bools1{1};
        bools_misses = bools2{1};

        for j = 2:length(parent_states)
            bools_only = bools_only .* bools1{j};
            bools_misses = bools_misses .* bools2{j};
        end
        
        cond_samples = node_data(bools_only == 1);
        cond_samples2 = node_data(bools_misses == 1);

        observed_low = zeros(num_states_node, 1);
        observed_high = zeros(num_states_node, 1);

        for ii = 1:num_states_node
            num = 0;
            for jj = 1:length(cond_samples)
                if isequal(cond_samples(jj), node_states{ii})
                    num = num + 1;
                end
            end
            observed_low(ii) = num;
        end
        
        for ii = 1:num_states_node
            num = 0;
            for jj = 1:length(cond_samples2)
                if isequal(cond_samples2(jj), node_states{ii})
                    num = num + 1;
                end
            end
            observed_high(ii) = num;
        end
        
        num_unknown = 0;

        for ii = 1:length(cond_samples2)
            if isequal(cond_samples2(ii), "?")
                num_unknown = num_unknown + 1;
            end
        end
        
        observed_high = observed_high + num_unknown;
        
        n_lo = length(cond_samples);
        n_hi = length(cond_samples2);

        for ii = 1:length(observed_high)

            k_lo = observed_low(ii);
            k_hi = observed_high(ii);
            
            [cond_lo, cond_hi] = confidence_box([k_lo, k_hi], [n_lo, n_hi], conf);
            

            indexes = num2cell([combins(i,:), ii]);

            prob_low(indexes{:}) = {cond_lo};
            prob_hi(indexes{:}) = {cond_hi};
        end

    end
end