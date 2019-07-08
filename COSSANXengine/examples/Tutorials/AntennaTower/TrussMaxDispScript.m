%% TRUSSMAXDISPSCRITP - Main MIO code, script version
% for each sample
for isample = 1:length(Tinput)
    %% construct the antenna structure from the sampled values. D is a
    % structure containing:
    % - nodal coordinate (D.Coord)
    % - nodal connectivity (D.Con)
    % - boundary conditions (D.Re)
    % - nodal loads (D.Load)
    % - beams Young's moduli (D.E)
    % - beams sections (D.A)
    %%  Definition of the 25 beams truss structure
    % Get structural parameter from input struct sample
    % E - random variables (a for-loop with eval is use here for brevity)
    for ibeam=1:25
        eval(['E' num2str(ibeam) '= Tinput(isample).E_' num2str(ibeam) ';']);
    end
    % Fx, Fy, Fz - function of the random variables theta and phi
    Fx = Tinput(isample).Fx;
    Fy = Tinput(isample).Fy;
    Fz = Tinput(isample).Fz;
    % Ai (sections of the beams) - parameter. The values of these parameters
    % are set from the outer loop design variables
    A1 = Tinput(isample).A1;
    A2 = Tinput(isample).A2;
    A3 = Tinput(isample).A3;
    A4 = Tinput(isample).A4;
    A5 = Tinput(isample).A5;
    A6 = Tinput(isample).A6;
    
    %% Construct the struct of the truss
    %  Nodal Coordinates
    Coord=[-37.5 0 200;37.5 0 200;-37.5 37.5 100;37.5 37.5 100;37.5 -37.5 100;...
        -37.5 -37.5 100;-100 100 0;100 100 0;100 -100 0;-100 -100 0];
    
    %  Connectivity
    Con=[1 2;1 4;2 3;1 5;2 6;2 4;2 5;1 3;1 6;3 6;4 5;3 4;5 6;...
        3 10;6 7;4 9;5 8;4 7;3 8;5 10;6 9;6 10;3 7;4 8;5 9];
    
    % Definition of Degree of freedom (free=0 &  fixed=1).
    % The nodes 7 to 10 are fixed in all the three degrees of freedom
    Re=zeros(size(Coord));Re(7:10,:)=[1 1 1;1 1 1;1 1 1;1 1 1];
    
    % Definition of Nodal loads. The Loads are applied at the two top nodes.
    Load=zeros(size(Coord));Load(1:2,:)=[Fx Fy Fz; Fx Fy Fz];
    
    % Definition of Modulus of Elasticity
    E = [E1 E2 E3 E4 E5 E6 E7 E8 E9 E10 E11 E12 E13 ...
        E14 E15 E16 E17 E18 E19 E20 E21 E22 E23 E24 E25];
    
    % Definition of beams sections
    A=[A1 A2 A2 A2 A2 A3 A3 A3 A3 A1 A1 A4 A4 A5 A5 A5 A5 A6 A6 A6 A6 A3 A3 A3 A3];
    
    % Convert to structure
    D=struct('Coord',Coord','Con',Con','Re',Re','Load',Load','E',E','A',A');
    %% compute the nodal displacements in the 3 degrees of freedom
    %   Compute the stresses, nodal diplacements and reaction forces given the
    %   struct describing the truss. 
    %   The stiffness matrix is assembled and used to computed the
    %   aforementioned quantities.
    w=size(D.Re);S=zeros(3*w(2));U=1-D.Re;f=find(U);
    for i=1:size(D.Con,2)
        H=D.Con(:,i);C=D.Coord(:,H(2))-D.Coord(:,H(1));Le=norm(C);
        T=C/Le;s=T*T';G=D.E(i)*D.A(i)/Le;Tj(:,i)=G*T;
        e=[3*H(1)-2:3*H(1),3*H(2)-2:3*H(2)];S(e,e)=S(e,e)+G*[s -s;-s s];
    end
    U(f)=S(f,f)\D.Load(f);F=sum(Tj.*(U(:,D.Con(2,:))-U(:,D.Con(1,:))));
    R=reshape(S*U(:),w);R(f)=0;
    %% compute the norms of the nodal displacements
    normU = zeros(1,size(U,2));
    for inode = 1:size(U,2)
        normU(inode) = norm(U(:,inode));
    end
    % assign the maximum displacement to the first output
    Toutput(isample).maxDisp = max(normU);
    %% compute the beam length
    %   Compute length of beams given the struct describing the truss. 
    beamLengths=zeros(1,size(D.Con,2));
    for i=1:size(D.Con,2)
       H=D.Con(:,i);C=D.Coord(:,H(2))-D.Coord(:,H(1));
       beamLengths(i)=norm(C);
    end
    %% compute the beam volumes and assign them to the sencond output
    Toutput(isample).beamVolumes = beamLengths' .* D.A;
end
