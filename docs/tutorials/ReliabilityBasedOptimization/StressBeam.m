function Toutput = StressBeam(Tinput)

Toutput = struct;

for i=1:length(Tinput)
    
    % computation of maximum stress in clamped beam due to tip load
    stress = 6*Tinput(i).F*Tinput(i).l/(Tinput(i).b*Tinput(i).h^2);
    Toutput(i).sigma = stress;
    
end

return;