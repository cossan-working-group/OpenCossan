function Xobj = set(Xobj,varargin)
%SET This method is used to change the value of a property of an object present
%in the Input object.
%
%  For instance it is possible to change the mean of a RandomVariable
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/set@Input
%
% Copyright~1993-2014, COSSAN Working Group, University of Liverpool, UK
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

assert(nargin>1, ...
    'COSSAN:Input:set',...
    'The set method makes no sense without arguments');

% TODO: use new input parser
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'sname','sobjectname'}
            Sname=varargin{k+1};
            
            assert(ismember(Sname,Xobj.Names),...
                'COSSAN:Input:set',...
                ['The object named %s is not present in the Input object\n',...
                '\nAvailable object: ' sprintf('\n* "%s"',Xobj.Names{:})], Sname)
        case {'spropertyname'}
            SpropertyName=varargin{k+1};
        case {'value','vvalues','svalue'}
            value=varargin{k+1};
        case {'msamples','msample'}
            Msamples=varargin{k+1};
            if size(Msamples,2)~=Xobj.NrandomVariables
                error('COSSAN:Input:set',...
                    ['The length of the rv must be equal to ' ...
                    'the number of samples  present in the Input object']);
            end
            Xobj.Samples=Samples('Xinput',Xobj,'MX',Msamples);
        case {'tsamples','tsample'}
            Tsamples=varargin{k+1};
            Xobj.Samples=Samples('Xinput',Xobj,'Tsamples',Tsamples);
        case {'xsamples','xsample'}
            assert(isa(varargin{k+1},'opencossan.common.Samples'), ...
                'COSSAN:Input:set',...
                'The %s  is not a Samples object',inputname(k+1))
            
            Xobj.Samples=varargin{k+1};
            
            % check Xsample
            if ~all(ismember(Xobj.Samples.Cvariables,...
                    [Xobj.RandomVariableNames Xobj.StochasticProcessNames Xobj.DesignVariableNames]))
                error('COSSAN:Input:set',...
                    'The Samples object does not contain the same RandomVariables, StochasticProcess and Designvariable defined in the Input object');
            end
        otherwise
            error('COSSAN:Input:set', ...
                'The PropertyName %s is not valid',varargin{k});
            
    end
end

%% DO SET

if exist('SpropertyName','var')
    switch lower(strtrim(SpropertyName))
        case {'mean','std','sdistribution','variance','parameter1','parameter2','parameter3','parameter4'}
            % If it is a RandomVariable
            Crvsnames=Xobj.RandomVariableSetNames;
            for n=1:length(Crvsnames)
                if ismember(Sname,Xobj.RandomVariableSets.(Crvsnames{n}).Names)
                    Xobj.RandomVariableSets.(Crvsnames{n})= ...
                        Xobj.RandomVariableSets.(Crvsnames{n}).set('Sname',Sname,SpropertyName,value);
                    return
                end
            end
            % If it is a Parameter
        case {'parametervalue'}
            assert(ismember(Sname,Xobj.ParameterNames),...
                'COSSAN:Input:set','%s is not a Parameter',Sname)
            
            Xobj.Parameters.(Sname).value  = value;
            
        case {'designvariablevalue','lowerbound','upperbound','vsupport'}
            % if it is a DesignVariable
            assert(ismember(Sname,Xobj.DesignVariableNames),...
                'COSSAN:Input:set','%s is not a DesignVariable',Sname)
            
            Xobj.DesignVariables.(Sname)  = ...
                Xobj.DesignVariables.(Sname).set(SpropertyName,value);
        otherwise
            error('COSSAN:Input:set',...
                'The method name %s is not available for the object %s', ...
                SpropertyName,Sname)
    end
end



