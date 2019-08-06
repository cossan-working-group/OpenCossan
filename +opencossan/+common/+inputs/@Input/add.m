function obj = add(obj,varargin)
%ADD This method add an object to the Input object.
%
% To add an object into input, the user must pass to the add method an
% object and a name in pair/value.
% 
%  - MEMBER: object to be passed
%  - NAME: name of the input inside OpenCossan
%
% Example:
% 
%   Xinput = Xinput.add('Member',Parameter('value1'),'Name','Par1')
% 
% See Also: http://cossan.co.uk/wiki/index.php/Add@Input
%
% Author: Edoardo Patelli
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

p = inputParser;
p.FunctionName = 'opencossan.common.inputs.Input.add';

% Use default values
p.addParameter('Member',[]);
p.addParameter('Name',"");

p.parse(varargin{:})

XaddObject=p.Results.Member;
Sname = p.Results.Name;


if ~isa(XaddObject,'opencossan.common.Samples')
    % Check if the variable has a name
    assert(logical(exist('Sname','var')),'openCOSSAN:Input:add:noName',...
    'It is NOT possible to add an object without defining its name')

    % Check if the variable is already present in the Input object
    assert(~ismember(Sname,obj.Names),'openCOSSAN:Input:add:duplicate',...
    'An object with the name %s is already present in the Input',Sname)
end

%% Processing Inputs
switch class(XaddObject)
    case 'opencossan.common.inputs.Parameter'
            obj.Parameters.(Sname)=XaddObject;
    case {'opencossan.optimization.ContinuousDesignVariable', ...
          'opencossan.optimization.DiscreteDesignVariable'}
        obj.Samples =[];
        obj.Members(Sname) = XaddObject;
    case {'opencossan.common.inputs.random.RandomVariableSet','opencossan.common.inputs.GaussianMixtureRandomVariableSet'}
        obj.Samples =[]; % Remove/reset Samples object
        obj.RandomVariableSets.(Sname)=XaddObject;       
%     case 'opencossan.intervals.BoundedSet'
%         obj.Xsamples =[];
%         obj.Xbset.(Sname)=XaddObject;
    case {'opencossan.common.inputs.stochasticprocess.KarhunenLoeve',...
          'opencossan.common.inputs.stochasticprocess.AtkinsonSilva'}
        obj.Samples =[];
        obj.StochasticProcesses.(Sname)=XaddObject;       
        
        assert(~isempty(XaddObject.EigenVectors),...
                'openCOSSAN:Input:add:NoKLtermStochasticProcess',...
                    'The KL-terms of the stochastic process are not determined');
    case 'opencossan.common.inputs.Function'
            obj.Functions.(Sname)=XaddObject;
    case 'opencossan.common.Samples'
        if ~isa(obj.Samples,'opencossan.common.Samples')
            obj.Samples     = XaddObject;
        else
            obj.Samples     = add(obj.Xsamples,'Xsamples', XaddObject);
        end
    otherwise
        error('openCOSSAN:inputs:Inputs:add', ...
            'The object type %s can not be added to the Input object',class(XaddObject));
end

if obj.DoFunctionsCheck
    checkFunction( obj );
end


