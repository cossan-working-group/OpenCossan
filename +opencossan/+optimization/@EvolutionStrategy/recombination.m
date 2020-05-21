function [Moffspring] = recombination(Xobj,Mparents)
    % Recombination: Private method of EvolutionStrategy
    
    %% Allocation of Intermediate Parents
    
    %% Definition of Some Parameters
    Nx=length(Xobj.Sigma); % Number of design variables
    Moffspring  = zeros(Xobj.Nlambda,size(Mparents,2));
    
    %% Recombination
    switch Xobj.RecombinationStrategy
        case{'discrete'},
            for i=1:Xobj.Nlambda,
                Vaux                        = randperm(Xobj.Nmu)';
                Vselect_parents             = Vaux(1:Xobj.Nrho);
                Mchosen_parents             = Mparents(Vselect_parents,1:end-1);
                Vaux                        = unidrnd(Xobj.Nrho,1,Nx) + (0:Xobj.Nrho:(Nx-1)*Xobj.Nrho);
                Moffspring(i,1:Nx)        = Mchosen_parents(Vaux);
                Moffspring(i,Nx+1:2*Nx)   = sum(Mchosen_parents(:,Nx+1:2*Nx),1)/Xobj.Nrho;
            end
        case{'intermediate'},
            for i=1:Nlambda,
                Vaux                    = randperm(Nmu)';
                Vselect_parents         = Vaux(1:Xobj.Nrho);
                Mchosen_parents         = Mparents(Vselect_parents,1:end-1);
                Moffspring(i,1:end-1) = sum(Mchosen_parents,1)/Xobj.Nrho;
            end
    end
