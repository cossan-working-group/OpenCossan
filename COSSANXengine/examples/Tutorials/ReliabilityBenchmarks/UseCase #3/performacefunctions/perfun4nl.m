function [Tout ] = perfun4nl(Tinput)
%PERFUN1 Summary of this function goes here
%   Detailed explanation goes here

Cpreallocate=num2cell(zeros(length(Tinput),1));
Tout = cell2struct(Cpreallocate, 'out', 2);

for i=1:length(Tinput)
Tout(i).out=2+Tinput(i).RV2+0.8*Tinput(i).RV1;
end

end
