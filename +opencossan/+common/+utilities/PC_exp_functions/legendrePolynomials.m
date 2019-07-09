function Mlegendre = legendrePolynomials(Vxi,Norder)
%legendrePolynomials   Evaluate the Legendre Polynomials
%   legendrePolynomials(Vxi,Norder) returns a matrix whose rows contain
%   the Legendre Polynomials P_0, ..., P_p, evaluated
%   at the entries of the column vector xi.
%
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================

%% Check xi

if size(Vxi,2) ~= 1
    error('xi must be a column vector')
end

%% Create the polynomials

Mlegendre = zeros(length(Vxi),Norder+1);

for i = 1:(Norder+1)
    if i == 1
        Mlegendre(:,i) = 1;
    elseif i == 2
        Mlegendre(:,i) = Vxi;
    else
        Mlegendre(:,i) = ( (2*i-3)*Vxi.*Mlegendre(:,(i-1)) - (i-2)*Mlegendre(:,i-2) )./(i-1);
    end
end




