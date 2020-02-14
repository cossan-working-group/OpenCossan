function offsprings = mutation(obj, parents)
    % MUTATION
    offsprings = zeros(size(parents));
    Nx = length(obj.Sigma); % Number of design variables
    
    tau_g = 1 / sqrt(2 * Nx); % general learning parameter
    tau_c = 1 / sqrt(2 * sqrt(Nx)); % coordinate-wise learning parameter
    
    % Mutation of strategy parameters. Must be performed before mutation of the design variables.
    Vz_glob = randn(obj.Nlambda, 1);
    Mz_coor = randn(obj.Nlambda, Nx);
    offsprings(:,Nx+1:2*Nx) = parents(:,Nx+1:2*Nx) .* ...
        exp(tau_g*repmat(Vz_glob,1,Nx) + tau_c*Mz_coor);
    
    % Mutation of design variables.
    offsprings(:,1:Nx)  = parents(:,1:Nx) + offsprings(:,Nx+1:2*Nx).*...
        randn(obj.Nlambda,Nx);
    return
