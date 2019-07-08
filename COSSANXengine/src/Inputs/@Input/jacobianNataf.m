function MJ = jacobianNataf(Xin,VU)
%jacobianNataf   Calculates the Jacobian of the Nataf model at the point VU
%            -- -------------------------------  
%           | dx_1/du_1 dx_1/du_2 ....... dx_1/du_n |
%        MJ=| dx_2/du_1 dx_2/du_2 ....... dx_2/du_n |
%           |     :         :     .......     :     |
%           | dx_n/du_1 dx_2/du_2 ....... dx_n/du_n |
%            ----------------------------------
%            
%
%   MANDATORY ARGUMENTS:
%   - Xin    :  Input object; contains the information about the 
%   RandomVariableSets present
%   - VU     :  Vector that contains the realization in the 
%               standard normal space where the Jacobian is to be calculated.
%               The dimension of this vector should be 1 x no. of 
%               rv's
%
%   OPTIONAL ARGUMENTS:
%
%   OUPUT ARGUMENTS
%   - MJ     :  Jacobian matrix, dimension no. of rv's x no. of 
%               rv's
%   
%   EXAMPLE
%   MJ      = jabobianNataf(Xin,VU) calculates the Jacobian matrix of the
%   nataf model at the point VU
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =========================================================================

%% 1.   Argument Check
if ~isa(Xin,'Input'),  % check if the first input is a RandomVariableSet object
    error('openCOSSAN:Input:jacobianNataf','The first input parameter must be an Input object');
end
if not(nargin==2),
    error('Two arguments required: Input object and VU (point in standard normal space)');
end

%% 2.   Get random variable sets present in Input object
TXrvs   = Xin.Xrvset;        %structure with RandomVariableSet objects
Cnames  = fieldnames(TXrvs);    %Cell containing names of RandomVariableSet objects
MJ      = [];                   %empty matrix to store Jacobian
Npos    = 0;                    %counter to establish position
for i=1:length(Cnames),
    Caux    = get(TXrvs.(Cnames{i}),'Cmembers'); %extract random variables in RandomVariableSet object
    Nelem   = length(Caux);     %get number of elements
    MJaux   = jacobianNataf(TXrvs.(Cnames{i}),VU(Npos+1:Npos+Nelem));   %calculate Jacobian matrix for i-th RandomVariableSet object
    MJ(Npos+1:Npos+Nelem,Npos+1:Npos+Nelem)     = MJaux;    %store results
    Npos    = Npos + Nelem;     %updates counted
end

return