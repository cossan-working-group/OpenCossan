function level = getCoverageLevel(coverage)
%GETCOVERAGELEVEL Summary of this function goes here
%   Detailed explanation goes here
level = 'medium';
if (coverage >= 0.8)
    level = 'high';
elseif (coverage <  0.5)
    level = 'low';
end
end

