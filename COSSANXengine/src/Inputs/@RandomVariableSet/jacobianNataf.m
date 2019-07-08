function MJ = jacobianNataf(Xrvs,VU)
%jacobianNataf   Calculates the Jacobian of the Nataf model at the point VU
%            -- -------------------------------  
%           | dx_1/du_1 dx_1/du_2 ....... dx_1/du_n |
%        MJ=| dx_2/du_1 dx_2/du_2 ....... dx_2/du_n |
%           |     :         :     .......     :               |
%           | dx_n/du_1 dx_2/du_2 ....... dx_n/du_n |
%            ----------------------------------
%            
%
%   MANDATORY ARGUMENTS:
%   - Xrvs   :  contains the information about the set of random variables and
%               their correlation
%   - VU     :  Vector that contains the realization in the 
%               standard normal space where the Jacobian is to be calculated.
%               The dimension of this vector should be 1 x no. of 
%               rv's in Xrvs
%
%   OPTIONAL ARGUMENTS:
%
%   OUPUT ARGUMENTS
%   - MJ     :  Jacobian matrix, dimension no. of rv's in Xrvs x no. of 
%               rv's in Xrvs
%   
%   EXAMPLE
%   MJ      = jabobianNataf(Xrvs1,VU) calculates the Jacobian matrix of the
%   nataf model at the point VU
%
%   See also: RandomVariableSet
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =========================================================================

%% 1.   Argument Check
if ~isa(Xrvs,'RandomVariableSet'),  % check if the first input is a RandomVariableSet object
    error('openCOSSAN:RandomVariableSet:jacobianNataf','The first input parameter must be a RandomVariableSet object');
end
if not(nargin==2),
    error('Two arguments required: RandomVariableSet object and VU (point in standard normal space)');
end

%% 2.   Realization in Standard Correlated Space and in Physical Space
%2.1.   Size of the Problem
Nvar    = length(Xrvs.Cmembers);      %Number of rv's in the rvset
%2.2.   Check length of vector VU
VU      = VU(:)';
if length(VU)~=Nvar,
    error('openCOSSAN:RandomVariableSet:jacobianNataf','VU is not a vector (neither a row nor a column vector), as it should be');
end
%2.3.   Realization in Standard Correlated Space
if get(Xrvs,'Lindependence'),
    VY      = VU;
else
    VY      = transpose(Xrvs.MUY * VU'); %Realization in Standard Correlated Space
end
%2.4.   Realization in Physical Space
VX  = map2physical(Xrvs,VU);

%% 3.   PDF's ratio between Standard Correlated Variables and Physical Variables
%3.1.   PDF - standard normal space
Vpdf_VY     = normpdf(VY);          %VY's pdf
%3.2.   PDF - physical space
Vpdf_VX     = zeros(size(Vpdf_VY));
for j=1:length(Xrvs.Cmembers)
    Vpdf_VX(:,j)    = evalpdf(Xrvs.Xrv{j},VX(:,j));
end
%3.3.   Sought ratio
Vdx_dy      = Vpdf_VY./Vpdf_VX;       %Sought ratios

%% 4.   Jacobian Matrix
MJ      = zeros(Nvar,Nvar);        %Matrix to store Jacobian
MB_T    = Xrvs.MUY';                    %Matrix to relate Standard to Standard correlated space; Y' = B * U'

if get(Xrvs,'Lindependence'),
    MJ      = diag(Vdx_dy);
else
    for j=1:Nvar,
        MJ(:,j)    = (Vdx_dy(j)*MB_T(:,j));
    end
    MJ  = MJ';
end

return
