function [ str ] = sprinf( varargin )
%SPRINF function used to fix a bug of matlab!
%   This function is used to bypass a misspelled line of code in matlab
%   eigs function. Without this the following error would be thrown:
%
%   Undefined function 'sprinf' for input arguments of type 'char'.
%
%   Error in eigs/printTimings (line 1349)
%               innerstr = getString(message('MATLAB:eigs:PrintTimingsComputeAX',sprinf('%f',cputms(3))));

str = sprintf(varargin{:});

end

