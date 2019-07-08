function varargout=makeString4TextFile(varargin)

s=varargin{1};
N=varargin{2};

if N == 1
    varargout{1}=['\n ',s];
else
    ss=[s,' '];
    varargout{1}=['\n',repmat(ss,1,N-1),s];
end

return