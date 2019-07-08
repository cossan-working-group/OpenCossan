function MS = cdf2stdnorm(Xrvs,MU)

%  cdf2stdnorm maps a point of the hypercube to standard normal space
%  of the random variables included in the RandomVariableSet object.
%    
%
%  MANDATORY ARGUMENTS
%    - Xrvs: object of RandomVariableSet
%    - MU:   Matrix of samples of RV hypercube
%
%  OUTPUT ARGUMENTS:
%    - MS:   Matrix of samples of RV in SNS
%
%
%  Example:  MU=cdf2stdnorm(Xrvs,'musamples',MU)
%
%  See also: RandomVariableSet
% 
% if mod(length(varargin),2)
%    error('openCOSSAN:RVSET:map2physical','Arguments must be in pairs property name/value');
% end
% for k=1:2:length(varargin)
%     switch lower(varargin{k})
%         case {'mu','musamples'}
%             MU=varargin{k+1};
%         otherwise
%             error('openCOSSAN:RandomVariableSet:stdnorm2cdf',...
%                 'Field name not allowed');
%     end
% end

MS=norminv(MU);

if ~Xrvs.Lindependence
    MS  = MS*transpose(Xrvs.MYU); %transform MY to uncorrelated standard normal rv's w/ MYU
end

