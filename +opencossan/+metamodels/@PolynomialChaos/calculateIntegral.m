function [varargout] = calculateIntegral(varargin)
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/calculateIntegral@PolynomialChaos
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 
% $Author:~Murat~Panayirci$ 

global counter
global CFEresult

%% get the input

Xpc             = varargin{end};                % Obtain the PC object
Xinp            = Xpc.Xsfem.Xmodel.Xinput;      % Obtain Input

assert(length(Xinp.CnamesRandomVariableSet)==1,'COSSAN:SFEM', ...
    'Only 1 random variable set is allowed')

Mxi             = cell2mat(varargin(1:Xinp.NrandomVariables));   % get the values identified for germs
coeffindex      = varargin{end-1};              % get the index of P-C coefficient which is calculated
counter         = counter + 1;
Xconnector      = Xpc.Xsfem.Xmodel.Xevaluator.CXsolvers{1};
Xext            = Xconnector.CXmembers{2};

%% calculate the integral

if strcmp(Xpc.Sbasis,'Hermite')
    pdfvalue  = prod(normpdf(Mxi),2);             % value of the multiplication of std. normal PDF for the xi's
    Mpsii     = evaluateHermite(Mxi,Xpc.Norder);  % values of Hermite polynomials at the xi values
elseif strcmp(Xpc.Sbasis,'Legendre')
    pdfvalue  = prod(unifpdf(Mxi,-1,1),2);        % value of the multiplication of uniform PDF (-1,1) for the xi's
    Mpsii     = evaluateLegendre(Mxi,Xpc.Norder); % values of Legendre polynomials at the xi values
end

% values of the responses at the xi values
if coeffindex == 1 || counter > length(CFEresult)
    CFEresult{counter} = runFEsolver(Xpc,Mxi); 
end

% convert the cell structure to matrix
Msamples = cell2mat(CFEresult{counter});
for iresponse = 1:Xext.Nresponse
   varargout{iresponse} = Msamples(iresponse,:)'.*Mpsii(:,coeffindex).*pdfvalue;
end

return


