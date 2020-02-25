function Moutput=gRP24(Minput)
% This function defines the problem RP24. 
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
% Reference: https://rprepo.readthedocs.io/en/latest/reliability_problems.html#sec-rp-24

% gcomp(X)=2.5?0.2357?(X1?X2)+0.00463?(X1+X2?20)4

            
Moutput =  2.5 - 0.2357 * (Minput(:,1) - Minput(:,2)) + ...
            0.00463 * (Minput(:,1)+Minput(:,2) -20) .^4; 

        
