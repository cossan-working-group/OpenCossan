%% Plot model
Sdirectory = fileparts(which('TutorialTrussBridgeStructure.m'));

load(fullfile(Sdirectory,'elements.dat'),'elements')
load(fullfile(Sdirectory,'nodes.dat'),'nodes')


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
incidence = elements(:,2:3);

% plot nodes
f1 = figure;
plot3(coord(:,1),coord(:,2),coord(:,3),'go','MarkerSize',4);
set(gca,'FontSize',16);
axis equal;
%
xlabel('x');
ylabel('y');
zlabel('z');
hold on;
%
num_elem = size(incidence,1);
% plot bars
X = zeros(2,num_elem);
Y = zeros(2,num_elem);
Z = zeros(2,num_elem);
for i=1:num_elem
    k1 = idx_nodes(incidence(i,1));
    k2 = idx_nodes(incidence(i,2));
    X(1,i) = coord(k1,1);
    X(2,i) = coord(k2,1);
    Y(1,i) = coord(k1,2);
    Y(2,i) = coord(k2,2);
    Z(1,i) = coord(k1,3);
    Z(2,i) = coord(k2,3);
end
plot3(X,Y,Z,'g-','LineWidth',0.3);
drawnow

