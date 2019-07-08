% This script is used to compute the infection parameter Y
% Minput is a matlab array of size (Nsamples,Ninputs) and Moutput is the
% computed quantity of interest of size (Nsamples,Noutput)
%
% Here the order of the input factore are: 'Szero' 'gamma' 'kappa'  'r' 'delta'
% Y=gamma*kappa*S0-r-delta



Moutput=Minput(:,2).* Minput(:,3).* Minput(:,1)-Minput(:,4) - Minput(:,5);
