Nsamples_validation = length(Xoutput_metamodel);
Nmodes_mm = size(Xoutput_metamodel(1).MPhi,2);
Nmodes_fm = size(Xmm.XvalidationOutput(1).MPhi,2);
Vf = zeros(size(Xoutput_metamodel(1).MPhi,1),1);
Vf(48) = 1.0;
DOF_obs = 30;
modal_damping_ratio = 0.02;
Vfreqrange = 0:0.03:5.;
Tfrf_mm = cell(Nsamples_validation,1);
Tfrf_fm = cell(Nsamples_validation,1);

for isim = 1:Nsamples_validation
    Xm_mm = Xoutput_metamodel(isim);
    Vzeta = modal_damping_ratio*ones(Nmodes_mm,1);
    Vforce = Xm_mm.MPhi'*Vf;
    Tfrf_mm{isim} = opencossan.common.outputs.Modes.frf(Xm_mm,'Sfrftype','acc','Vforce',Vforce','Vexcitationfrequency',Vfreqrange,'Vdofs',DOF_obs,'Vzeta',Vzeta);
    
    Xm_fm = Xm_mm.XvalidationOutput(isim);
    Vzeta = modal_damping_ratio*ones(Nmodes_fm,1);
    Vforce = Xm_fm.MPhi'*Vf;
    Tfrf_fm{isim} = opencossan.common.outputs.Modes.frf(Xm_fm,'Sfrftype','acc','Vforce',Vforce','Vexcitationfrequency',Vfreqrange,'Vdofs',DOF_obs,'Vzeta',Vzeta);
    
    f(isim) = figure;
    semilogy(2*pi*Vfreqrange,abs(Tfrf_mm{isim}.FRF_30),'Linewidth',2); hold on
    semilogy(2*pi*Vfreqrange,abs(Tfrf_fm{isim}.FRF_30),'Linewidth',2,'Color','r','Linestyle','--');
    xlabel('Excitation [rad/s]')
    ylabel('acceleration FRF');
    title(['Comparison of validation sample no. ' num2str(isim)]);
        legend('meta-model','full model');
    h1=gca; h2=get(gca,'XLabel'); h3=get(gca,'YLabel'); h4 = get(gca,'Title');
    set([h1 h2 h3 h4],'FontSize',16);
    grid on
    xlim([0 30])
end
