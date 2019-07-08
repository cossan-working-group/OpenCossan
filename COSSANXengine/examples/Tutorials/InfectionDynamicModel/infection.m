function [Y] = infection(Szero,gamma,kappa,r,delta)
%INFECTION This 
%   Detailed explanation goes here
   Y=gamma.*kappa.*Szero-r-delta;

end

