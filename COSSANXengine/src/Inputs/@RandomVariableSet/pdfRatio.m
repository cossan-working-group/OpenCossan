function varargout = pdfRatio(Xrvset,varargin)
%UEVALPDF Evaluates the ratio between the pdf.
%$ the Nvar-dimensional STANDARD NORMAL SPACE MU, where Nvar is the # of
%  columns of MU  and the # of rows of MU is the number of samples
%
%
%   MANDATORY ARGUMENTS:
%    - Xrvset     RandomvariableSet object
%    - Mnumerator       Numerator of the fraction 
%    - Mdenominator     Demominator of the fraction
%
%   Optional PropertyName:
%    - LphysicalSpace   Flag for defining if the matrixes are in
%                       PhysicalSpace (default=false)
%
%   OPTIONAL OUTPUT:
%   - varargout{1} = Vpdf		 Vector of the pdf
%
%  Vratio=pdfRatio(Xrvset,'Mnumerator',MU1,'Mdenominator',MU2)
%

%% initialize variable
LphysicalSpace=false;

%% Process inputs
	for k=1:2:length(varargin)
		switch lower(varargin{k})
			case {'mdenominator','denominator'}
				Mdenominator=varargin{k+1};
            case {'mnumerator','numerator'}
				Mnumerator=varargin{k+1};
			case {'lphysicalspace'}
				LphysicalSpace=varargin{k+1};
			otherwise
				error('openCOSSAN:RandomVariableSet:pdfRatio',...
					['PropertyName ' varargin{k} ' not allowed'])
		end
	end

%% checks inputs
if size(Mdenominato)~=size(Mnumerator)
    error('openCOSSAN:RandomVariableSet:pdfRatio',...
		'The Mdenominato and Mnumerator must have the same size')
end

if ~(size(Mdenominato,2)==length(Xrvset.Cmembers))
	error('openCOSSAN:RandomVariableSet:pdfRatio','Wrong no. of columns of the inputs matrixes - must be equal to length Xrvset.Cmembers');
end

if LphysicalSpace
    Mdenominator= map2stdnorm(Xrvset,Mdenominator);
    Mnumerator= map2stdnorm(Xrvset,Mnumerator);
end

Nsim = size(Mdenominator,1);
VpdfrvNumerator = zeros(Nsim,length(Xrvset.Cmembers));
VpdfrvDenominator = zeros(Nsim,length(Xrvset.Cmembers));

for j=1:length(Xrvset.Cmembers)
	VpdfrvNumerator(:,j) =normpdf(Mnumerator(:,j));
    VpdfrvDenominator(:,j) =normpdf(Mdenominator(:,j));
end


Vpdf=exp(sum(log(VpdfrvNumerator),2)-sum(log(VpdfrvDenominator),2));

% Export results
varargout{1}=Vpdf;

