function [Moffspring]   = mutation(Xobj,Mparents)
% Mutation: Private method of EvolutionStrategy

%% Definition of Some Parameters
Moffspring  = zeros(size(Mparents));
Nx=length(Xobj.Vsigma); % Number of design variables

tau_g       = 1/sqrt(2*Nx);         %general learning parameter
tau_c       = 1/sqrt(2*sqrt(Nx));   %coordinate-wise learning parameter

%% 2.   Mutation of Strategy Parameters
%       Note that this operation should be performed before mutating the
%       design variables
Vz_glob                 = randn(Xobj.Nlambda,1);
Mz_coor                 = randn(Xobj.Nlambda,Nx);
Moffspring(:,Nx+1:2*Nx) = Mparents(:,Nx+1:2*Nx) .* ...
    exp( tau_g*repmat(Vz_glob,1,Nx) + tau_c*Mz_coor);

%% 3.   Mutation of Design Variables
Moffspring(:,1:Nx)  = Mparents(:,1:Nx) + Moffspring(:,Nx+1:2*Nx).*...
    randn(Xobj.Nlambda,Nx);

return
