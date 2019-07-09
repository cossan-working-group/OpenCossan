function MX = map2physical(obj,MU)

%  MAP2PHYSICAL maps a point of the standard normal space into the physical
%  space of the random variables included in the rvset object.
%
%
%  MANDATORY ARGUMENTS
%    - obj:  object of RandomVariableSet
%    - MU:   Matrix of samples of RV in SNS (n. simulation, n. RV)
%
%  OUTPUT ARGUMENTS:
%    - MX:   Matrix of samples of RV in Physical Space (n. simulation, n. RV)
%
%
%  Example:  MX = map2physical(obj,'MS',MS)
%
%  See also: RandomVariableSet


%% Check inputs
assert(size(MU,2) == length(obj.Names),...
    'openCOSSAN:RVSET:map2physical',...
    'Number of columns of MU must be equal to # of rv''s in rvset')

assert(isreal(MU),...
    'openCOSSAN:RVSET:map2physical',...
    'You have been stupid enough to call this method with complex numbers');

%% Main part
Nvar = length(obj.Names);
Nsim = size(MU,1);

% preallocate memory
MX = zeros(Nsim,Nvar);

if ~obj.isIndependent()
    Nnzevals    = size(obj.NatafModel.MUY,2);
    MU          = MU(:,1:Nnzevals);
    MY          = transpose(obj.NatafModel.MUY * MU');
else
    MY          = MU;
end

for i = 1:Nvar
    MX(:,i) = map2physical(obj.Members(i),MY(:,i));
end

end
