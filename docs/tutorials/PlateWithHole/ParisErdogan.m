function Toutput = ParisErdogan( Tinput )


% dummy Memory
Cdummy=num2cell(zeros(length(Tinput),1));
Toutput=struct('da1dn',Cdummy,'da2dn',Cdummy);


for i=1:length(Tinput)
   Toutput(i).da1dn = Tinput.C*(Tinput(i).deltaK1)^ Tinput(i).m;
   Toutput(i).da2dn = Tinput.C*(Tinput(i).deltaK2)^ Tinput(i).m;
end

end

