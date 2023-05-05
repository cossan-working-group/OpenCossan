function [conf_lo, conf_hi] = confidence_box(k, n, c)
    %%%
    % Computes a confidence interval from the k out of n c-box.
    %
    %   Both k and n can be uncertain.
    %
    %   k - vector of integers [k_lo, k_hi]
    %   n - vector of integers [n_lo, n_hi]
    %   c - confidence level in [0, 1]
    %%%
    
    c_lo = (100 - c)/2;
    c_hi = 100 - c_lo;
    c_lo = c_lo/100; c_hi = c_hi/100;
    conf_lo = betainv(c_lo, k(1), n(2) - k(1) + 1);
    conf_hi = betainv(c_hi, k(2)+1, max(0, n(1) - k(2)));
    
    if isnan(conf_hi); conf_hi = 1; end
    if isnan(conf_lo); conf_lo = 0; end

end