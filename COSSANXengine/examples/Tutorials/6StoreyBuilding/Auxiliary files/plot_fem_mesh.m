load nodes.txt
load element_soil.txt
load element_shells.txt
load element_beams.txt
load MCS_results Xo

nn = zeros(max(nodes(:,1)),3);
for i=1:length(nodes)
    nn(nodes(i,1),:)=nodes(i,2:4);
end

opengl hardware    
figure
set(gcf,'Renderer','OpenGL');

%% plot solid elements
for i_el=1:length(element_soil)
    X = zeros(length(element_soil(i_el,:))-1,3);
    for i = 1:8
        X(i,:)=nn(element_soil(i_el,i+1),:);
    end
    C = convhulln(X);
    % Plot the convex hull.
    hold on
    for i = 1:size(C,1)
       j = C(i,[1 2 3 1]);
       patch(X(j,1),X(j,2),X(j,3),'w');
    end
end

%% plot shell elements
for i_el=1:length(element_shells)
    X = zeros(length(element_shells(i_el,:))-1,3);
    for i = 1:4
        X(i,:)=nn(element_shells(i_el,i+1),:);
    end
    hold on;
    patch(X(:,1),X(:,2),X(:,3),'w','FaceAlpha',0.3)
end

%% plot beam elements
% determine the color of the beam based on the value of beta
Col=colormap;
nchannel=64;
res = rv('Sdistribution','normal','mean',1e8,'CoV',0.2);
betas = betavalues(Xo,'Xresistance',res);
% find minimum and maximum value of beta
maxbeta = -Inf; minbeta = Inf;
Cfields = fieldnames(betas);
for ifield = 1:length(Cfields)
    maxbeta = max([maxbeta, min(betas.(Cfields{ifield}))]);
    minbeta = min([minbeta, min(betas.(Cfields{ifield}))]);
end
maxbeta = 10; minbeta = 4;
% scale the betas according to the number of channel of the colormap
colbins = linspace(minbeta,maxbeta,nchannel);

% plot the beams
for i_el=1:length(element_beams)
    X = zeros(length(element_beams(i_el,:))-1,3);
    for i = 1:2
        X(i,:)=nn(element_beams(i_el,i+1),:);
    end
    hold on;
    Sfield = ['C' int2str(element_beams(i_el,1))];
    icol = 65-find(min(betas.(Sfield))<=colbins,1);
    plot3(X(:,1),X(:,2),X(:,3),'LineWidth',5,'Color',Col(icol,:))
end

axis off
view([-127.5,10])
camproj('perspective')
%%
labels = cell(nchannel,1);
labels{1} = num2str(colbins(64));
for i=8:8:nchannel
    labels{i} = num2str(colbins(65-i));
end
lcolorbar(labels,'Fontsize',14,'fontweight','bold');
