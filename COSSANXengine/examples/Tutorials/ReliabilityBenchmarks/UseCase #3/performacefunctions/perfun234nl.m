function [out ] = perfun234(Tinput)
%PERFUN1 Summary of this function goes here
%   Detailed explanation goes here

%out1 =  perfun1(Tinput);
out2 =  perfun2(Tinput);
out3 =  perfun3(Tinput);
out4 =  perfun4(Tinput);

out=max(max(out2,out4),out3);

end
