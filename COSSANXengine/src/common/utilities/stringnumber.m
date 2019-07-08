function str2 = stringnumber(str,lb,ub,varargin)
%STRINGNUMBER   Generates a cell array with a sequence of strings
%  STRINGNUMBER(str,lb,ub) gerates a cell array with n string entries
%                          str_lb str_lb+1, str_lb+2, ... str_ub
%                          lb ... lower bound, ub ... upper bound
%                          The usage of an additional ending of the string is optional  
%
%  Usage: STRINGNUMBER(str,lb,ub)
%  E.g.:  str = 'string'; ub = 10; lb=2 
%         str2 = stringnumber('string',2,1000,'.sim');  
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2006 IfM
% =====================================================

%
% History:
% BG, 20-jul-2007
% =====================================================


if nargin < 3
    error('openCOSSAN:sample:TooLessInputs','Requires at least three input arguments.');
end
if nargin == 4
    str_end = varargin{1};
else str_end ='';
end
if nargin > 4
    error('openCOSSAN:sample:TooManyInputs','Requires at most four input arguments.');
end

n=ub-lb+1;
nzeros = floor(log10(ub));

s='0';
if nzeros == 0; s=''; end
if nzeros > 1
    for i=1:nzeros-1
        s=[s, '0'];
    end
end

j=0;
for i=lb:ub
    nzeros2 = nzeros - floor(log10(i));
    if nzeros2 < nzeros-j; s=regexprep(s,'0','','once'); j=j+1; end
str2{i-lb+1} = [str,s,num2str(i),str_end];
end

return;