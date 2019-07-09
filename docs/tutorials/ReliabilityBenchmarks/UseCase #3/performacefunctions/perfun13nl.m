function [Tout ] = perfun13nl(Tinput)
%PERFUN1 Summary of this function goes here
%   Detailed explanation goes here

Cpreallocate=num2cell(zeros(length(Tinput),1));
Tout = cell2struct(Cpreallocate, 'out', 2);

Tout1 =  perfun1nl(Tinput);
Tout3 =  perfun3nl(Tinput);


for n=1:length(Tinput)
    Tout(n).out=max(Tout1(n).out,Tout3(n).out);
end

end
