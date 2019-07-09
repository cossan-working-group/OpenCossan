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
    'The function require an opencossan.common.input.Input object to be evaluated.');

assert(isa(Xinp,'opencossan.common.inputs.Input'), ...
    'openCOSSAN:Function:evaluate',...
    ['the second argument must be an object of type opencossan.common.inputs.Input',...
    '\n Provided object of class %s'],class(Xinp));

for itok=1:length(Xfun.Tokens)
    if ~sum(ismember(Xinp.Names, Xfun.Tokens{itok}))
        error('openCOSSAN:Function:evaluatefunction',...
            'The required object %s is not present in the input object',Xfun.Tokens{itok});
    end
end

%% check samples/input
% if Xinp.NrandomVariables~=0 &&  isempty(Xinp.Xsamples)
%     error('openCOSSAN:Function:evaluatefunction',...
%         'The input object does not contain samples');
% end

if Xinp.DoFunctionsCheck
    Xinp.checkFunction;
end

LcheckSamples=false;

%%  Extract set of values from Xinput object
%  Extract value of samples present in Xinput
Xsamples    = Xinp.Samples;
% Extract name of parameters present in Xinput
Cnames    = [Xinp.ParameterNames Xinp.DesignVariableNames];   %get name of parameters in Xinput
Nsamples    = Xinp.Nsamples;

if Nsamples == 0
    % No Samples available.
    % Get Samples from the default values of parameters and design
    % variables
    assert(~isempty(Cnames),'openCOSSAN:Function:evaluatefunction', ...
        'Function can not be evaluated because it does not contain any parameters')
end

Nsamples    = max(1,Nsamples);

%%  Prepare strings for evaluating the Function

varargin=cell(1,length(Xfun.Tokens));

% Create executable script
SexecString=Xfun.Expression;
for n=1:length(Xfun.Tokens)
    
    Svalue=['varargin{' num2str(n) '}'];
    Stoken=strcat('<&',Xfun.Tokens{n},'&>');
    SexecString  = regexprep(SexecString,Stoken,Svalue,1);
end



for itok=1:length(Xfun.Tokens)
    %  Case Ctok{itok} is a rv
    if ismember(Xfun.Tokens{itok},Xinp.RandomVariableNames)
        varargin{itok}=Xinp.getValues('VariableNames',Xfun.Tokens(itok));
        LcheckSamples=true;
        continue
    end
    
    %% Parameter
    if ismember(Xfun.Tokens{itok},Xinp.ParameterNames)
        varargin{itok}=Xinp.Parameters.(Xfun.Tokens{itok}).Value;
        continue
    end
    
    %% Function
    if ismember(Xfun.Tokens{itok},Xinp.FunctionNames)
        varargin{itok}=Xinp.getValues('VariableNames',Xfun.Tokens(itok));
        Xinp.DoFunctionsCheck = false;
        varargin{itok} = Xinp.Functions.(Xfun.Tokens{itok}).evaluate(Xinp);
        LcheckSamples=true;
        continue
    end
    
    %% Design Variable
    if ismember(Xfun.Tokens{itok},Xinp.DesignVariableNames)
        varargin{itok}=Xinp.getValues('VariableNames',Xfun.Tokens(itok));
        LcheckSamples=true;
        continue
    end
    
    error('openCOSSAN:Function:evaluatefunction',...
        ['object ' Xfun.Tokens{itok} ' is not allowed']);
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
