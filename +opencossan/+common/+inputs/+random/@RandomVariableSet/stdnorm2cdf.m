function MU = stdnorm2cdf(obj,MS)

%  stdnorm2cdf maps a point of the standard normal space into the HyperCube
%    
%
%  MANDATORY ARGUMENTS
%    - rvs:  object of rvset
%    - MS:   Matrix of samples of RV in SNS (n. simulation, n. RV)
%
%  OUTPUT ARGUMENTS:
%    - MU:   Matrix of samples of RV in HyperCube
%
%
%  Example:  MU = stdnorm2cdf(Xrvs,'MS',MS)
%
%  See also: RandomVariableSet


%% Check inputs
assert(size(MS,2) == length(obj.Names),...
    'openCOSSAN:RVSET:stdnorm2cdf','Number of columns of MS must be equal to # of rv''s in rvset')

assert(isreal(MS),...
    'openCOSSAN:RVSET:stdnorm2cdf','this method can not be used with complex numbers')

%% Main part 
if ~obj.isIndependent()
    MS = transpose(obj.NatafModel.MUY * MS');
end

if max(max(MS)) > 8
    warning('openCOSSAN:RVSET',...
        'Value(s) in the standard normal space can not be mapped univocally in the Hypercube space\n Max Value: %f',max(max(MS)))
end

VS = MS(:);

indexRightTail = VS > 0;
if iscolumn(VS)
    VU(indexRightTail)  = 1 - normcdf(-VS(indexRightTail));
    VU(~indexRightTail) = normcdf(VS(~indexRightTail));
    VU = VU(:);
elseif isrow(VS)
    VU(indexRightTail)  = 1 - normcdf(-VS(indexRightTail));
    VU(~indexRightTail) = normcdf(VS(~indexRightTail));
end

MU = reshape(VU,size(MS));

end
