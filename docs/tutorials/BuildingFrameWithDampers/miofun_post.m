function Toutput = miofun_post(Tinput)
%
%
h=3.963; %m
B=[1 0 0;-1 1 0;0 -1 1]/h;
for n=1:length(Tinput)
    
    IDR=B*[Tinput(n).disp_history1.Vdata;Tinput(n).disp_history2.Vdata;Tinput(n).disp_history3.Vdata];
    Toutput(n).max_IDR=max(max(abs(IDR)));
    Toutput(n).sum_damper_forces=sum([max(abs(Tinput(n).damper_force_history1.Vdata)),...
    max(abs(Tinput(n).damper_force_history2.Vdata)),max(abs(Tinput(n).damper_force_history3.Vdata))]);
end
end