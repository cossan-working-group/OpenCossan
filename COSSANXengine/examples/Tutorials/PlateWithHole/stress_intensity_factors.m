function y = stress_intensity_factors( Tstruct )
% Stress intensity factors in an infinite plate, with two non interacting
% cracks


% dummy Memory
Cdummy=num2cell(zeros(length(Tstruct),1));
y=struct('sif1_max',Cdummy,'sif2_max',Cdummy,'delta_sif1',Cdummy,'delta_sif2',Cdummy);


for i=1:length(Tstruct)

w = Tstruct(i).w;
smin = Tstruct(i).smin;
smax = Tstruct(i).smax;
a1 = Tstruct(i).a1;
a2 = Tstruct(i).a2;

sif1min = sqrt(2*tan(pi*a1/2/w))/cos(pi*a1/2/w) * (0.752 + 2.02*(a1/w) + .37*(1-sin(pi*a1/2/w))^3) * smin *sqrt(pi*a1);
sif2min = sqrt(2*tan(pi*a2/2/w))/cos(pi*a2/2/w) * (0.752 + 2.02*(a2/w) + .37*(1-sin(pi*a2/2/w))^3) * smin *sqrt(pi*a2);


sif1max = sqrt(2*tan(pi*a1/2/w))/cos(pi*a1/2/w) * (0.752 + 2.02*(a1/w) + .37*(1-sin(pi*a1/2/w))^3) * smax *sqrt(pi*a1);
sif2max = sqrt(2*tan(pi*a2/2/w))/cos(pi*a2/2/w) * (0.752 + 2.02*(a2/w) + .37*(1-sin(pi*a2/2/w))^3) * smax *sqrt(pi*a2);

y(i).sif1_max   = sif1max;
y(i).sif2_max   = sif2max;
y(i).delta_sif1 = sif1max - sif1min;
y(i).delta_sif2 = sif2max - sif2min;

end

