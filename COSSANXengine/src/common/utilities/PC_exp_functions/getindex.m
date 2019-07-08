function [alpha,varargout] = getindex(M,q)
%GETINDEX   Get index sequences.
%   GETINDEX(M,q) returns all index sequences with M indices a_1, a_2,... a_M,
%   such that a_1 + a_2 + ... + a_M = q
%   This algorithm is given in: Sudret, Der Kiureghian, "Stochastic Finite Element
%   Methods and Reliability - A State-of-the-Art Report", Dept. of Civil & Env. Eng.,
%   University of California, Berkeley.
%
%   [ALPHA, NALPHA] = GETINDEX(M,q) outputs the array of sequences ALPHA,
%   as well as the number of sequences NALPHA
%
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================

% Number of boxes
nbox = M+q-1;
% Number of different index sequences alpha, (size of index set M and order q)
nalpha=nchoosek(nbox,q);

% Initialize data structures
alpha            = zeros(nalpha,M);  %Array holding the index sequences
iball            = 1:M;              %Ball location; iball(i) stores the box number of ball i
iball(M)         = nbox+1;           %Virtual ball; there are only M-1 actual balls
icurb            = M-1;              %Current ball number; we start from right to left
ibox             = zeros(1,nbox+1);  %Box occupancy; 0 is empty, 1 is occupied
ibox(1:(M-1))    = ones(1,(M-1));    %Start with balls packed to the left
ibox(1,nbox+1)   = 1;                %ibox(nbox+1) is virtual box and is always occupied
alpha(1,1:(M-1)) = zeros(1,M-1); 
alpha(1,M)       = q;                %Record first integer sequence

% Begin moving balls around...
i=1;
while iball(1) ~= (q+1) %Keep moving balls until the leftmost ball is as right as possible
    
    if (ibox(iball(icurb)+1)) == 0  % check if there is space to the right
        i=i+1;
        ibox(iball(icurb))=0;
        iball(icurb)=iball(icurb)+1; % move ball to the right
        ibox(iball(icurb))=1; 
        
        % Pack balls to the right of the current ball
        while icurb < M-1,
            ibox(iball(icurb+1))=0; 
            iball(icurb+1)=iball(icurb)+1; %pack next ball to the right
            ibox(iball(icurb+1))=1;
            icurb=icurb+1;
        end
        
        %Record integer sequence
        alpha(i,1)=iball(1)-1;
        for j=2:M
            alpha(i,j)=iball(j)-iball(j-1)-1;
        end
        
    else
        
        icurb=icurb-1; % Move to next ball on the left
        
    end
    
end

% Now flip the array alpha, such that the xi_i occur in ASCENDING order
alpha = flipud(alpha);

% When 2 output arguments are given, output number of index sequences nalpha
if nargout == 2
    varargout(1) = {nalpha};
end

