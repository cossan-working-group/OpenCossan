function Xs = add(Xs,varargin)
%ADD method adds samples to Samples object. %
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Add@Samples
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

%% Process inputs
% opencossan.OpenCossan.validateCossanInputs(varargin{:});

% Store some local variable
CsamplesVariables=Xs.Cvariables;

%% Add samples
for k=1:2:length(varargin),
    switch lower(varargin{k})
        % Add samples from random variables
        case {'msamplesphysicalspace'}
            % Matrix of sample in physical space
            assert(size(varargin{k+1},2)==length(Xs.CnamesRandomVariable)+length(Xs.CnamesIntervalVariable), ...
                'openCOSSAN:Samples:add',...
                'The number of colums of the MsamplesPhysicalSpace must be %i',...
                length(CsamplesVariables));
            % Map the sample from the physical space to the hypercube
            MsamplesHyperCubeAdd=zeros(size(varargin{k+1},1),length(Xs.CnamesRandomVariable));
            irv=0;
            % Cycle over all the RandomVariableSet
            for n=1:length(Xs.Xrvset)
                MsamplesHyperCubeAdd(:,irv+(1:Xs.Xrvset{n}.Nrv))= ...
                    Xs.Xrvset{n}.physical2cdf(varargin{k+1}(:,irv+(1:Xs.Xrvset{n}.Nrv)));
                irv=irv+Xs.Xrvset{n}.Nrv;
            end
            Xs.MsamplesHyperCube =[Xs.MsamplesHyperCube; MsamplesHyperCubeAdd];
            % Map the sample from the physical space to the hypersphere
            if ~isempty(Xs.CnamesIntervalVariable)
                MsamplesHyperSphereAdd=zeros(size(varargin{k+1},1),length(Xs.CnamesIntervalVariable));
                iiv=0;
                % Cycle over all the RandomVariableSet
                for n=1:length(Xs.Xbset)
                    MsamplesHyperSphereAdd(:,iiv+(1:Xs.Xbset{n}.Niv))= ...
                        Xs.Xbset{n}.map2hypersphere(varargin{k+1}(:,irv+iiv+(1:Xs.Xbset{n}.Niv)));
                    iiv=iiv+Xs.Xbset{n}.Niv;
                end
                Xs.MsamplesHyperSphere =[Xs.MsamplesHyperSphere; MsamplesHyperSphereAdd];
            end
        case {'msamplesstandardnormalspace'}
            % Matrix of sample in Standard Normal Spave
            if size(varargin{k+1},2)~=length(CsamplesVariables)
                error('openCOSSAN:Samples:add',...
                    ['The number of colums of the MsamplesStandardNormalSpace must be ' ...
                    num2str(length(CsamplesVariables))]);
            end
            
            % Cycle over all the RandomVariableSet
            MsamplesHyperCubeAdd=normcdf(varargin{k+1});
            
            Xs.MsamplesHyperCube =[Xs.MsamplesHyperCube; MsamplesHyperCubeAdd];
        case {'msampleshypercube','mcdf'},
            % Matrix of sample in correlated hypercube
            if size(varargin{k+1},2)~=length(Xs.CnamesRandomVariable)
                error('openCOSSAN:Samples:add',...
                    ['The number of colums of the MsamplesHyperCube must be ' ...
                    num2str(length(CsamplesVariables))]);
            end
            %  Samples in hypercube space
            Xs.MsamplesHyperCube =[Xs.MsamplesHyperCube; varargin{k+1}];
        case {'msampleshypersphere','mhs'},
            % Matrix of sample in correlated hypersphere
            if size(varargin{k+1},2)~=length(Xs.CnamesIntervalVariable)
                error('openCOSSAN:Samples:add',...
                    ['The number of colums of the MsamplesHyperSphere must be ' ...
                    num2str(length(Xcs.CnameRandomVariable))]);
            end
            %  Samples in hypersphere space
            Xs.MsamplesHyperSphere =[Xs.MsamplesHyperSphere; varargin{k+1}];    
        case {'msamplesdoedesignvariables'},
            % Matrix of the design of experiment for design variables
            if size(varargin{k+1},2)~=size(Xs.MdoeDesignVariables,2)
                error('openCOSSAN:Samples:add',...
                    ['The number of colums of the MsamplesHyperCube must be ' ...
                    num2str(size(Xs.MdoeDesignVariables,2))]);
            end
            Xs.MdoeDesignVariables  =[Xs.MdoeDesignVariables; varargin{k+1}];
        case {'vweights'}
            % Add weights
            Xs.Vweights=[Xs.Vweights; varargin{k+1}];   %add weights
        case {'xsamples'}
            % Add a Samples object
            assert(isa(varargin{k+1},'opencossan.common.Samples'), ...
                'openCOSSAN:Samples:add',...
                'An object of class opencossan.common.Samples is required after the FieldName %s\nProvided object tpye %s', ...
                varargin{k}, class(varargin{k+1}));
            
            % Check if the passed Samples object contains all the variables
            % of the original sample (thus, to merge them) or none (thus,
            % to add the new variable)
            CvariablesAddSamples=varargin{k+1}.Cvariables;

            if length(CsamplesVariables)>=length(CvariablesAddSamples)
                Vcheck=ismember(CsamplesVariables,CvariablesAddSamples);
            else
                for n=1:length(CvariablesAddSamples)
                    Vcheck(n)=any(strcmp(CsamplesVariables,CvariablesAddSamples(n)));
                end
            end
            
            if all(Vcheck==1)
                % The samples object contains the same variables, the two
                % samples will be merged
                Xs.MsamplesHyperCube= [Xs.MsamplesHyperCube; varargin{k+1}.MsamplesHyperCube];    %add samples in standard normal space
                Xs.MsamplesHyperSphere= [Xs.MsamplesHyperSphere; varargin{k+1}.MsamplesHyperSphere];
                Xs.Vweights  = [Xs.Vweights; varargin{k+1}.Vweights];    %add weights
                Xs.MdoeDesignVariables  =[Xs.MdoeDesignVariables; varargin{k+1}.MdoeDesignVariables];
                % Add dataSeries
                if isempty(Xs.Xdataseries) && ~isempty(varargin{k+1}.Xdataseries)
                    Xs.Xdataseries = varargin{k+1}.Xdataseries;
                    Xs.XstochasticProcess = varargin{k+1}.XstochasticProcess;
                    Xs.CnamesStochasticProcess =varargin{k+1}.CnamesStochasticProcess;
                elseif ~isempty(Xs.Xdataseries) && ~isempty(varargin{k+1}.Xdataseries)
                    % The dataseries share the variables --> Merge by
                    % adding the samples of the new dataseries to the
                    % existing one
                    Xs.Xdataseries = Xs.Xdataseries.addSamples('Xdataseries',varargin{k+1}.Xdataseries);
                end
                
            elseif all(Vcheck==0)
                % The Samples objects do not share any variable. The passed
                % sample will be added to the original Add/merge Random variables sample matrix
                if isempty(Xs.Xrvset) && ~isempty(varargin{k+1}.Xrvset)
                    Xs.Xrvset=varargin{k+1}.Xrvset;
                    Xs.MsamplesHyperCube= varargin{k+1}.MsamplesHyperCube;
                    Xs.Vweights  = varargin{k+1}.Vweights;
                elseif ~isempty(Xs.Xrvset) && ~isempty(varargin{k+1}.Xrvset)
                    Xs.Xrvset(end+1)=varargin{k+1}.Xrvset;
                    
                    assert (size(Xs.MsamplesHyperCube,1)==size(varargin{k+1}.MsamplesHyperCube,1),...
                        'openCOSSAN:Samples:add',...
                        strcat('The two samples object should contain the same number of samples\n',...
                        '* First Samples object contains %i samples',...
                        '* Second Samples object contains %i samples'),...
                        size(Xs.MsamplesHyperCube,1),size(varargin{k+1}.MsamplesHyperCube,1));
                    
                    Xs.MsamplesHyperCube= [Xs.MsamplesHyperCube varargin{k+1}.MsamplesHyperCube];    %add samples in standard normal space
                    
                    if isempty(Xs.Vweights)
                        Xs.Vweights  = varargin{k+1}.Vweights;    %add weights
                    end
                end
                if isempty(Xs.Xbset) && ~isempty(varargin{k+1}.Xbset)
                    Xs.Xbset=varargin{k+1}.Xbset;
                    Xs.MsamplesHyperSphere= varargin{k+1}.MsamplesHyperSphere;
                    Xs.Vweights  = varargin{k+1}.Vweights;
                elseif ~isempty(Xs.Xbset) && ~isempty(varargin{k+1}.Xbset)
                    Xs.Xbset(end+1)=varargin{k+1}.Xbset;
                    assert (size(Xs.MsamplesHyperSphere,1)==size(varargin{k+1}.MsamplesHyperSphere,1),...
                        'openCOSSAN:Samples:add',...
                        strcat('The two samples object should contain the same number of samples\n',...
                        '* First Samples object contains %i samples',...
                        '* Second Samples object contains %i samples'),...
                        size(Xs.MsamplesHyperSphere,1),size(varargin{k+1}.MsamplesHyperSphere,1));
                    
                    Xs.MsamplesHyperSphere= [Xs.MsamplesHyperSphere varargin{k+1}.MsamplesHyperSphere];   
                    if isempty(Xs.Vweights)
                        Xs.Vweights  = varargin{k+1}.Vweights;    %add weights
                    end
                end
                % Add dataSeries
                if isempty(Xs.Xdataseries) && ~isempty(varargin{k+1}.Xdataseries)
                    Xs.Xdataseries = varargin{k+1}.Xdataseries;
                    Xs.XstochasticProcess = varargin{k+1}.XstochasticProcess;
                    Xs.CnamesStochasticProcess =varargin{k+1}.CnamesStochasticProcess;
                elseif ~isempty(Xs.Xdataseries) && ~isempty(varargin{k+1}.Xdataseries)
                    assert (size(Xs.Xdataseries,1)==size(varargin{k+1}.Xdataseries,1),...
                        'openCOSSAN:Samples:add',...
                        strcat('The two samples object should contain the same number of samples\n',...
                        '* First Samples object contains %i samples',...
                        '* Second Samples object contains %i samples'),...
                        size(Xs.Xdataseries,1),size(varargin{k+1}.Xdataseries,1));
                    
                    Xs.Xdataseries = [Xs.Xdataseries, varargin{k+1}.Xdataseries];
                    Xs.XstochasticProcess = [Xs.XstochasticProcess, varargin{k+1}.XstochasticProcess];
                    Xs.CnamesStochasticProcess = [Xs.CnamesStochasticProcess, varargin{k+1}.CnamesStochasticProcess];
                end
                % Add DesignVariable doe matrix
                if isempty(Xs.MdoeDesignVariables) && ~isempty(varargin{k+1}.MdoeDesignVariables)
                    Xs.CnamesDesignVariables =varargin{k+1}.CnamesDesignVariables;
                    Xs.MdoeDesignVariables = varargin{k+1}.MdoeDesignVariables;
                elseif ~isempty(Xs.MdoeDesignVariables) && ~isempty(varargin{k+1}.MdoeDesignVariables)
                    assert (size(Xs.MdoeDesignVariables,1)==size(varargin{k+1}.MdoeDesignVariables,1),...
                        'openCOSSAN:Samples:add',...
                        strcat('The two samples object should contain the same number of samples\n',...
                        '* First Samples object contains %i samples',...
                        '* Second Samples object contains %i samples'),...
                        size(Xs.MdoeDesignVariables,1),size(varargin{k+1}.MdoeDesignVariables,1));
                    
                    Xs.MdoeDesignVariables = [Xs.MdoeDesignVariables, varargin{k+1}.MdoeDesignVariables];
                    Xs.CnamesDesignVariables = [Xs.CnamesDesignVariables varargin{k+1}.CnamesDesignVariables];
                end
                
                
            else
                error('openCOSSAN:Samples:add',...
                    'Either the two samples objects have all the same inputs (samples merged) or none (samples added)');
            end
            
        otherwise
            error('openCOSSAN:Samples:add', ...
                'PropertyName %s not valid ', varargin{k})
    end
    
    % Check consistency of the number of samples/realization
    if isempty(Xs.Xdataseries)
        VsamplesDS=0;
    else
        VsamplesDS = Xs.Xdataseries(1).Nsamples;
    end
    
    Vsamples=[size(Xs.MsamplesHyperCube,1) VsamplesDS size(Xs.MdoeDesignVariables,1) size(Xs.MsamplesHyperSphere,1)];
    VsamplesCheck=Vsamples(Vsamples~=0);
    
    assert(all(VsamplesCheck==VsamplesCheck(1)),...
    'openCOSSAN:Samples:add:InconsistentSamplesSize', ...
    ['No consistent number of samples for all the variables\n'....
    'Samples RandomVariables   : %i\n',...
    'Samples Dataseries        : %i\n',...
    'Samples DesignOfExperiment: %i\n',...
    'Samples IntervalVariables: %i'],...
    Vsamples(1),Vsamples(2),Vsamples(3),Vsamples(4))
    
end
    
