function MU = map2stdnorm(Xrvs,MX)
%MAP2STDNORM maps a value from the space of the random variables included
%in the rvset object to the standard normal space
%
%  MANDATORY ARGUMENTS
%    - MX:   Matrix of samples of RV in Physical Space (n. simulation, n.
%    RV)
%
%  OUTPUT ARGUMENTS:
%    - MU:   Matrix of samples of RV in SNS (n. simulation, n. RV)
%
%  Usage: MU = MAP2STDNORM(Xrvs,'MX',MX) 
%
%  See also: RandomVariableSet


% for k=1:2:length(varargin)
%     switch lower(varargin{k})
%         case {'mx','mxsamples'}
%             MX=varargin{k+1};
%         otherwise
%             error('openCOSSAN:RandomVariableSet:stdnorm2cdf',...
%                 'Field name not allowed');
%     end
% end   


if size(MX,2)==length(Xrvs.Cmembers)
    Mx=MX;
elseif size(MX,1)==length(Xrvs.Cmembers)
    Mx=transpose(MX);
else
    error('openCOSSAN:Input:map2standnorm', ...
		'Number of columns must be equal to the total number of rv''s in Input object');
end


Nvar = length(Xrvs.Cmembers);
Nsim = size(Mx,1);

% preallocate memory
MY = zeros(Nsim,Nvar); %MY - matrix of rv's in stand. normal space, but correlated

%apply method map2stdnorm to rv (not rvset!)
%hence correlations are not taken care of

for i=1:Nvar
    MY(:,i) = map2stdnorm(Xrvs.Xrv{i}, Mx(:,i));                                                                                
end

if ~Xrvs.Lindependence
    MU  = transpose(Xrvs.MYU * MY'); %transform MY to uncorrelated standard normal rv's w/ MYU
else
    MU  = MY;
end

% return the matrix in the original order
if size(MU,2)==size(Mx,1)
    MU=transpose(MU);  
end

