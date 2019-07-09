function Xobj = computeTerms(Xobj,varargin)
%COMPUTETERMS Calculates the Karhunen-Loeve terms to be considered for the
%generation of samples of the specified stochastic process
%  KL_TERMS(SP1,varargin)
%
%   USAGE:  [StochasticProcessObject]=computeTerms(StochasticProcessObject,'PropertyName', PropertyValue, ...)
%
%   The COMPUTETERMS method produces a matrix with the eigenvectors and a vector
%   with the corresponding eigenvalues of the correlation matrix.
%
%   INPUT ARGUMENTS:
%    - Xobj       : StochasticProcess object
%    - NumberTerms: number of KL-terms to be retained
%    - AssembleCovariance: True or False (default)
%    - CovarianceMatrix
%
%  Example:
% * SP1=KL_terms(SP1,'NumberTerms',30) determines the eigenvectors
% and eigenvales of the 30 largest modes
%

import opencossan.OpenCossan

% Process inputs via inputParser
p = inputParser;
p.FunctionName = 'opencossan.common.inputs.stochasticprocess.KarhunenLoeve.computeTerms';

% Use default values
p.addParameter('NumberTerms',floor(length(Xobj.Coordinates)/2));
p.addParameter('AssembleCovariance',false);
p.addParameter('CovarianceMatrix',Xobj.CovarianceMatrix);

% Parse inputs
p.parse(varargin{:});

% Assign input to objects properties
validateattributes(p.Results.NumberTerms,{'numeric'},{'<=',length(Xobj.Coordinates)})
NumberTerms = p.Results.NumberTerms;
AssembleCovariance = p.Results.AssembleCovariance;
Xobj.CovarianceMatrix = p.Results.CovarianceMatrix;

% Check if the CovarianceMatrix is lower triangular
if istril(p.Results.CovarianceMatrix) || istriu(p.Results.CovarianceMatrix)
    % assemble full covariance
    Xobj.CovarianceMatrix=p.Results.CovarianceMatrix+...
        p.Results.CovarianceMatrix'-diag(diag(p.Results.CovarianceMatrix));
end

assert(~isempty(Xobj.CovarianceMatrix)||~isempty(Xobj.CovarianceFunction), ...
        'OpenCossan:KarhunenLoeve:computeTerms:noCovariance',...
        'Either the CovarianceMatrix or the CovarianceFunction must be provided')

Vx = Xobj.Coordinates;

Topts.issym = 1;
Topts.isreal = 1;
if opencossan.OpenCossan.getVerbosityLevel==4
    Topts.disp = 2;
elseif opencossan.OpenCossan.getVerbosityLevel==4
    Topts.disp = 1;
else
    Topts.disp = 0;
end

Mcov=Xobj.CovarianceMatrix;

if ~isempty(Mcov)
    
    if ~isempty(Xobj.CovarianceFunction)
        warning('OpenCossan:KarhunenLoeve:computeTerms:CovarianceFunctionAndMatrixDefined',...
            ['CovarianceMatrix and CovarianceFunction are both defined. \n' ...
            'Computing K-L terms using CovarianceMatrix!'])
    end
    
    opencossan.OpenCossan.cossanDisp(['Calling eigs with Mcovariance and ' ...
        num2str(NumberTerms) ' K-L terms'],4)
    [MPhi, Mlam] = eigs(Mcov,NumberTerms,'lm',Topts);
elseif AssembleCovariance 
    opencossan.OpenCossan.cossanDisp(['Assembling covariance matrix and calling eigs method with ' ...
        num2str(NumberTerms) ' K-L terms'],4)
    if Xobj.IsHomogeneous && Xobj.IsEquallySpaced
        Mcov = zeros(length(Vx));
        Vcov = compute(Xobj.CovarianceFunction,[Vx(1)*ones(1,length(Vx));Vx])';
        for i=1:length(Vx)
            Mcov(i,:) = [fliplr(Vcov(1:i)) Vcov(2:end-(i-1))];
        end
    else
        [Mindex1, Mindex2]= meshgrid(1:length(Vx),1:length(Vx));
        Vcov = compute(Xobj.CovarianceFunction,[Vx(:,Mindex1(:));Vx(:,Mindex2(:))]);
        Mcov = reshape(Vcov,length(Vx),length(Vx));
    end
    Xobj.CovarianceMatrix = Mcov;
    [MPhi, Mlam] = eigs(Mcov,NumberTerms,'lm',Topts);
else
    if Xobj.IsHomogeneous && Xobj.IsEquallySpaced
        OpenCossan.cossanDisp(['Homogeneus and equally spaced method with ' ...
            num2str(NumberTerms) ' K-L terms'],4)
        [MPhi, Mlam] = eigs(@(x) Xobj.matvecprodHomogeneous(x,Vx,Xobj.CovarianceFunction),...
            length(Vx),NumberTerms,'lm',Topts);
    else
        OpenCossan.cossanDisp(['NON-Homogeneus SP with ' num2str(NumberTerms) ' K-L terms'],4)
        [MPhi, Mlam] = eigs(@(x) Xobj.matvecprodNonhomogeneous(x,Vx,Xobj.CovarianceFunction),...
            length(Vx),NumberTerms,'lm',Topts);
    end
end

Vlam = diag(Mlam);

assert(all(Vlam>=0), ...
     'OpenCossan:KarhunenLoeve:computeTerms:NoAdmissibleCovariance',...
        'Not admissible covariance function: matrix is not positive-semidefinite')
    
[Vlam, index] = sort(Vlam,'descend');

MPhi = MPhi(:,index);
for imode = 1:NumberTerms
    MPhi(:,imode) = MPhi(:,imode)/norm(MPhi(:,imode));
end


Xobj.EigenVectors = MPhi;
Xobj.EigenValues = Vlam;

% Show covariance EigenValues

OpenCossan.cossanDisp(sprintf('* %u computed K-L terms (Max: %e; Min: %e)',...
    length(Xobj.EigenValues),max(Xobj.EigenValues),...
    min(Xobj.EigenValues)),4);


end

