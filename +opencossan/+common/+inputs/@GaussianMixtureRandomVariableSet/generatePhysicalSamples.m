function MphysicalSpace = generatePhysicalSamples(Xobj,Nsamples)
if isempty(Xobj.Mcoeff)||isempty(Xobj.Vconstraints)
    %% No bounds defined: use method random of gmdistribution class
    MphysicalSpace = random(Xobj.gmDistribution,Nsamples);
    
elseif Xobj.Lrejection
    % use random of gmdistribution with rejection technique
    
    MphysicalSpace = random(Xobj.gmDistribution,Nsamples);
    
    Mcontraints=repmat(Xobj.Mcoeff*Xobj.Vconstraints,1,Nsamples)';
    while 1
        
        VrejectedInd= find(any(MphysicalSpace<Mcontraints,2));
        
        if isempty(VrejectedInd)
            break
        end
        
        MphysicalSpace(VrejectedInd,:) = random(Xobj.gmDistribution,length(VrejectedInd));
        
    end
    
    
else
    if isempty(Xobj.RhoThr)
        Xobj.RhoThr=[];
    end
    [Ncomp, Ndim]=size(Xobj.MdataSet);
    
    
    % CHECK INPUT
    
    %Xobj.Mcorrelation & Xobj.MdataSet
    if nargin < 2 || isempty(Xobj.MdataSet) || isempty(Xobj.Mcorrelation)||isempty(Xobj.Mcoeff)||isempty(Xobj.Vconstraints)
        error('gmtruncrnd:BadInput','Too Few Inputs');
    elseif ~ismatrix(Xobj.MdataSet)
        error('gmtruncrnd:BadInput','Xobj.MdataSet Must Be A Matrix');
    elseif ndims(Xobj.Mcorrelation) > 3
        error('gmtruncrnd:BadInput','Bad Sigma');
    end
    
    if ndims(Xobj.Mcorrelation) == 3 && size(Xobj.Mcorrelation,3) ~= Ncomp
        error('gmtruncrnd:BadInput','Covariance Matrix Dimensions Not Allowed');
    end
    
    if isempty(Nsamples)
        Nsamples = 1;
    elseif ~isnumeric(Nsamples) ||~isscalar(Nsamples) ||Nsamples<=0 ||Nsamples ~= round(Nsamples)
        error('gmtruncrnd:BadInput','Number of Samples should be scalar positive and integer ');
    end
    
    if isempty(Xobj.Vweights)
        Xobj.Vweights = repmat(1/Ncomp,[1,Ncomp]); % default equal component probability
        warning('Default Equal Component Probability Has Been Adopted')
    elseif ~isvector(Xobj.Vweights)
        error('gmtruncrnd:BadInput','Xobj.Vweights Must Be A Vector');
    elseif length(Xobj.Vweights)~=Ncomp
        error('gmtruncrnd:BadInput','Length of Vweights Must Be Equal To The Number Of Components');
    end
    
    if ~ismatrix(Xobj.Mcoeff)
        error('gmtruncrnd:BadInput','Mcoeff must be a matrix')
    elseif size(Xobj.Mcoeff,2)~=Ndim
        error('gmtruncrnd:BadInput','Wrong dimension of Mcoeff ')
    end
    
    if ~isvector(Xobj.Vconstraints)
        error('gmtruncrnd:BadInput','Vconstraints must be a vector')
        % elseif ~isinteger(length(Vconstraints)/Ndim)
        %     error('gmtruncrnd:BadInput','Vconstraints dimension not allowed')
    elseif length(Xobj.Vconstraints)~=size(Xobj.Mcoeff,1)
        error('gmtruncrnd:BadInput','Number of Vconstraints rows must be equal to number of Mcoeff rows')
    end
    
    
    %CHOSE THE COMPONENTS
    compIdx=randsample(Ncomp, Nsamples,true,Xobj.Vweights/sum(Xobj.Vweights));
    %PREALLOCATE OUTPUT VECTOR
    Y=zeros(Nsamples,Ndim, superiorfloat(Xobj.MdataSet,Xobj.Mcorrelation));
    if ndims(Xobj.Mcorrelation)== 3
        for i=1:Ncomp
            mbrs = find (compIdz == i);
            [Y(mbrs,:), rho]= opencossan.common.utilities.rmvnrnd (Xobj.MdataSet(i,:),Xobj.Mcovariance(:,:,i),length(mbrs),Xobj.Mcoeff,Xobj.Vconstraints,Xobj.RhoThr);
        end
    else % common covariance
        mbrs = find(compIdx == 1);
        Xobj.RhoThr=-1;
        debug=[];
        [Y(mbrs,:),rho] = opencossan.common.utilities.rmvnrnd(Xobj.MdataSet(1,:),Xobj.Mcovariance,length(mbrs),Xobj.Mcoeff,Xobj.Vconstraints,Xobj.RhoThr);
        
        for i = 2:Ncomp
            mbrs = find(compIdx == i);
            
            Y(mbrs,:) = opencossan.common.utilities.rmvnrnd(Xobj.MdataSet(i,:),Xobj.Mcovariance,length(mbrs),Xobj.Mcoeff,Xobj.Vconstraints,Xobj.RhoThr);
        end
    end
    MphysicalSpace=Y;
    %     MphysicalSpace = truncatedSample(Xobj.MdataSet,Xobj.Mcovariance,Nsamples,Xobj.Vweights,Xobj.Mcoeff,Xobj.Vconstraints,Xobj.RhoThr);
end
end