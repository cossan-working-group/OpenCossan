%% This function provides the response for MIO

% displacement
for i=1:length(Tinput)
    Toutput(i).disp = abs(-11*Tinput(i).force*100^3 /...
                         (768 * Tinput(i).youngs * Tinput(i).inertia )); %#ok<SAGROW>
end
