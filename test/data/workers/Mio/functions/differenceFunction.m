function [Voutput1, Voutput2] = differenceFunction(Vinput1, Vinput2)

Voutput1 = zeros(size(Vinput1,1),1);
Voutput2 = Voutput1;
for i = 1:size(Vinput1,1) % this is slow! Don't do it in real life!
    Voutput1(i) = Vinput1(i)-Vinput2(i);
    Voutput2(i) = Vinput2(i)-Vinput1(i);
end

return;
