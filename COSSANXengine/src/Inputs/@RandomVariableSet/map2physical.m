function MX = map2physical(Xrvs,MU)

%  MAP2PHYSICAL maps a point of the standard normal space into the physical
%  space of the random variables included in the rvset object.
%    
%
%  MANDATORY ARGUMENTS
%    - Xrvs: object of rvset
%    - MU:   Matrix of samples of RV in SNS (n. simulation, n. RV)
%
%  OUTPUT ARGUMENTS:
%    - MX:   Matrix of samples of RV in Physical Space (n. simulation, n. RV)
%
%
%  Example:  MX=map2physical(Xrvs,'MS',MS)
%
%  See also: RandomVariableSet


%% Check inputs

% for k=1:2:length(varargin)
%     switch lower(varargin{k})
%         case {'ms','mssamples'}
%             MU=varargin{k+1};
%         otherwise
%             error('openCOSSAN:RandomVariableSet:stdnorm2cdf',...
%                 'Field name not allowed');
%     end
% end   

if not(size(MU,2)==length(Xrvs.Cmembers)) && isempty(Xrvs.Nmaxeigs)
    error('openCOSSAN:RVSET:map2physical','Number of columns of MU must be equal to # of rv''s in rvset');
elseif ~isempty(Xrvs.Nmaxeigs) && not(size(MU,2)==Xrvs.Nmaxeigs)
        error('openCOSSAN:RVSET:map2physical','Number of columns of MU must be equal to # eigenvalues retained');
end


if sum(sum(abs(imag(MU))))
    error('openCOSSAN:RVSET:map2physical','You have been stupid enough to call this method with complex numbers');
end
%% Main part 
Nvar = length(Xrvs.Cmembers);
Nsim = size(MU,1);

% preallocate memory
MX = zeros(Nsim,Nvar);

if ~Xrvs.Lindependence
    Nnzevals    = size(Xrvs.MUY,2);
    MU              = MU(:,1:Nnzevals);
    MY              = transpose(Xrvs.MUY * MU');
else
    MY          = MU;
end

for i=1:Nvar
	MX(:,i) = map2physical(Xrvs.Xrv{i},MY(:,i));     
end

end
