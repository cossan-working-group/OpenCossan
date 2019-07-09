function Cout = evaluateFunction(obj,varargin)
%EVALUATEFUNCTION evaluate the function defined in the Input object based
%on the current realizations for the RandomVariable and DesignVariable
%
% The following inputs can be passed in key/value pair:
%
%  - FunctionName: string containing the name of the function to be evalauted 
%  - FunctionNames: cell-array of strings containing the name of the functions to be evalauted 
%
% Invoking the method with not inputs returns the function values of all
% the functions contained in the input object.
%
% EXAMPLE:
% 
%  - Given an input object "Xinput" containing a Function object "Xfun1"
%
%      out = Xinput.evaluateFunction('FunctionName','Xfun1')
% 
%  - Given an input object "Xinput" containing 3 Function object
%  "Xfun1", "Xfun2" and "Xfun3", the user want to retrieve the values of
%  Xfun1 and Xfun3
%
%      out = Xinput.evaluateFunction('FunctionNames',{'Xfun1','Xfun3'})
% 
%
% See also: https://cossan.co.uk/wiki/index.php/evaluateFunction@Function
%
% Author: Matteo Broggi, Edoardo Patelli
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

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

%TODO: Maybe this method should be private, it is called

%% Parse inputs
p = inputParser;
p.FunctionName = 'opencossan.common.inputs.Input.evaluateFunction';

% Use default values
p.addParameter('FunctionNames',obj.FunctionNames,@(x)all(cellfun(@ischar,x)));
p.addParameter('FunctionName','',@ischar);

p.parse(varargin{:});

if ~isempty(p.Results.FunctionName)
    Cfun = {p.Results.FunctionName};
else
    Cfun = p.Results.FunctionNames;
end

%% Evaluate Function
Nfunctions=length(Cfun);
% preallocate memory
if ~isempty(obj.Samples)
    Cout    = cell(obj.Nsamples,Nfunctions);   %cell to store values
else
    Cout    = cell(1,Nfunctions);
end

for ifun=1:Nfunctions
    Mout =obj.Functions.(Cfun{ifun}).evaluate(obj);
    
    % If the function returns only a scalar value, remap the value for all
    % the samples
    if size(Mout,1)==1
        Mout=repmat(Mout,obj.Nsamples,1);
    end
    
    for n=1:obj.Nsamples
        Cout{n,ifun}=Mout(n,:);
    end
end

