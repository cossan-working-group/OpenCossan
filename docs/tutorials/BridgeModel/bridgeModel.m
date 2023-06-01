%% bridgeModel.m
% This script is used to compute the maximum displacement of a mathematical
% model of a bridge under harmonic load.
%
% The input values are passes in the matrix Minput and returned in a matrix
% called Moutput
%
% % $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli~and~Helmut~Pradlwarter$

%% Define some constants
Nbays= 20; % number of bays

freq_range = Minput(1,124);
rho = Minput(1,125);
beamDimension=Minput(1,126);

%%
%       1         2          3         4          5          6
%       E         h          l         s          w          c
% 2.1e+11     0.001       0.36      50.0          0       0.01
%    0.03      0.05       0.05      0.10       0.16       0.35
%       1  n_span+1 2*n_span+1 3*nspan+1 4*n_span+2 5*n_span+3
%  n_span  2*n_span   3*n_span 4*nspan+1 5*n_span+2 6*n_span+3
%

% Compute variables that do not depends on the samples
indexC = transpose(1:4:1+4*Nbays);
% compute total number of points
nnz = (4^2)*2*Nbays+2*(Nbays+1);
i_K = zeros(nnz,1);
j_K = zeros(nnz,1);
s_K = zeros(nnz,1);
nnz = (4^2)*2*Nbays;
i_M = zeros(nnz,1);
j_M = zeros(nnz,1);
s_M = zeros(nnz,1);
% compute total number of points
nza = 32*Nbays;

dof_unit_load = 3+4*2; %index of the applied force
dof_response = 3+4*2;  %index of the response of interest
    
% Preallocate memory
Moutput=zeros(size(Minput,1),1);

for isample=1:size(Minput,1)
    %% sparse damping matrix C
    sparse_C = sparse(indexC,indexC,Minput(isample,Nbays*5+3:Nbays*6+3)); %#ok<*SUSENS>
    
    %% sparse mass and stiffness matrix M and K
    
    for n=1:Nbays
        % compute current values
        l=Minput(isample,Nbays+n)/2;          %  l    length current bay
        E=Minput(isample,Nbays*2+n);          %  E    Youngs modulo
        A=Minput(isample,n)*beamDimension;        %  cross section area
        I=beamDimension*Minput(isample,n).^3/12;  %  geometric moment of inertia
        
        %stiffness matrix
        eK = E/l*[ 12*I/l^2  6*I/l  -12*I/l^2  6*I/l ; ...
            6*I/l    4*I     -6*I/l    2*I ; ...
            -12*I/l^2 -6*I/l   12*I/l^2 -6*I/l ; ...
            6*I/l    2*I     -6*I/l    4*I ];
        
        % consistent matrix
        eM = rho*A*l/420* ...
            [ 156   22*l    54  -13*l ; ...
            22*l  4*l^2  13*l -3*l^2 ; ...
            54   13*l   156  -22*l ; ...
            -13*l -3*l^2 -22*l 4*l^2 ];
        
        
        [i0_K,j0_K,s0_K] = find(eK);
        [~,~,s0_M] = find(eM);
        
        i0_K = i0_K+(n-1)*4;
        j0_K = j0_K+(n-1)*4;
        ka = 1+(n-1)*32;
        ke = 16+(n-1)*32;
        i_K(ka:ke) = i0_K;
        j_K(ka:ke) = j0_K;
        s_K(ka:ke) = s0_K;
        i_M(ka:ke) = i0_K;
        j_M(ka:ke) = j0_K;
        s_M(ka:ke) = s0_M;
        
        i0_K = i0_K+2;
        j0_K = j0_K+2;
        ka = 17+(n-1)*32;
        ke = 32+(n-1)*32;
        i_K(ka:ke) = i0_K;
        j_K(ka:ke) = j0_K;
        s_K(ka:ke) = s0_K;
        i_M(ka:ke) = i0_K;
        j_M(ka:ke) = j0_K;
        s_M(ka:ke) = s0_M;
    end
    
    
    
    for n=1:Nbays+1
        i_K(nza+2*n-1:nza+2*n) = [4*n-3,4*n-2]';
        j_K(nza+2*n-1:nza+2*n) = [4*n-3,4*n-2]';
        s_K(nza+2*n-1:nza+2*n) = [Minput(isample,Nbays*3+n),Minput(isample,Nbays*4+1+n)]';
    end
    
    sparse_K = sparse(i_K,j_K,s_K);
    sparse_M = sparse(i_M,j_M,s_M);
    
    %% Compute and plot eigenvectors
    % ne = min(n,8);
    % [v,d,flag] = eigs(sparse_K,sparse_M,ne,0);
    % omega = sqrt(diag(d));
    % eig_fr = omega/(2*pi)
    
    % figure;
    % plot(v(1:2:end,ne));
    % grid on;
    % figure;
    % plot(v(1:2:end,ne-1));
    % grid on;
    % figure;
    % plot(v(1:2:end,ne-2));
    % grid on;
    % figure;
    % plot(v(1:2:end,ne-3));
    % grid on;
    
    %% Compute response  
    % computes amplitudes of frequency response
    % hjp 090928
    
    [i_K,j_K,v_K] = find(sparse_K);
    [i_C,j_C,v_C] = find(sparse_C);
    [i_M,j_M,v_M] = find(sparse_M);
    
    [m,~] = size(sparse_K);
    load_vector = zeros(m,1);
    load_vector(dof_unit_load) = 1;
    
    n_freq = numel(freq_range);
    fr_ampl = zeros(m,n_freq);
    % Process frequences
    for k=1:numel(freq_range)
        om = 2*pi*freq_range(k);
        sp_dyn_stiff = sparse([i_K;i_C;i_M],[j_K;j_C;j_M],[v_K;v_C*1i*om;-v_M*om^2]);
        ampl = sp_dyn_stiff\load_vector;
        fr_ampl(:,k) = ampl;
    end
    
    %% Plot results
    %tab_dis = tab_ampl(dof,:);
    % tab_dis_re = real(fr_ampl);
    % tab_dis_im = imag(fr_ampl);
    % tab_dis_abs = abs(fr_ampl);
    %
    % figure
    % plot(tab_dis_re(1:11))
    % grid on;
    %
    % figure
    % plot(tab_dis_im(1:11))
    % grid on;
    %
    % figure
    % plot(tab_dis_abs(1:11))
    % grid on;
    
    dis_amplitudes = abs(fr_ampl(1:2:end));
    dis_response = dis_amplitudes(fix((dof_response+1)/2));
    
    Moutput(isample)=max(dis_amplitudes);
end
