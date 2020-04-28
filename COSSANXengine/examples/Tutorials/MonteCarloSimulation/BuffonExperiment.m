function BuffonExperiment(Nthrows)
%% Buffon Experiments
%
% BuffonExperiment(Nthrows) 
%
% Nthrows: the number of times the needle were thrown;
%
% Author: Edoardo Patelli, 2013-2016
%
% This file is distributed in the hope that it will be useful under the
% GNU LESSER GENERAL PUBLIC LICENSE.


%% Define problems
% t=distance between parallel lines
% L=needle's length
t=2; L=1;

%% Compute real value of the probability of intersection according to the
% Buffon's formula
Pintesection=2*L/(pi*t);

%% Use batches
% Number of batches used to perform the analysis
Nbatches=100;
% compute throws for each batch 
NthrowsBatch = floor(Nthrows/Nbatches);

% Prepare figure
figure; axis on; grid on; box on; hold on;
plot([1 Nbatches],[Pintesection Pintesection],'r')
axis([0 Nbatches+1 0 1])


Nhits=0; % Counter for the needles intersecting the line
NsamplesTot=0;
for n=1:Nbatches
    NsamplesTot=NsamplesTot+NthrowsBatch;
    % Generate 2 random number uniformily distributed in the range [0,1).
    % a vector of 2 times 10000 pseudorandom numbers
    U=rand(2,NthrowsBatch);
    % Compute distance from a line
    d=U(1,:)*t; 
    % compute angle
    phi=0.5*pi*U(2,:);    
    % hits is a vector of zeros where false and ones where true
    hits= d<=cos(phi);
    Nhits=Nhits+sum(hits);
    % Compute the estimator    
    PintersectionEstimated=Nhits/ NsamplesTot;
    
    % Update plot
    plot (n,PintersectionEstimated,'x')
    if n==1
        legend('Theoretical results','MC estimator')
    end
    if NthrowsBatch<100
        pause(0.1)
    end
end

% summarize results
display('Buffon experiment')
fprintf('Distance between lines (t) %f\n',t)
fprintf('Needle'' length (L) %f\n',L)
fprintf('Expected value %f \n',PintersectionEstimated)
fprintf('Estimation error %f%%\n', ...
    abs(PintersectionEstimated-Pintesection)/Pintesection*100)

% end of code
