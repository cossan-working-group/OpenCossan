function [Toutput] = expcovfunction(Tinput)

sigma = 1;
b = 0.5;

Toutput(size(Tinput,1),1) = struct;
for i=1:length(Tinput),
    t1  = Tinput(i).t1;
    t2  = Tinput(i).t2;
    Toutput(i).fcov  = sigma^2*exp(-1/b*abs(t2-t1));
end

return