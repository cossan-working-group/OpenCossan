function [Vlengths] = getBeamLength(D)
%GETBEAMLENGTH Summary of this function goes here
%   Detailed explanation goes here

Vlengths=zeros(1,size(D.Con,2));
for i=1:size(D.Con,2)
   H=D.Con(:,i);C=D.Coord(:,H(2))-D.Coord(:,H(1));
   Vlengths(i)=norm(C);
end


