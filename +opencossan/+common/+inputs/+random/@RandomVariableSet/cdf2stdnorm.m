function MS = cdf2stdnorm(obj,MU)

%  cdf2stdnorm maps a point of the hypercube to standard normal space
%  of the random variables included in the RandomVariableSet object.
%    
%
%  MANDATORY ARGUMENTS
%    - RVS:  object of RandomVariableSet
%    - MU:   Matrix of samples of RV hypercube
%
%  OUTPUT ARGUMENTS:
%    - MS:   Matrix of samples of RV in SNS
%
%
%  Example:  MS = cdf2stdnorm(RVS,'musamples',MU)
%
%  See also: RandomVariableSet



VU = MU(:);

indexRightTail = VU > 0.5;
if iscolumn(VU)
    VS(indexRightTail)  = -norminv(1 - VU(indexRightTail));
    VS(~indexRightTail) =  norminv(VU(~indexRightTail));
    VS = VS(:);
elseif isrow(VU)
    VS(indexRightTail)  = -norminv(1 - VU(indexRightTail));
    VS(~indexRightTail) =  norminv(VU(~indexRightTail));
end

MS = reshape(VS,size(MU));

if ~obj.isIndependent()
    MS  = MS * transpose(obj.NatafModel.MYU);                            %transform MY to uncorrelated standard normal rv's w/ MYU
end

