function Moutput=gRP8(Mx)
% Performance function for reliability problem 8.
% 
% Parameters:	x (numpy.array of float(s)) ? Values of independent variables: columns are the different parameters/random variables (x1, x2,?xn) and rows are different parameter/random variables sets for different calls.
% Returns:	
% g_val_sys (numpy.array of float(s)) ? Performance function value for the system.
% g_val_comp (numpy.array of float(s)) ? Performance function value for each component.
% msg (str) ? Accompanying diagnostic message, e.g. warning.
% 
% Reference:
% https://rprepo.readthedocs.io/en/latest/reliability_problems.html#sec-rp-8


Moutput = Mx(:,1) + 2*Mx(:,2) + 2*Mx(:,3) + Mx(:,4) - 5*Mx(:,5) - 5*Mx(:,6);

