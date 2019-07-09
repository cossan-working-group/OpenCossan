function Moutput = differenceMatrix(Minput)

Moutput= zeros(size(Minput,1),2);
for i = 1:size(Minput,1)
    Moutput(i,1) = Minput(i,1)-Minput(i,2);
    Moutput(i,2) = Minput(i,2)-Minput(i,1);
end

return;
