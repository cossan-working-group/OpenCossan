function Pout = gen_truss(Pinput)

opts.disp = 0;
Pout = struct;

for isample = 1:size(Pinput,1)
    %[mass_mat,stif_mat] = assembly_matrices(Pinput(i));
    Cinput = struct2cell(Pinput(isample));
    Minput = cell2mat(Cinput);
    dof_per_node = 3;
    
    %#####################################################
    %
    %% load the coordinates of the nodes
    
    Sfolder = fileparts(which('TutorialTrussBridgeStructure.m'));
    load(fullfile(Sfolder,'nodes.dat'),'nodes');
    nr_nodes = nodes(:,1);
    abs_nr_nodes = abs(nr_nodes);
    nodnr_max = max(abs_nr_nodes);
    nodnr_min = min(abs_nr_nodes);
    if nodnr_min==0
        error(1,'%s','nodes number can not be zero!')
    end;
    %
    idx_nodes = nan(nodnr_max,1);
    for i=1:size(nr_nodes)
        idx_nodes(abs_nr_nodes(i))=i;
    end
    % idx_nodes
    coord = nodes(:,2:end);
    %
    % order node numbers
    ord_nodes = sort(abs_nr_nodes);
    for i=1:size(abs_nr_nodes)-1
        if ord_nodes(i)==ord_nodes(i+1)
            error(2,'%s','two number are equal')
        end
    end
    %
    dofs = nan(size(nr_nodes,1),1);
    k=0;
    for i=1:size(nr_nodes)
        if(nr_nodes(i)>0)
            dofs(idx_nodes(nr_nodes(i)))=k;
            k=k+dof_per_node;
        end
    end
    nr_dofs = k;
    
    %% load the incidences and property_nr
    
    load(fullfile(Sfolder,'elements.dat'),'elements');
    
    nr_elem = elements(:,1);
    incidence = elements(:,2:3);
    property_nr = elements(:,4);
    
    load(fullfile(Sfolder,'mass.dat'),'mass');
    nr_mass = mass(:,1);
    
    load(fullfile(Sfolder,'prop.dat'),'prop');
    nr_property = prop(:,1);
    
    %==========================================================
    %
    tmp = nan(max(nr_property),1);
    for i=1:size(nr_property,1)
        tmp(nr_property(i))=i;
    end
    
    for i=1:size(property_nr,1)
        property_nr(i) = tmp(property_nr(i));
    end
    clear tmp;
    %
    
    mass = Minput(1:33);
    
    mass_mat = zeros(nr_dofs);
    for i=1:size(mass,1)
        k = dofs(idx_nodes(nr_mass(i)));
        if ~isnan(k)
            for j=1:dof_per_node
                mass_mat(k+j,k+j) = mass(i);
            end
        end
    end
    
    stiffness = Minput(34:end);
    
    stif_mat = zeros(nr_dofs);
    for i=1:size(nr_elem)
        k1 = idx_nodes(incidence(i,1));
        k2 = idx_nodes(incidence(i,2));
        if k1==k2
            error(3,'%s','two incidences are equal');
        end
        dx = coord(k1,:)-coord(k2,:);
        length = norm(dx,2);
        unit_vec = dx./length;
        umat = unit_vec'*unit_vec;
        form = [umat -umat; -umat umat];
        if isnan(dofs(k1))
            dof1 = nan(1,dof_per_node);
        else
            dof1 = dofs(k1)+1:dofs(k1)+dof_per_node;
        end
        if isnan(dofs(k2))
            dof2 = nan(1,dof_per_node);
        else
            dof2 = dofs(k2)+1:dofs(k2)+dof_per_node;
        end
        dof = [dof1 dof2];
        idx = find(~isnan(dof));
        form = form(idx,idx);
        dof = dof(find(~isnan(dof)));
        i1 = property_nr(i);
        stif = stiffness(i1);
        stif_mat(dof,dof) = stif_mat(dof,dof)+form*stif;
    end
    
    Pout(isample).mass = mass_mat;
    Pout(isample).stiff = stif_mat;
    [MPhi,Mlambda] = eigs(stif_mat,mass_mat,20,'sm',opts);
    Pout(isample).MPhi = fliplr(MPhi);
    Pout(isample).Vlambda = flipud(diag(Mlambda));
end

return;