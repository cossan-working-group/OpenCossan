function [Tout ] = perfunallnl(Tinput)
%PERFUN1 Summary of this function goes here
%   Detailed explanation goes here

Tout1 =  perfun1(Tinput);
Tout2 =  perfun2(Tinput);
Tout3 =  perfun3(Tinput);
Tout4 =  perfun4(Tinput);

Cpreallocate=num2cell(zeros(length(Tinput),1));
Tout = cell2struct(Cpreallocate, 'out', 2);


for n=1:length(Tinput)
    Tout(n).out=max(min(Tout1(n).out,max(Tout2(n).out,Tout4(n).out)),Tout3(n).out);
end


end
