function [Xsamples, varargout] = sample(Xobj,varargin)
%SAMPLE This method generate a Samples object using the selected DOE type
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/sample@DesignOfExperiments
%
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

import opencossan.common.Dataseries
import opencossan.common.Samples

%% Process inputs

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'xinput'
            Xinput=varargin{k+1};
        otherwise
            error('openCOSSAN:DesignOfExperiments:sample',...
                'Input argument %s  not allowed ',varargin{k})
    end
end

assert(logical(exist('Xinput','var')),...
    'openCOSSAN:DesignOfExperiments:sample', ...
    'The method sample requires an opencossan.common.inputs.Input object to be execured')

Ndv=Xinput.NdesignVariables;
Nrv=Xinput.NrandomVariables;
CnamesRV=Xinput.RandomVariableNames;
CnamesDV=Xinput.DesignVariableNames;
Cnames=[CnamesRV CnamesDV];

%% Check the validity of inputs
% Check whether or not any RandomVariable or DeseignVariables are defined
assert(Ndv>0 | Nrv>0,'openCOSSAN:DesignOfExperiments:sample:noDVorRV',...
     'The provided Input object does not contain neither DesignVariable nor RandomVariable')

% DeseignVariables without bounds are not accepted
if Ndv > 0
    for idv = 1:Ndv
        if Xinput.DesignVariables.(CnamesDV{idv}).LowerBound == -inf ...
                || Xinput.DesignVariables.(CnamesDV{idv}).UpperBound == inf
            error('openCOSSAN:DesignOfExperiments:sample',...
                'All Design Variables should have a defined lower & upper bounds')
        end
    end
end

% if TWO-LEVEL FACTORIAL is chosen, the dimension should be less than 25
% (due to memory issues)
if strcmp(Xobj.SdesignType,'2Levelfactorial') && (Ndv+Nrv) > 24
    error('openCOSSAN:DesignOfExperiments:sample',...
        'if central-composite type of design is chosen, the dimension (Nrv + Ndv) should be between 2 and 24')
end

% if FULL FACTORIAL is chosen & Continoous DVs are used
% then Vlevels should be provided by the user for each DV
if strcmp(Xobj.SdesignType,'FullFactorial') && isempty(Xobj.VlevelValues) && Ndv > 0
    error('openCOSSAN:DesignOfExperiments:sample',...
        ['if FullFactorial is used together with continous DesignVariable\n.', ...
        'Vlevels should be provided for each continous DesignVariable'])
end

% if BOX-BEHNKEN is chosen, the dimension should be at least 3
if strcmp(Xobj.SdesignType,'BoxBehnken') && (Ndv+Nrv) < 3
    error('openCOSSAN:DesignOfExperiments:sample',...
        'Box-behnken design of experiment requires at least 3 inputs (DesignVariable+RandomVariables >=3)')
end

% if CENTRAL COMPOSITE is chosen, the dimension should be at between 2 and 26
if strcmp(Xobj.SdesignType,'CentralComposite')
    if (Ndv+Nrv) > 26 || (Ndv+Nrv) < 2
        error('openCOSSAN:DesignOfExperiments:sample',...
            'if central-composite type of design is chosen, the dimension (Nrv + Ndv) should be between 2 and 26')
    end
end

% if USER DEFINED is chosen, the number of columns of the provided
% MdoeFactors should match Nrv + Ndv
if strcmp(Xobj.SdesignType,'UserDefined')
    assert((Ndv+Nrv)== size(Xobj.MdoeFactors,2),...
        'openCOSSAN:DesignOfExperiments:sample',...
        'Number of columns (%i) of the provided MdoeFactors should be %i',...
        size(Xobj.MdoeFactors,2),Ndv+Nrv)
    
    %% Reorder MdoeFactors
    if ~isempty(Xobj.ClevelNames)
        Vindex=zeros(1,length(Xobj.ClevelNames));
        for n=1:length(Vindex)
            pos=find(strcmp(Xobj.ClevelNames{n},Cnames));
            
            assert(~isempty(pos),'openCOSSAN:DesignOfExperiments:sample',...
                'Required variable %s not present in the Input\n Available variables: %s', ...
                Xobj.ClevelNames{n},sprintf('"%s" ',Cnames{:}))
            Vindex(n)=pos;
        end
        Xobj.MdoeFactors=Xobj.MdoeFactors(:,Vindex);
        
    end
    
end

% if the designtype is NOT FullFactorial and MDoeFactors contain values
% outside the interval [-1,1], then the input can contain only continous
% DVs and NOT discrete DVs
if ~isempty(Xobj.MdoeFactors)
    if ~isempty(find(Xobj.MdoeFactors<-1, 1)) || ~isempty(find(Xobj.MdoeFactors>1, 1))
        for idv = 1:Ndv
            if ~isempty(Xinput.DesignVariables.(CnamesDV{idv}).Vsupport)
                error('openCOSSAN:DesignOfExperiments:sample',...
                    'Discrete DVs cannot be used within DOE with coordinates outside [-1,1]')
            end
        end
    end
end


%% Construct the Vlevels vector
% No of levels is required ONLY for the FULLFACTORIAL design
if strcmp(Xobj.SdesignType,'FullFactorial')
    Vlevels = 3*ones(Ndv+Nrv,1);
    [~, VindicesA, VindicesB] = intersect(Xobj.ClevelNames,Cnames);
    Vlevels(VindicesB)   = Xobj.VlevelValues(VindicesA);
        
    % FOR DISCRETE DVs: number of levels is equal to the number of support
    % points
    for idv = 1:Ndv
        if ~isempty(Xinput.XdesignVariable.(CnamesDV{idv}).Vsupport)
            Vlevels(Nrv+idv) = length(Xinput.XdesignVariable.(CnamesDV{idv}).Vsupport);
        end
    end
end

%% Generate the DOE coordinates according to the selected design type
if strcmp(Xobj.SdesignType,'2LevelFactorial')
    Xobj.MdoeFactors = ff2n(Nrv+Ndv);
elseif strcmp(Xobj.SdesignType,'FullFactorial')
    Xobj.MdoeFactors = fullfact(Vlevels);
elseif strcmp(Xobj.SdesignType,'BoxBehnken')
    % NOTE: the parameter center is set to 1 so that there will be only
    % one sample at the mean values, i.e. at 0,0,0,...
    Xobj.MdoeFactors = bbdesign(Nrv+Ndv,'center',1);
elseif strcmp(Xobj.SdesignType,'CentralComposite')
    Xobj.MdoeFactors = ccdesign(Nrv+Ndv,'center',1,'type',Xobj.ScentralCompositeType);
end

%% Evaluate the input values according to DOE coordinates - for RandomVariables

if Nrv > 0
    % The coordinates of the DOE points are transformed to actual values
    % using the map2pyhsical method of RandomVariableSet
    % NOTE: If FULLFACTORIAL is selected, then it is necessary to map the
    % coordinates from 1,Nlevel => 0,1
    if strcmp(Xobj.SdesignType,'FullFactorial')
        for irv = 1:Nrv
            Xobj.MdoeFactors(:,irv) = (Xobj.MdoeFactors(:,irv) - 1)/max(Xobj.MdoeFactors(:,irv)-1);
        end
    end
    MdoePhysicalSpaceRV = Xinput.map2physical((Xobj.perturbanceParameter*Xobj.MdoeFactors(:,1:Nrv))); %#ok<NASGU>
else
    MdoePhysicalSpaceRV = []; %#ok<NASGU>
end

varargout{1} = Xobj;

%% Evaluate the input values according to DOE coordinates - for DVs
%
% NOTE: This mapping is done differently for the FULLFACTORIAL design and
% for the remaining desing types, mainly because fullfactorial creates
% coordinates based on defined no of levels (i.e. includes positive integer
% values such as 1,2,3,...), while the other design types generated
% coordinates between [-1,1].

if strcmp(Xobj.SdesignType,'FullFactorial')
    if Ndv > 0
        MdoePhysicalSpaceDV = zeros(size(Xobj.MdoeFactors(:,1:Ndv)));
        for idv = 1:Ndv
            % For CONTINOUS DVs
            if isempty(Xinput.XdesignVariable.(Xinput.CnamesDesignVariable{idv}).Vsupport)
                Vdummy = ...
                    linspace(Xinput.XdesignVariable.(Xinput.CnamesDesignVariable{idv}).lowerBound,...
                    Xinput.XdesignVariable.(Xinput.CnamesDesignVariable{idv}).upperBound,...
                    Vlevels(Nrv+idv));
                MdoePhysicalSpaceDV(:,idv) = Vdummy(Xobj.MdoeFactors(:,idv+Nrv));
                % For DISCRETE DVs
            else
                MdoePhysicalSpaceDV(:,idv) = ...
                    Xinput.XdesignVariable.(Xinput.CnamesDesignVariable{idv}).Vsupport(Xobj.MdoeFactors(:,idv+Nrv));
            end
        end
    else
        MdoePhysicalSpaceDV = []; %#ok<NASGU>
    end
else
    if Ndv > 0
        % The coordinates of the DOE points are transformed to actual values
        % using the following steps
        MdoePhysicalSpaceDV = zeros(size(Xobj.MdoeFactors(:,1:Ndv)));
        for idv = 1:Ndv
            % Xobj.LuseCurrentValues= TRUE => If MdoeFactor = 0, use CURRENT value of the DV
            if Xobj.LuseCurrentValues
                % Identify the indices of zeros and other values
                Vzeroindices = Xobj.MdoeFactors(:,idv+Nrv)==0;
                Vnonzeroindices = find(Xobj.MdoeFactors(:,idv+Nrv));
                % First map the zeros to the current values of the DVs
                MdoePhysicalSpaceDV(Vzeroindices,idv) = ...
                    Xinput.XdesignVariable.(Xinput.DesignVariables{idv}).Value;
                % For CONTINOUS DVs
                if isa(Xinput.DesignVariables.(Xinput.DesignVariable{idv}), 'opencossan.optimization.ContinuousDesignVariable')
                    interval = Xinput.DesignVariables.(Xinput.DesignVariablesNames{idv}).UpperBound - ...
                        Xinput.DesignVariables.(Xinput.DesignVariableNames{idv}).LowerBound;
                    MdoePhysicalSpaceDV(Vnonzeroindices,idv) = ...
                        Xinput.DesignVariables.(Xinput.DesignVariableNames{idv}).LowerBound + ...
                        unifcdf(Xobj.MdoeFactors(Vnonzeroindices,idv+Nrv),-1,1).*interval;
                    % For DISCRETE DVs
                else
                    Vindices = unidinv(unifcdf(Xobj.MdoeFactors(Vnonzeroindices,idv+Nrv),-1,1),...
                        length(Xinput.DesignVariables.(Xinput.DesignVariableNames{idv}).Support));
                    % Since unidinv returns NaN for zero, these are replaced woth the lowerbound, i.e.
                    % Vsupport(1) values
                    VNaNindices = isnan(Vindices);
                    Vindices(VNaNindices) = 1;
                    MdoePhysicalSpaceDV(Vnonzeroindices,idv) = ...
                        Xinput.DesignVariable.(Xinput.DesignVariableNames{idv}).Support(Vindices);
                end
                % Xobj.LuseCurrentValues= TRUE => If MdoeFactor = 0, use MEDIAN value of the interval of DV
            else
                % For CONTINOUS DVs
                if isa(Xinput.DesignVariables.(Xinput.DesignVariable{idv}), 'opencossan.optimization.ContinuousDesignVariable')
                    interval = Xinput.DesignVariables.(Xinput.DesignVariableNames{idv}).UpperBound - ...
                        Xinput.DesignVariables.(Xinput.DesignVariableNames{idv}).LowerBound;
                    MdoePhysicalSpaceDV(:,idv) = ...
                        Xinput.DesignVariables.(Xinput.DesignVariableNames{idv}).LowerBound + ...
                        unifcdf(Xobj.MdoeFactors(:,idv+Nrv),-1,1).*interval;
                    % For DISCRETE DVs
                else
                    Vindices = unidinv(unifcdf(Xobj.MdoeFactors(:,idv+Nrv),-1,1),...
                        length(Xinput.DesignVariables.(Xinput.DesignVariableNames{idv}).Support));
                    % Since unidinv returns NaN for zero, these are replaced woth the lowerbound, i.e.
                    % Vsupport(1) values
                    VNaNindices = isnan(Vindices);
                    Vindices(VNaNindices) = 1;
                    MdoePhysicalSpaceDV(:,idv) = ...
                        Xinput.DesignVariables.(Xinput.DesignVariableNames{idv}).Support(Vindices);
                end
            end
        end
    else
        MdoePhysicalSpaceDV = []; %#ok<NASGU>
    end
end

Sarguments='Samples(''Xinput'',Xinput';
%% Create the Samples object for the generated input values
CspNames=Xinput.CnamesStochasticProcess;

if ~isempty(CspNames)
    Nsamples=size(Xobj.MdoeFactors,1);
    for isp = 1:length(CspNames)
        if isp==1
            Xds = Dataseries('Mdata',Xinput.Xsp.(CspNames{isp}).Vmean,...
                'Mcoord',Xinput.Xsp.((CspNames{isp})).Mcoord,'Sindexname',CspNames{isp});
        else
            Xds(1,isp) = Dataseries('Mdata',Xinput.Xsp.(CspNames{isp}).Vmean,...
                'Mcoord',Xinput.Xsp.((CspNames{isp})).Mcoord,'Sindexname',CspNames{isp});
        end
    end 
    Xds = repmat(Xds,Nsamples,1); %#ok<NASGU>
    Sarguments=strcat(Sarguments,',''Xdataseries'',Xds');
end

if Ndv>0
    Sarguments=strcat(Sarguments,',''MdoeDesignVariables'',MdoePhysicalSpaceDV');
end
if Nrv>0
    Sarguments=strcat(Sarguments,',''MsamplesPhysicalSpace'',MdoePhysicalSpaceRV');
end

Sarguments=strcat(Sarguments,');');


Xsamples = eval(Sarguments);



