function Moutput = orthoNormalBasis(Vdirection) 
% ORTHONORMALBASIS compute the transformation matrix to rotate the
% coordinate system into a new one, where the first orthonormal
% vector is oriented likewise the inputted direction. This function
% implements the Gram–Schmidt process (see 
% "http://en.wikipedia.org/wiki/Gram%E2%80%93Schmidt_process"  for details)
%
% INPUT         Vdirection: vector identifying the direction in the 
%                           original space 
%
% OUTPUT        Moutput:    transformation matrix Ax=y for the change of
%                           coordinates into the rotated system
% -------------------------------------------------------------------------
% Author: Marco de Angelis
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk
% -------------------------------------------------------------------------
if ~isrow(Vdirection)
    Vdirection=transpose(Vdirection);
end

if abs(abs(Vdirection*Vdirection')-1)>1e-12
    Vdirection=Vdirection/norm(Vdirection);
end

% extract dimension
Nvars=length(Vdirection);


% Initialisations
% initialise array containing the sought orthonormal basis; rows are vector
% coordinates
MorthNormalBasis=zeros(Nvars);
% initialise array containing the orthogonal vectors on the basis
MorthogonalVectors=zeros(Nvars,Nvars);
% generate random vectors
MrandomVectors=randn(Nvars);

% Define the basis 
% assign the first vector of the basis
MorthNormalBasis(1,:)=Vdirection;

% Start iterations of the Gram–Schmidt process to generate linearly
% independent vectors
for idim=2:Nvars
    for iproj=1:idim-1
        MorthogonalVectors(idim,:)=MorthogonalVectors(idim,:) - ...
            MorthNormalBasis(iproj,:)*(MrandomVectors(idim,:)*MorthNormalBasis(iproj,:)');
    end
    MorthogonalVectors(idim,:)=MrandomVectors(idim,:)+MorthogonalVectors(idim,:);
    MorthNormalBasis(idim,:)=MorthogonalVectors(idim,:)/norm(MorthogonalVectors(idim,:));
end

% compute the accuracy that is the maximum value of the inner products 
% between orthogonal vectors
inaccuracy=max(max(abs((MorthNormalBasis*MorthNormalBasis')-eye(Nvars))));

if inaccuracy>100*eps
    warning('openCOSSAN:simulations:LineSampling',...
        ['The map into a rotated space may be inaccurate \n',...
        'for numerical issues'])
end

if rank(MorthNormalBasis)~=Nvars
warning('openCOSSAN:simulations:LineSampling',...
        ['The map into a rotated space has not been performed correctly \n',...
        'for numerical issues'])
end

% use this bit (without loop) for a five-dimensional example
%     Ve1=Vdirection;
%     
%     Vrand2=Mrand(1,:);
%     Vu2 = Vrand2 - Ve1*(Vrand2*Ve1');
%     Ve2 = Vu2/norm(Vu2);
%     MorthNormBasis(2,:)=Ve2;
%     
%     Vrand3=Mrand(3,:);
%     Vu3 = Vrand3 - Ve1*(Vrand3*Ve1') - Ve2*(Vrand3*Ve2');
%     Ve3 = Vu3/norm(Vu3);
%     MorthNormBasis(3,:)=Ve3;
%     
%     
%     Vrand4=Mrand(4,:);
%     Vu4 = Vrand4 - Ve1*(Vrand4*Ve1') - Ve2*(Vrand4*Ve2') - Ve3*(Vrand4*Ve3');
%     Ve4 = Vu4/norm(Vu4);
%     MorthNormBasis(4,:)=Ve4;
%     
%     Vrand5=Mrand(5,:);
%     Vu5 = Vrand5 - Ve1*(Vrand5*Ve1') - Ve2*(Vrand5*Ve2') - Ve3*(Vrand5*Ve3') - Ve4*(Vrand5*Ve4');
%     Ve5 = Vu5/norm(Vu5);
%     MorthNormBasis(5,:)=Ve5;

% assign the output
Moutput=MorthNormalBasis;


