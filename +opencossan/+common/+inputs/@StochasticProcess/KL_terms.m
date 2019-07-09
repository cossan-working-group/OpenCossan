function Xsp = KL_terms(Xsp,varargin)
%KL_TERMS Calculates the Karhunen-Loeve terms to be considered for the
%generation of samples of the specified stochastic process 
%  KL_TERMS(SP1,varargin)
%
%   USAGE:  [MPhi Vlam]=KL_terms(StochasticProcess,'PropertyName', PropertyValue, ...)
%
%   The KL-terms method produce a matric with the eigenvectors and a vector
%   with the corresponding eigenvalues of the correlation matrix.
%
%   MANDATORY ARGUMENTS:
%    - SP     StochasticProcess object
%    - NKL_terms: number of KL-terms to be retained
%    - Stype: "direct" or "iterative" (method for solving eigenvalue problem)
%
%
%
%  Example:
% * [Mphi Vlam]=KL_terms(SP1,'NKL_terms',30) determines the eigenvectors
% and eigenvales of the 30 largest modes
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/KL_terms@StochasticProcess
%
% Copyright 1983-2015 COSSAN Working Group, University of Innsbruck, Austria

Lcovarianceassemble=false; %Set default value
OpenCossan.validateCossanInputs(varargin{:})
Mcov = Xsp.Mcovariance;

for k=1:2:length(varargin)  
    switch lower(varargin{k})
        case {'nkl_terms'}
            NKL_terms = varargin{k+1};
        case {'lcovarianceassemble'}
            Lcovarianceassemble  = varargin{k+1};
        case {'mcovariance'}
            Mcov = varargin{k+1};   
        otherwise
            error('openCOSSAN:StochasticProcess:KL_terms',...
                ['Field name ' varargin{k} ' not allowed']);            
    end
end

if ~isempty(Mcov)
    % Check if the matrix is positive defined
%    chol(Mcov);
elseif ~ isempty(Xsp.Xcovariancefunction)
    Xfun = Xsp.Xcovariancefunction;
else
    error('openCOSSAN:StochasticProcess:KL_terms',...
        'Either the covariance matrix or the covariance function must be provided')
end

if NKL_terms > length(Xsp.Mcoord)
    error('openCOSSAN:StochasticProcess:KL_terms',...
        'The number of KL-terms (%i) must be <= length of Mcoord (%i)',...
        NKL_terms,length(Xsp.Mcoord))
end    

Vx = Xsp.Mcoord;

Topts.issym = 1;
Topts.isreal = 1;
if OpenCossan.getVerbosityLevel==4
    Topts.disp = 2;
elseif OpenCossan.getVerbosityLevel==4
    Topts.disp = 1;    
else
    Topts.disp = 0; 
end

if Xsp.Lhomogeneous==1 && Xsp.Lequallyspaced==0
    warning('openCOSSAN:StochasticProcess:KL_terms',...
        ['In case of an equally spaced input Mcoord of the homogeneous process ' ...
        'the eigensolution can be performed faster'])
end    

if ~isempty(Mcov)
    OpenCossan.cossanDisp(['Calling eigs with Mcovariance and ' num2str(NKL_terms) ' K-L terms'],4)
    [MPhi, Mlam] = eigs(Mcov,NKL_terms,'lm',Topts);
elseif Lcovarianceassemble
    OpenCossan.cossanDisp(['Assembling covariance matrix and calling eigs method with ' num2str(NKL_terms) ' K-L terms'],4)
    if Xsp.Lhomogeneous && Xsp.Lequallyspaced
        Mcov = zeros(length(Vx));
        Vcov = evaluate(Xfun,[Vx(1)*ones(1,length(Vx));Vx])';
        for i=1:length(Vx)
            Mcov(i,:) = [fliplr(Vcov(1:i)) Vcov(2:end-(i-1))];
        end
    else
        [Mindex1, Mindex2]= meshgrid(1:length(Vx),1:length(Vx));
        Vcov = evaluate(Xfun,[Vx(:,Mindex1(:));Vx(:,Mindex2(:))]);
        Mcov = reshape(Vcov,length(Vx),length(Vx));
    end
    Xsp.Mcovariance = Mcov;
    [MPhi, Mlam] = eigs(Mcov,NKL_terms,'lm',Topts);
else
    if Xsp.Lhomogeneous && Xsp.Lequallyspaced
        OpenCossan.cossanDisp(['Homogeneus and equally spaced method with ' num2str(NKL_terms) ' K-L terms'],4)
        [MPhi, Mlam] = eigs(@(x) Xsp.matvecprodHomogeneous(x,Vx,Xfun),length(Vx),NKL_terms,'lm',Topts);        
    else
        OpenCossan.cossanDisp(['NON-Homogeneus SP with ' num2str(NKL_terms) ' K-L terms'],4)
        [MPhi, Mlam] = eigs(@(x) Xsp.matvecprodNonhomogeneous(x,Vx,Xfun),length(Vx),NKL_terms,'lm',Topts);
    end
end

Vlam = diag(Mlam);
if any(Vlam<0)
    error('openCOSSAN:StochasticProcess:KL_terms',...
        'Not admissible covariance function: matrix is not positive-semidefinite')
end
[Vlam, index] = sort(Vlam,'descend');
MPhi = MPhi(:,index);
for imode = 1:NKL_terms
    MPhi(:,imode) = MPhi(:,imode)/norm(MPhi(:,imode));
end


Xsp.McovarianceEigenvectors = MPhi;
Xsp.VcovarianceEigenvalues = Vlam;

% Show covariance EigenValues

OpenCossan.cossanDisp(sprintf('* %u computed K-L terms (Max: %e; Min: %e)',...
            length(Xsp.VcovarianceEigenvalues),max(Xsp.VcovarianceEigenvalues),...
            min(Xsp.VcovarianceEigenvalues)),4);
       

end

