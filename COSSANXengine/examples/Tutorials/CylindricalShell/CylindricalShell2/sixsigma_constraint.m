function [gx, varargout] =sixsigma_constraint(Radius, Thickness)

% select here the design variables and the parameters
Radius = Radius*0.1016;          % Radius is normalized
Length = 0.2023;                 % Length is fixed
Thickness = Thickness*1.1597e-4; % Thickness is normalized
Nsamples = 48; 
% Limit from NASA SP-8007
% lambda = (1- 0.902*(1 - exp(-1/16*sqrt(Radius/Thickness))));
% Reference load is normalized to the buckling load of the shell
ref_load = 4500; 
analitic_buckl_load = 1.044e11/sqrt(3*(1-0.3^2))*2*pi*Thickness^2;
lambda = ref_load * 1/(analitic_buckl_load);


%% compute mean and standard deviation of the buckling load with MCS
%TODO: remove the fake
Xout = Fake_MC_bl_shell(Radius, Length, Thickness, Nsamples);

Vloads = Xout.getValues('Cnames',{'Load'});

mean_bl = mean(Vloads);
std_bl = std(Vloads);

% load results.mat
% mean_blgrid=[mean_blgrid;mean_bl];
% std_blgrid=[std_blgrid;std_bl];
% x1_grid=[x1_grid;x(1)];
% x2_grid=[x2_grid;x(2)];
% save results.mat mean_blgrid std_blgrid x1_grid x2_grid
%% return the value of the non-linear constraint function
gx = lambda - mean_bl + 6*std_bl;
varargout{1} = mean_bl;
varargout{2} = std_bl;