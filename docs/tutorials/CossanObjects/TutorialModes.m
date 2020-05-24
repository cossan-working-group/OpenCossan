%% TUTORIALMODES
% In this tutorial it is shown how to construct a Modes object and how to
% compute frequency response functions
%
%
% See Also:  Modes
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Barbara-Goller$ 
clear
close all
clc;
%% Prapare definition of Modes object

% Load structural matrices (truss structure of tutorial for metamodel)
Sdirectory = fileparts(which('TutorialModes.m'));
load(fullfile([Sdirectory '/stiffness_mass_matrices.mat']));

% Determine modal properties
opts.disp = 0;
Nmodes = 20;  % number of modes to be retained
[Phi. Lam]=eigs(stiff,mass,Nmodes,0,opts);
Vlam = diag(Lam);

% Construct object Modes
Xmodes = opencossan.common.outputs.Modes('Mphi',Phi,'Vlambda',Vlam);

%% Perform FRF-analysis

DOF_obs = 48; % observed DOF
DOF_exc = 30; % DOF where load acts
Vfreq = 0.:0.05:5.; % frequency range
mod_damp_ratio = 0.02*ones(Nmodes,1); % modal damping ratios
Vforce = zeros(size(stiff,1),1);
Vforce(DOF_exc)=1.0; % force vector in physical space;
Vforce_mod = Phi'*Vforce; % force vector in modal space

% displacement FRF
Tfrf_disp = frf(Xmodes,'Sfrftype','disp','Vforce',Vforce_mod','Vexcitationfrequency',Vfreq,'Vdofs',DOF_obs,'Vzeta',mod_damp_ratio);

% velocity FRF
Tfrf_vel = frf(Xmodes,'Sfrftype','vel','Vforce',Vforce_mod','Vexcitationfrequency',Vfreq,'Vdofs',DOF_obs,'Vzeta',mod_damp_ratio);

% acceleration FRF
Tfrf_acc = frf(Xmodes,'Sfrftype','acc','Vforce',Vforce_mod','Vexcitationfrequency',Vfreq,'Vdofs',DOF_obs,'Vzeta',mod_damp_ratio);

%% Plot magnitude of FRFs

f1=figure;
semilogy(Vfreq,abs(Tfrf_disp.FRF_48),'Linewidth',2);
grid on
xlabel('excitation frequency [Hz]');
ylabel('|displacement|');
h1=gca; h2=get(gca,'XLabel'); h3=get(gca,'YLabel'); h4 = get(gca,'Title');
set([h1 h2 h3 h4],'FontSize',16);

f2=figure;
semilogy(Vfreq,abs(Tfrf_vel.FRF_48),'Linewidth',2);
grid on
xlabel('excitation frequency [Hz]');
ylabel('|velocity|');
h1=gca; h2=get(gca,'XLabel'); h3=get(gca,'YLabel'); h4 = get(gca,'Title');
set([h1 h2 h3 h4],'FontSize',16);

f3=figure;
semilogy(Vfreq,abs(Tfrf_acc.FRF_48),'Linewidth',2);
grid on
xlabel('excitation frequency [Hz]');
ylabel('|acceleration|');
h1=gca; h2=get(gca,'XLabel'); h3=get(gca,'YLabel'); h4 = get(gca,'Title');
set([h1 h2 h3 h4],'FontSize',16);



%% Close figure and validate solution

close(f1);
close(f2);
close(f3);

% check displacent FRF
assert(all(all(abs(abs(Tfrf_disp.FRF_48(1:10))-[0.0327, 0.0346, 0.0423, 0.0677, 0.4429, ...
                                    0.0642, 0.0260, 0.0145, 0.0089, 0.0055])<1e-4)), ...
                                    'CossanX:Tutorials:TutorialModes', ...
                                    'Reference Solution of displacement FRF does not match.')
                                
% check velocity FRF
assert(all(all(abs(abs(Tfrf_vel.FRF_48(1:10))-[0, 0.0109, 0.0266, 0.0638, 0.5566, ...
                                     0.1008, 0.0490, 0.0318, 0.0224, 0.0156])<1e-4)), ...
                                    'CossanX:Tutorials:TutorialModes', ...
                                    'Reference Solution of velocity FRF does not match.')
                                
% check acceleration FRF
assert(all(all(abs(abs(Tfrf_acc.FRF_48(1:10))-[0, 0.0034, 0.0167, 0.0601, 0.6994, ...
                                     0.1583, 0.0923, 0.0699, 0.0563, 0.0441])<1e-4)), ...
                                    'CossanX:Tutorials:TutorialModes', ...
                                    'Reference Solution of displacement FRF does not match.')
                                
