function MU = stdnorm2cdf(Xrvs,MS)

%  stdnorm2cdf maps a point of the standard normal space into the HyperCube
%    
%
%  MANDATORY ARGUMENTS
%    - Xrvs: object of rvset
%    - MS:   Matrix of samples of RV in SNS (n. simulation, n. RV)
%
%  OUTPUT ARGUMENTS:
%    - MU:   Matrix of samples of RV in HyperCube
%
%
%  Example:  MU=stdnorm2cdf(Xrvs,'MS',MS)
%
%  See also: RandomVariableSet


%% Check inputs

% 
% OpenCossan.validateCossanInputs(varargin{:});
% for k=1:2:length(varargin)
%     switch lower(varargin{k})
%         case {'ms','mssamples'}
%             MS=varargin{k+1};
%         otherwise
%             error('openCOSSAN:RandomVariableSet:stdnorm2cdf',...
%                 'Field name not allowed');
%     end
% end   

if not(size(MS,2)==length(Xrvs.Cmembers))
    error('openCOSSAN:RVSET:stdnorm2cdf','Number of columns of MS must be equal to # of rv''s in rvset');
end


if sum(sum(abs(imag(MS))))
    error('openCOSSAN:RVSET:stdnorm2cdf','this method can not be used with complex numbers');
end


%% Main part 
if ~Xrvs.Lindependence
    MS = transpose(Xrvs.MUY * MS');
end

if max(max(MS))>8
warning('openCOSSAN:RVSET',...
    'Value(s) in the standard normal space can not be mapped univocally in the Hypercube space\n Max Value: %f',max(max(MS)))
end
MU = normcdf(MS);

end
