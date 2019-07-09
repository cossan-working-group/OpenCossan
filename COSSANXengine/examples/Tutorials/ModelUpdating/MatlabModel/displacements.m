%% Displacement script
%
% This script computes the displacement (yp) of the 2DOF system    

%For each simulation
for n=1:length(Tinput)  %Loop to run 'length(Tinput)' times the deterministic analysis
    %Get the input values for each simulation and put in some more readable variable
    k1=Tinput(n).k1;
    k2=Tinput(n).k2; 
    F=[Tinput(n).F1 ; Tinput(n).F2];
    %Determine the displacements for the 2DOF system (a simple FEA analysis may
    %come here)
    yp=([1.0/k1 1.0/k1; 1.0/k1 (k1+k2)/(k1*k2)])*F;
    %Pass the resulted displacements for each simulation output values to
    %the Toutput property for OpenCossan
    Toutput(n).y1=yp(1);
    Toutput(n).y2=yp(2);
end