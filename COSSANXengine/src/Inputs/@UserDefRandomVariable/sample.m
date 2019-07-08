function VX = sample(Xrv,varargin)
%SAMPLE Generates samples for the specified RV 
%  SAMPLE(rv1,varargin)   
%       
%   USAGE:  Px=SAMPLE(Xrv,'PropertyName', PropertyValue, ...)
%
%   The sample method produce a vector or a matrix of samples from the RV
%   object.
%   The method takes a variable number of token value pairs.  These
%   pairs set properties (optional values) of the run method.
%
%  Example: 
% * Vx=sample(Xrv,'Nsamples',m) produces m samples for the specified RV  
% * Vx=sample(Xrv) produces a single sample
% * Mx=sample(Xrv,'Vsamples',[m n]) produces a sample matrix mxn 
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================

m = 1; 
n = 1;
for k=1:2:length(varargin)
	if ~isa(varargin{k},'char')
		warning('openCOSSAN:rv:sample',...
			'Please pass the arguments list in pairs (PropertyName, PropertyValue)')
		if nargin < 1
			error('openCOSSAN:rv:samplerv','Requires at least one input argument.\n');
		elseif nargin == 1
			m = 1; n = m;
		elseif nargin == 2
			m = varargin{1}; n = m;
		elseif nargin == 3
			m = varargin{1}; n = varargin{2};
		else
			error('openCOSSAN:rv:samplerv','TooManyInputs: Requires at most three input arguments.');
		end
	else	
		switch lower(varargin{k})
			case {'nsamples'}
				m = varargin{k+1};
				n = 1;
			case {'vsamples'}
				m = varargin{k+1}(1);
				n = varargin{k+1}(2);
		end
	end
end
VX = random(Xrv.empirical_distribution,m,n);
    end


