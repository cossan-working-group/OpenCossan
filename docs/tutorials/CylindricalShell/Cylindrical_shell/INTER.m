function r=INTER(A,v,u,plot)
%function r=INTER(A,v,u,kill)  
%   ===    ===    ===    Date: 07.03.2000            
%  =   =  =   =  =   =   Purpose: Interpolation of matrices 
%  =      =====   ===      
%  =   =  =   =  =   =
%   ===   =   =   ===
%   
% update: 15.01.01
% changed 'bilinear' to 'bicubic' according to suggestion of J. Hol
%------------------------------------------------------------------------------




[N,M]=size(A);
[x,y]=meshgrid(1:M,1:N);
[xi,yi]=meshgrid(1:(M-1)/(u-1):M,1:(N-1)/(v-1):N);
rfd=interp2(x,y,A,xi,yi,'bicubic');

r=rfd;

if plot==0 
return
end
subplot(2,1,1)
mesh(x,y,A)

subplot(2,1,2)
mesh(xi,yi,rfd);




