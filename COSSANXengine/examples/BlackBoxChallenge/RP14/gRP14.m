function Moutput=gRP14(Minput)
% This function defines the problem RP14. 
% Requires 5 inputs and provides 1 output

%     Performance function for reliability problem 14
% 
%     Parameters
%     ----------
%         Minput : Values of independent variables: columns are the
%         different parameters/random variables (x1, x2,...xn) and rows are
%         different parameter/random variables sets for different calls.  
% 
%     Returns
%     -------
%         Moutput : Performance function value for the system.
%
% Reference: https://rprepo.readthedocs.io/en/latest/reliability_problems.html#sec-rp-14

            
Moutput =   Minput(:,1) - ...
            32./(pi.*Minput(:,2).^3) .* ...
            sqrt( (Minput(:,3).^2 .* Minput(:,4).^2)/16 + Minput(:,5).^2 ); 
