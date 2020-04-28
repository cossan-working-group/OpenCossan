


function estimatePI(Nthrows)
%% estimatePI
%
% estimatePI(Nthrows) this function estimates the value of Pi by means of Monte
% Carlo simulation
% Let us consider a circle (with a radius r) which is within a square (with
% edges of length l=2*r). Now, by choosing random points within the square, we are
% able to calculate whether or not each point is within the circle or not.
% We used the dart method to estimate Pi.
%
% Since we know the area of a circle (AreaCircle) with radius r
% (AreaCircle=pi*r^2) and the area of the square (AreaSquare) with sides of
% lenght l=2*r (AreaSquare=l^2).
%
% the ratio, R, of the area of the circle to the total area of the square is:
%
% R=AreaCircle/AreaSquare=pi*r^2/(4*r^2) = pi/4
%
% Hence pi=Ratio*4
%
% Due to simmetry we can calculate the ratio of only 1/4 of the circle/square
%
% Nthrows: the number of times the needle were thrown;
%
% Author: Edoardo Patelli, 2013
%
% This file is distributed in the hope that it will be useful under the
% GNU LESSER GENERAL PUBLIC LICENSE.


%% Define problems
% r=radius of the circle
% L=square size
r=1; 
l=2*r;


% Prepare figure
figure; axis on; grid on; box on; hold on;
Vtheta=linspace(0,pi/2,50);
Vx=[0 r*cos(Vtheta) 0];
Vy=[0 r*sin(Vtheta) 0];
plot([0 1 1 0 0],[0 0 1 1 0],'b') % Plot square
plot(Vx,Vy,'r') % Plot quarter of cirle
axis([-0.5 1.5 -0.5 1.5])

Nhits=0; % Counter for the point "hitting" the circle

% NOTE: This code is not optimized for Matlab. The for loop can be optimized
% using vectors


% Method 0: interctive mode
for n=1:Nthrows
    % Generate two random numbers defining the position inside the square
    x=rand;
    y=rand;
    % Generate 2 random number uniformily distributed in the range [0,1).
    % a vector of 2 times 10000 pseudorandom numbers
    if x^2+y^2<r;
        plot(x,y,'.r')
    else
        plot(x,y,'.k')
    end
    if Nthrows<=100;
        pause(0.1)
    elseif Nthrows<=1000;
       pause(0.01) 
    end
end

% Method 1
tic,
for n=1:Nthrows
    % Generate two random numbers defining the position inside the square
    x=rand;
    y=rand;
    % Generate 2 random number uniformily distributed in the range [0,1).
    % a vector of 2 times 10000 pseudorandom numbers
    if x^2+y^2<r
        Nhits=Nhits+1;
    end
end
time1=toc;
fprintf('\n* Method 1 \n')
fprintf('Pi estimator %f \n',4*Nhits/Nthrows)
fprintf('Samples per second %e \n',Nthrows/time1)

% Method 2

tic,
% Generate two random numbers defining the position inside the square
Vpoints=rand(Nthrows,2);
% Check if the points are inside the circle
Nhits2=sum((Vpoints(:,1).^2+Vpoints(:,2).^2)<r);

time2=toc;
fprintf('\n* Method 2 \n')
fprintf('Pi estimator %f \n',4*Nhits2/Nthrows)
fprintf('Samples per second %e \n',Nthrows/time2)

