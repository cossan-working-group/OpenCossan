function [output] = performanceFunctionG7(MX)

% High dimensional problem 
% Noise function

%% 1. Parameters

%% 2.   Random Variables

m=size(MX,2); %number random variables
Vi=1:10;
Vbeta=(2.5+0.25*cos(pi * Vi/m))/sqrt(6);

Vjstart=4*(Vi-1)+1;
Vjend=4*(Vi-1)+6;

Mg=zeros(size(MX,1),length(Vi));

for i=1:length(Vi)
    Mg(:,i)=Vbeta(i)-sum(MX(:,Vjstart(i):Vjend(i)),2);
end

output = max(Mg,[],2);

