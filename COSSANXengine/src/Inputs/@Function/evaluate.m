function Vout = evaluate(Xfun,Xinp)
%EVALUATE method evaluates the function defined in the Function object
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Evaluate@Function
%

% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli~and~Pierre-Beaurepaire$

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

%% Check arguments
assert(logical(exist('Xinp','var')), ...
    'openCOSSAN:Function:evaluate',...
    'The function require an Input object to be evaluated.');

assert(isa(Xinp,'Input'), ...
    'openCOSSAN:Function:evaluate',...
    'the second argument must be an object of type Input ');

for itok=1:length(Xfun.Ctoken)
    if ~sum(ismember(Xinp.Cnames, Xfun.Ctoken{itok}))
        error('openCOSSAN:Function:evaluatefunction',...
            'The required object %s is not present in the input object',Xfun.Ctoken{itok}{1});
    end
end

%% check samples/input
% if Xinp.NrandomVariables~=0 &&  isempty(Xinp.Xsamples)
%     error('openCOSSAN:Function:evaluatefunction',...
%         'The input object does not contain samples');
% end

if Xinp.LcheckFunctions
    Xinp.checkFunction;
end

LcheckSamples=false;

%%  Extract set of values from Xinput object
%  Extract value of samples present in Xinput
Xsamples    = Xinp.Xsamples;
% Extract name of parameters present in Xinput
Cpar    = Xinp.CnamesParameter;   %get name of parameters in Xinput

if isa(Xsamples,'Samples')
    Nsamples    = Xsamples.Nsamples;
else
    % No Samples available.
    % Get Samples from the parameter
    assert(~isempty(Cpar),'openCOSSAN:Function:evaluatefunction', ...
        'Function can not be evaluated because it does not contain any parameters')
    
    Nsamples    = size(Xinp.Xparameters.(Cpar{1}).value,1);
end

Nsamples    = max(1,Nsamples);

%%  Prepare strings for evaluating the Function

varargin=cell(1,length(Xfun.Ctoken));

% Create executable script
SexecString=Xfun.Sexpression;
for n=1:length(Xfun.Ctoken)
    
    Svalue=['varargin{' num2str(n) '}'];
    Stoken=strcat('<&',Xfun.Ctoken{n},'&>');
    SexecString  = regexprep(SexecString,Stoken,Svalue,1);
end



for itok=1:length(Xfun.Ctoken)
    %  Case Ctok{itok} is a rv
    if ismember(Xfun.Ctoken{itok},Xinp.CnamesRandomVariable)
        varargin{itok}=Xinp.getValues('Cnames',Xfun.Ctoken{itok});
        LcheckSamples=true;
        continue
    end
    
    %% Interval variable
    if ismember(Xfun.Ctoken{itok},Xinp.CnamesIntervalVariable)
        varargin{itok}=Xinp.getValues('Cnames',Xfun.Ctoken{itok});
        LcheckSamples=true;
        continue
    end
    
    %% Parameter
    if ismember(Xfun.Ctoken{itok},Xinp.CnamesParameter)
        varargin{itok}=Xinp.Xparameters.(Xfun.Ctoken{itok}{1}).value;
        continue
    end
    
    %% Function
    if ismember(Xfun.Ctoken{itok},Xinp.CnamesFunction)
        varargin{itok}=Xinp.getValues('Cnames',Xfun.Ctoken{itok});
        Xinp.LcheckFunctions = false;
        varargin{itok} = Xinp.Xfunctions.(Xfun.Ctoken{itok}{1}).evaluate(Xinp);
        LcheckSamples=true;
        continue
    end
    
    %% Design Variable
    if ismember(Xfun.Ctoken{itok},Xinp.CnamesDesignVariable)
        varargin{itok}=Xinp.getValues('Cnames',Xfun.Ctoken{itok});
        LcheckSamples=true;
        continue
    end
    
    error('openCOSSAN:Function:evaluatefunction',...
        ['object ' Xfun.Ctoken{itok}{:} ' is not allowed']);
end

%% Evaluation of the Function

try
    Vout = eval(SexecString);
catch ME
    error('openCOSSAN:Function:evaluatefunction',...
        strcat('Sexpression could not be evaluated successfully, syntax may be invalid\n',...
        ME.message));
end

%% Validate Results
if isa(Xsamples,'Samples')
    if LcheckSamples
        assert(size(Vout,1)==Nsamples,'openCOSSAN:Function:evaluatefunction', ...
            'The function returns an output of %s elements while the input contains only %s values',...
            sprintf('%i',size(Vout,1)),sprintf('%i',Nsamples))
    else
        Vout(1:Nsamples,1)=Vout;
    end
end

return
