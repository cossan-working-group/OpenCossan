%% Displacement script with noise
%
% This script computes 'n=length(Tinput)' times the displacement (yp) of the 2DOF system    
n=length(Tinput); %Obtain the number of simulations that will be run
%For each simulation
for i=1:n  %Loop to run 'length(Tinput)' times the deterministic analysis
    %Get the input values for each simulation and put in some more readable variable
    k1=Tinput(i).k1;k2=Tinput(i).k2;
    F=[Tinput(i).F1 ; Tinput(i).F2];
    p1=Tinput(i).p1;p2=Tinput(i).p2;
    %Determine the displacements for the 2DOF system (a simple FEA analysis may
    %come here)
    yp=([1.0/k1 1.0/k1; 1.0/k1 (k1+k2)/(k1*k2)])*F;
    %Pass the resulted displacements for each simulation output values added to a aussian noise to
    %the Toutput property for OpenCossan
    Toutput(i).y1=yp(1)+p1;
    Toutput(i).y2=yp(2)+p2;
end