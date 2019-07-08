function b = matrixVectorProduct(x,Npccoefficients,NinputApproximationOrder,Vcijk_i,Vcijk_j,Vcijk_k,Vcijk,MKnominal,CMKi,Ndofs,...
                      Vci2jk,Vci2jk_i,Vci2jk_j,Vci2jk_k,CMKii)

%
% MATVECPROD performs the matrix vector production required within the
%            iterative solution process for P-C expansion. This iterative
%            solution procedure is applied to solve the system of equations
%            resulting from P-C expansion. The full size matrices are never 
%            assembled during this procedure for memory allocation reason.  
%
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================

[ix jx] = size(x);
if not(ix==Npccoefficients*Ndofs) || not(jx==1)
    error('x has not the right size');
end  
    
b = zeros(Npccoefficients*Ndofs,1); %vector storing matvec prod.

% Notation is as follows:
% 
% System to be solved => Ax=b
%
% where A = cijk * K_i, x = u_k, b = f_k
%
% b_start: starting index for b at iteration i
% b_end  : ending   index for b at iteration i 
%
% x_start: starting index for x at iteration i
% x_end  : ending   index for x at iteration i 

for i = 1:length(Vcijk_i)
    % determine the indices
    j_start = (Vcijk_j(i) - 1) * Ndofs + 1; 
    j_end   = Vcijk_j(i)*Ndofs; 
    k_start = (Vcijk_k(i) - 1) * Ndofs + 1; 
    k_end   = Vcijk_k(i)*Ndofs; 
    % perform the calculation
    if Vcijk_i(i) == 1
        b(j_start:j_end) = b(j_start:j_end) + Vcijk(i)*MKnominal*x(k_start:k_end);
    else
        b(j_start:j_end) = b(j_start:j_end) + Vcijk(i)*CMKi{Vcijk_i(i)-1}*x(k_start:k_end);
    end
    if ~(k_start==j_start)
        if Vcijk_i(i) == 1
            b(k_start:k_end) = b(k_start:k_end) + Vcijk(i)*MKnominal*x(j_start:j_end);
        else
            b(k_start:k_end) = b(k_start:k_end) + Vcijk(i)*CMKi{Vcijk_i(i)-1}*x(j_start:j_end);
        end 
    end
end

if NinputApproximationOrder == 2
    for i=1:length(Vci2jk_i)
        % determine the indices
        j_start = (Vci2jk_j(i) - 1) * Ndofs + 1; 
        j_end   = Vci2jk_j(i)*Ndofs; 
        k_start = (Vci2jk_k(i) - 1) * Ndofs + 1; 
        k_end   = Vci2jk_k(i)*Ndofs; 
        % perform the calculation
        b(j_start:j_end) = b(j_start:j_end) + Vci2jk(i)*(CMKii{Vci2jk_i(i)}./2)*x(k_start:k_end);
        if ~(k_start==j_start)
            b(k_start:k_end) = b(k_start:k_end) + Vci2jk(i)*(CMKii{Vci2jk_i(i)}./2)*x(j_start:j_end);
        end
    end
end


