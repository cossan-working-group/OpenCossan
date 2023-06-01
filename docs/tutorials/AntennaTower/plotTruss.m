% plot the undeformed truss structure

% Adapting to the original code
% Coord=Coord'; Con=Con';

C=Coord;e=Con(1,:);f=Con(2,:);
X = zeros(3*length(Con),3);
for icart=1:3
    M=[C(icart,e);C(icart,f);NaN(size(e))];X(:,icart)=M(:);
end
% Plot of the structure
figure
plot3(X(:,1),X(:,2),X(:,3),'k');axis('equal');
xlabel('x'), ylabel('y')
% show node labels
for inode=1:length(Coord)
    text(Coord(1,inode),Coord(2,inode),Coord(3,inode),...
        num2str(inode),'FontSize',10)
end
% show frame labels
hold
for ibeam=1:length(Con)
    if max(ibeam == [2 3 4 5])==1
        text((Coord(1,Con(2,ibeam))-Coord(1,Con(1,ibeam)))/3+Coord(1,Con(1,ibeam)),...
        (Coord(2,Con(2,ibeam))-Coord(2,Con(1,ibeam)))/3+Coord(2,Con(1,ibeam)),...
        (Coord(3,Con(2,ibeam))-Coord(3,Con(1,ibeam)))/3+Coord(3,Con(1,ibeam)),...
        num2str(ibeam),'FontSize',9)
    else
    text((Coord(1,Con(2,ibeam))-Coord(1,Con(1,ibeam)))/2+Coord(1,Con(1,ibeam)),...
        (Coord(2,Con(2,ibeam))-Coord(2,Con(1,ibeam)))/2+Coord(2,Con(1,ibeam)),...
        (Coord(3,Con(2,ibeam))-Coord(3,Con(1,ibeam)))/2+Coord(3,Con(1,ibeam)),...
        num2str(ibeam),'FontSize',9)
    end
end

% % % show sections assignements
% for ibeam=1:length(Con)
%     text(2*(Coord(1,Con(2,ibeam))-Coord(1,Con(1,ibeam)))/3+Coord(1,Con(1,ibeam)),...
%         2*(Coord(2,Con(2,ibeam))-Coord(2,Con(1,ibeam)))/3+Coord(2,Con(1,ibeam)),...
%         2*(Coord(3,Con(2,ibeam))-Coord(3,Con(1,ibeam)))/3+Coord(3,Con(1,ibeam)),...
%         SA(ibeam,:),'FontSize',8)
% end
grid on