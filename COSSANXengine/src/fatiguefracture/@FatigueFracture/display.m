function display(Xobj)
%DISPLAY  Displays the PARAMETER object
%
%
%   Example: DISPLAY(Xobj) will output the summary of the Xobj object
% =========================================================================


%% 1.   Output to Screen
% 1.1.   Name
cossanDisp(' ');
cossanDisp('===================================================================');
cossanDisp([' FatigueFracture Object  -  Name: ' inputname(1)]);
cossanDisp('===================================================================');
% 1.2.   main paramenters

switch Xobj.solver
    case {'ode113'}
        cossanDisp(' ');
        cossanDisp(' The differential equation solver is Adam-Bashforth-Moulton');
    case {'ode45'}
        cossanDisp(' ');
        cossanDisp(' The differential equation solver is Runge-Kutta');
end

if Xobj.linearSIF
    cossanDisp(' ');
    cossanDisp(' The stress intensity factor is assumed to be linear with respect to the stress');
end

cossanDisp('--------------------------------------------------------------------');

