function D = PlanarTruss

Coord=360*[2 1 0;2 0 0;1 1 0;1 0 0;0 1 0;0 0 0]; 
Con=[5 3;1 3;6 4;4 2;4 3;2 1;6 3;5 4;4 1;3 2];
Re=[0 0 1;0 0 1;0 0 1;0 0 1;1 1 1;1 1 1];
Load=zeros(size(Coord));Load(2,:)=[0 -1e5 0];Load(4,:)=[0 -1e5 0];
% or:   Load=[0 0 0;0 -1e5 0;0 0 0;0 -1e5 0;0 0 0;0 0 0];
E=ones(1,size(Con,1))*1e7;
% or:   E=[1 1 1 1 1 1 1 1 1 1]*1e7;
A=[27.5 0.1 24.5 17.5 0.1 0.5 7.5 21.5 21.5 0.1];
D=struct('Coord',Coord','Con',Con','Re',Re','Load',Load','E',E','A',A');

end

