function x0 = draw_limit_states2(design_points,e1,e2)
% Computes and draws the linear limit states in the plane defined by the
% direction_1 and direction_2.
% 
% the unit vector e1 = direction_1/norm(direction_1)
% the unit vector e2 = dir2/norm(dir2)
%     where dir2 = direction_2-<e1,direction_2>*e1
%
% HJP 081126
%

%% determine both orthogonal unit vector
% which define the two dim. plane
%e1 = direction_1/norm(direction_1);
%dir2 = direction_2-e1*direction_2'*e1;
%e2 = dir2/norm(dir2);


%% compute design point in e1-e2 plane
% a linear limit state function in n-dim. standard normal 
% space is uniquely specified by its design point x*.
% For this case the design point x0 in e1-e2 plane can be
% computed in the following way:
% All points xp in the e1-e2 plane can be represented by
% xp = a1*e1+a2*e2 (1)
% The limit state function must fulfill the condition that
% the inner product <(xp-x*),x*> = 0, since the limit state 
% surface is orthogonal to the vector x*. This leads to the
% relation 
% <x*,e1>*a1+<x*,e2> = <x*,x*> = ||x*||^2 (2)
% The design point in e1-e2 plane is then the solution of (2)
% which minimizes x0^2 = a1^2+a2^2.
% It is well known that the solution is obtained by 
% taking (a1,a2) proportional to (<x*,e1>,<x*,e2>), which leads
% to the solution
%    x0 = b1*e1+b2*e2
% with
%    b1 = a0*<x*,e1>
%    b2 = a0*<x*,e2>
%    a0 = <x*,x*>/(<x*,e1>^2+<x*,e2>^2)
%
x0 = design_points;


%% compute position used in 'text()' for
% plotting the number of linear limit states
% near the design point x0
tmp4 = x0.^2;
tmp5 = sqrt(sum(tmp4));
tmp6 = repmat(tmp5,size(x0,1),1);
dist = 0.6;
text_pos = x0-x0./tmp6*dist

a = 6.0;
ndp = size(x0,2)
y_east = zeros(1,ndp);
x_north = y_east;
y_west = y_east;
x_south = y_east;

color_plot = ['b-','g-','r-','c-','m-','k-','bd'];
color_fill = ['b','g','r','c','m','k','b'];

for k=1:ndp
    k
    xi = x0(1,k);
    xid = xi;
    if(abs(xid)<0.0001)
        xid = 0.0001;
    end
    eta = x0(2,k);
    etad = eta;
    if(abs(etad)<0.0001)
        etad = 0.0001;
    end
    y_east(k) = eta+xi/etad*(xi-a);
    y_west(k) = eta+xi/etad*(xi+a);
    x_north(k) = xi+eta/xid*(eta-a);
    x_south(k) = xi+eta/xid*(eta+a);
end
out = [x_south; x_north; y_east; y_west]

x = zeros(5,1);
y = zeros(5,1);

%figure;
for k=1:ndp
    abs_a = [abs(y_east(k));abs(y_west(k));abs(x_south(k));abs(x_north(k))];
    if(min(abs_a)>a)
        continue;
    end
    if((x0(1,k)>=0) && (x0(2,k)>0))
        if(y_west(k)<a)
            x(1) = -a; y(1) = y_west(k);
            x(2) = -a; y(2) = a;
            x(3) = a; y(3) = a;
            x(4) = a; y(4) = y_east(k);
        else
            x(1) = x_north(k); y(1) = a;
            x(2) = a; y(2) = a;
            if(x_south(k)>a) 
                x(3) = a; y(3) = y_east(k);
                x(4) = x(1); y(4) = y(1);
            else
                x(3) = a; y(3) = -a;
                x(4) = x_south(k); y(4) = -a;
            end
        end
        dp1 = x0(:,k)'
        out1 = [x,y]
    elseif ((x0(1,k)<0) && (x0(2,k)>=0))
        if(x_south(k)>-a)
            x(1) = x_south(k); y(1) = -a;
            x(2) = -a; y(2) = -a;
            x(3) = -a; y(3) = a;
            x(4) = x_north(k); y(4) = a;
        else
            x(1) = -a; y(1) = y_west(k);
            x(2) = -a; y(2) = a;
            if(x_north(k)<a)
                x(3) = x_north(k); y(3) = a;
                x(4) = x(1); y(4) = y(1);
            else
                x(3) = a; y(3) = a;
                x(4) = a; y(4) = y_east(k);
            end
        end
    elseif ((x0(1,k)<=0) && (x0(2,k)<0))
        if(y_east(k)>-a)
            x(1) = a; y(1) = y_east(k);
            x(2) = a; y(2) = -a;
            x(3) = -a; y(3) = -a;
            x(4) = -a; y(4) = y_west(k);
        else
            x(1) = x_south(k); y(1) = -a;
            x(2) = -a; y(2) = -a;
            if(x_north(k)<-a)
                x(3) = -a; y(3) = y_west(k);
                x(4) = x(1); y(4) = y(1);
            else
                x(3) = -a; y(3) = a;
                x(4) = x_north(k); y(4) = a;
            end
        end
      elseif ((x0(1,k)>0) && (x0(2,k)<=0))
        if(x_north(k)<a)
            x(1) = x_north(k); y(1) = a;
            x(2) = a; y(2) = a;
            x(3) = a; y(3) = -a;
            x(4) = x_south(k); y(4) = -a;
        else
            x(1) = a; y(1) = y_east(k);
            x(2) = a; y(2) = -a;
            if(x_south(k)>-a)
                x(3) = x_south(k); y(3) = -a;
                x(4) = x(1); y(4) = y(1);
            else
                x(3) = -a; y(3) = -a;
                x(4) = -a; y(4) = y_west(k);
            end
        end
    else
        error('can not be');
    end
    x(5) = x(1);
    y(5) = y(1);
    fill(x,y,color_fill(k));
    %plot(x,y,color_plot(k),'LineWidth',2);
    nr = sprintf('%d',k);
    h = text(text_pos(1,k),text_pos(2,k),nr);
    set(h,'FontSize',16);
    alpha(0.1);
    hold on
end
%
%
grid on;
axis equal;
axis([-a a -a a]);
set(gca,'FontSize',16);
set(gca,'XTick',[-6 -4 -2 0 2 4 6]);
%legend('1','1','2','2','3','3','4','4','5','5','6','6')
%
%
%
%

