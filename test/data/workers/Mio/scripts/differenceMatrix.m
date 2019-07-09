Moutput= zeros(size(Minput,1),2);
Moutput(:,1) = Minput(:,1)-Minput(:,2);
Moutput(:,2) = Minput(:,2)-Minput(:,1);