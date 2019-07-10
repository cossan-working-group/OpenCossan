function Moutput = getValues(Xobj,varargin)
%getValues Retrieve the values of a variable present in the
%          Input Object
%
% The method returns the values of the samples of the objects contained in
% the input in matrix form. 
%
% The following inputs can be passed in key/value pair:
%
%  - VariableNames: string containing the name of the desired variable
%  - VariableNames: cell-array of strings containing the name of the desired
%                   variables
%
% It is mandatory to specify at least one varaible name.
%
% EXAMPLE:
% 
%  - Given an input object "Xinput" containing a Function object "Xfun1"
%
%      out = Xinput.getValues('VariableName','Xfun1')
% 
%  - Given an input object "Xinput" containing 1 RandomVariable "Xrv1" and
%    3 Function objects "Xfun1", "Xfun2" and "Xfun3", the user want to 
%    retrieve the values of Xrv11 and Xfun3
%  
%      out = Xinput.evaluateFunction('VariableNames',{'Xrv1','Xfun3'})
% 
%
% See Also: http://cossan.co.uk/wiki/index.php/getValues@Input
%
% Author: Edoardo Patelli Pierre Beaurepaire
% Copyright~1993-2015, COSSAN Working Group, University of Liverpool, UK
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

import opencossan.common.utility.*

%% Parse inputs
p = inputParser;
p.FunctionName = 'opencossan.common.inputs.Input.getValues';

% Use default values
p.addParameter('VariableNames',{},@(x)all(cellfun(@ischar,x)));
p.addParameter('VariableName','',@ischar);

p.parse(varargin{:});

if ~isempty(p.Results.VariableName)
    Cnames = {p.Results.VariableName};
else
    Cnames = p.Results.VariableNames;
end

assert(~isempty(Cnames),'openCOSSAN:Input:getValues',...
        'It is a mandatory to specify the name(s) of the variable(s)')

assert(all(ismember(Cnames,Xobj.Names)),'openCOSSAN:Input:getValues',...
    'At least one required VariableName is not present in the Input object')
    
%% Check if the variable Sname is present in the Input object
Crv        = Xobj.RandomVariableNames;
Cfun       = Xobj.FunctionNames;
Cparanames = Xobj.ParameterNames;
Csp        = Xobj.StochasticProcessNames;
Cdv        = Xobj.DesignVariableNames;

% Preallocate memory
Moutput=zeros(max(Xobj.Nsamples,1),length(Cnames));

for k=1:length(Cnames)
    Sname=Cnames{k};
    %% check if the variable is a RandomVariable
    ipos=find(strcmp(Crv,Sname),1);
    if ~isempty(ipos)
        assert(~isempty(Xobj.Samples),'openCOSSAN:Input:getValues',...
                    'if the sample object is not defined it is not possible to retrieve values from the RandomVariable');

        Moutput(:,k) = Xobj.Samples.MsamplesPhysicalSpace(:,ipos);   
    end
        
    %% check if the variable is a Function
    ipos=find(strcmp(Cfun,Sname),1);
    if ~isempty(ipos)
        if isempty(Xobj.Samples)
            assert( Xobj.NrandomVariables==0,...
                'openCOSSAN:Input:getValues','Samples are required to evaluate the Function');
        end
        Moutput(:,k) = opencossan.common.utilities.cell2float(Xobj.evaluateFunction('FunctionName',Sname));
    end
    
    %% check if the variable is a Parameter
    ipos=find(strcmp(Cparanames,Sname),1);
    if ~isempty(ipos)
        % is a Parameter
        
        Nl=length(Xobj.Parameters.(Cparanames{ipos}).value) ;
        if Nl >1
            warning('openCOSSAN:Input:getValues',...
                'Only the first member of the array Parameter is provided');
            
        end
        
        Moutput(:,k) = Xobj.Parameters.(Cparanames{ipos}).value(1);
        
    end
    
    %% check if the variable is a StochasticProcess
    ipos=find(strcmp(Csp,Sname),1);
    if ~isempty(ipos)
        if isempty(Xobj.Samples)
            % if the sample object is not define it is not possible to retrive the
            % values of the StochasticProcess
        else
            Moutput(:,k) = [];
        end
    end
    
    %% check if the variable is a DesignVariable
    ipos=find(strcmp(Cdv,Sname),1);
    if ~isempty(ipos)
        if ~isempty(Xobj.Samples)
            Moutput(:,k) = Xobj.Samples.MdoeDesignVariables(:,ipos);
        else
            Moutput(:,k) = Xobj.DesignVariables.(Cdv{ipos}).value;
            opencossan.OpenCossan.cossanDisp(['getValues returns the current value of the DesignVariable ' Sname],4)
        end
    end
end






