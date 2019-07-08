function [out ] = perfun2nl(Tinput)
%PERFUN1 Summary of this function goes here
%   Detailed explanation goes here

Cpreallocate=num2cell(zeros(length(Tinput),1));
Tout = cell2struct(Cpreallocate, 'out', 2);

out=zeros(length(Tinput),1);
for i=1:length(Tinput)
Tout(i).out=2+Tinput(i).RV1+0.1*Tinput(i).RV2;
end

end
