function b = preconditioning(x,Npccoefficients,Ndofs,Vpsii2,Mpreconditioner)
%
% PRECON provides the preconditioner for PCG Solver
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================

b = zeros(Npccoefficients*Ndofs,1);

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

for i=1:Npccoefficients
    b_start = (i-1)*Ndofs+1;
    b_end   = i*Ndofs;
    x_start = (i-1)*Ndofs+1;
    x_end   = i*Ndofs;
    b(b_start:b_end) = Vpsii2(i)*Mpreconditioner\(Mpreconditioner'\x(x_start:x_end));
end

