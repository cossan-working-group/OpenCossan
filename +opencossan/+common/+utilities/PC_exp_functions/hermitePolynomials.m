function Mhermite = hermitePolynomials(Vxi,Norder)
%hermitePolynomials   Evaluate the Hermite Polynomials
%   hermitePolynomials(Vxi,Norder) returns a matrix whose rows contain
%   the Hermite Polynomials H_0, ..., H_p, evaluated
%   at the entries of the column vector Vxi.
%
%   Example:
%   Vxi = [0.1; -0.1]
%   psi = hermitePolynomials(Vxi,2) returns
%   psi = [ 1.0000 0.1000 -0.9900; 1.0000 -0.1000 -0.9900 ], 
%   the first row corresponding to xi(1), the second to x(2).
%
%   The routine is based on the recursive formula: 
%   h_{n+1}(x) = x * h_{n}(x) - n * h_{n-1}(x)
%
%   Note: due to Matlab's index rule the following holds:'
%   h{i} = h_{i-1}, i.e. h{1} = h_0, h{2} = h_1, ...
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

%% Evaluate Hermite Polynomials

Mhermite = ones(length(Vxi),Norder+1);
switch Norder
    case 0
        return
    case 1
        Mhermite(:,2) = Vxi;
        return
    otherwise
        Mhermite(:,2) = Vxi;
        j=3;
        while j <= (Norder+1)
            Mhermite(:,j) = Vxi .* Mhermite(:,j-1) - (j-2)*Mhermite(:,j-2);
            j=j+1;
        end
end
