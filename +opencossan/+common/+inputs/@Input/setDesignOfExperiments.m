function Xobj = setDesignOfExperiments(Xobj,varargin)
%SETDESIGNOFEXPERIMENTS This method is used to define the realizations of
%the design of experiments 
%
%
% Author:
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

OpenCossan.validateCossanInputs(varargin{:});

if isempty(varargin)
    error('COSSAN:Input:setDesignOfExperiments',...
        'The set method makes no sense without arguments');
end

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'csnames'}
            Cnames=varargin{k+1};
            
            assert(all(ismember(Cnames,Xobj.Cnames)),...
                'COSSAN:Input:setDesignOfExperiments',...
                ['Name of the design variable does not match with the names of the design variable present in the input object\n',...
                '\nAvailable DesignVariables: ' sprintf('\n* "%s"',Xobj.Cnames{:}), ...
                '\nRequired DesignVariables: ' sprintf('\n* "%s"',Cnames{:})])
        case {'msamples','mvalues'}
            Msamples=varargin{k+1};
        otherwise
            error('COSSAN:Input:setDesignOfExperiments', ...
                'The PropertyName %s is not valid',varargin{k});
            
    end
end

assert(size(Msamples,2)==length(Cnames),...
    'COSSAN:Input:setDesignOfExperiments',...
    'Number of colums of Msamples is %i, number of variables %i ',size(Msamples,2),length(Cnames))


%% DO SET
VmappingDV=find(ismember(Cnames,Xobj.CnamesDesignVariable));
VmappingRV=find(ismember(Cnames,Xobj.CnamesRandomVariable));

% set samplesDesignOfExpetiments and samplesRandomVariables
if isempty(Xobj.Xsamples)
    Xsmp=Samples('Xinput',Xobj, ...
        'Msamplesdoedesignvariables',Msamples(:,VmappingDV),...
        'MsamplesPhysicalSpace',Msamples(:,VmappingRV));
else
    Xsmp=Xobj.Xsamples.set('Msamplesdoedesignvariables',Msamples(:,VmappingDV),...
                            'MsamplesPhysicalSpace',Msamples(:,VmappingRV));
end

Xobj.Xsamples=Xsmp;
end



