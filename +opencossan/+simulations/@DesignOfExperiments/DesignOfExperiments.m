classdef DesignOfExperiments < opencossan.simulations.Simulations
    %DESIGNOFEXPERIMENTS Class definition
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/@DesignOfExperiments
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
    properties
        SdesignType            = '2LevelFactorial';  % Type of DOE
        ScentralCompositeType  = 'faced';            % Type of the Central-Composite Design
        MdoeFactors                                  % Matrix containing the coordinates of the input samples
        perturbanceParameter   = 1;                  % Parameter multiplied with the Mdoefactors matrix
        LuseCurrentValues      = true;               % Parameter to use the current values of the DV's or not
        VlevelValues           = [];                 % Levels for the continous DVs (required only for FULLFACTORIAL)
        ClevelNames                                  % Corresponding DV names to the values defined in Vlevelvalues vector
    end
    
    properties (SetAccess = private)
        CdesignTypeAvailable={'2LevelFactorial' 'FullFactorial' 'BoxBehnken'  ...
            'CentralComposite' 'UserDefined'}
        
        CcentralCompositeTypeAvailable={'faced' 'inscribed'}
    end
    
    methods
        
        %% Methods inheritated from the superclass
        display(Xobj)             % This method shows the summary of the Xobj
        
        function computeFailureProbability(Xobj,~)
            error('openCOSSAN:DesignOfExperiments:DesignOfExperiments',...
                ['method computeFailureProbability not available for the ' class(Xobj) ' object \n'])
        end
        
        Xo=apply(Xobj,varargin)   % Perform the simulations
        
        %% constructor
        function Xobj= DesignOfExperiments(varargin)
            %DESIGNOFEXPERIMENTS constructor
            %
            % See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/@DesignOfExperiments
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
            
            
            %% Validate input arguments
            opencossan.OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'sdesigntype'}
                        assert(ismember(varargin{k+1},Xobj.CdesignTypeAvailable), ...
                            'openCOSSAN:DesignOfExperiments', ...
                            strcat('Available options for SdesignType are: ',sprintf('\n* %s', Xobj.CdesignTypeAvailable{:})))
                        Xobj.SdesignType=varargin{k+1};
                    case {'scentralcompositetype'}
                        assert(ismember(lower(varargin{k+1}),Xobj.CcentralCompositeTypeAvailable), ...
                            'openCOSSAN:DesignOfExperiments', ...
                            strcat('Available options for %s are: ',sprintf('\n* %s', Xobj.CcentralCompositeTypeAvailable{:})),varargin{k})
                        Xobj.ScentralCompositeType=lower(varargin{k+1});
                    case {'mdoefactors'}
                        Xobj.MdoeFactors=varargin{k+1};
                    case {'vlevelvalues'}
                        Xobj.VlevelValues=varargin{k+1};
                    case {'clevelnames'}
                        Xobj.ClevelNames=varargin{k+1};
                    case {'perturbanceparameter'}
                        Xobj.perturbanceParameter=varargin{k+1};
                    case {'lusecurrentvalues'}
                        Xobj.LuseCurrentValues=varargin{k+1};
                    case {'timeout'}
                        Xobj.timeout=varargin{k+1};
                    case {'nbatches'}
                        Xobj.Nbatches=varargin{k+1};
                    case {'lexportsamples'}
                        Xobj.Lexportsamples=varargin{k+1};
                    case {'lintermediateresults'}
                        Xobj.Lintermediateresults=varargin{k+1};
                    case {'sbatchfolder'}
                        Xobj.SbatchFolder=varargin{k+1};
                    otherwise
                        error('openCOSSAN:DesignOfExperiments',...
                            'Property name %s not allowed', varargin{k});
                end
            end
            
            % if userdefined DOE is selected, the user has to provide the input samples, i.e. Mfactors matrix
            if strcmp(Xobj.SdesignType,'UserDefined') && isempty(Xobj.MdoeFactors)
                error('openCOSSAN:DesignOfExperiments',...
                    'If the Design Type is selected as UserDefined, MdoeFactors matrix has to be provided')
            end
            
            
            % perturbance parameter should be positive
            assert(Xobj.perturbanceParameter > 0, ...
                'openCOSSAN:DesignOfExperiments',...
                'Please provide a positive value for the perturbance parameter (%e)',Xobj.perturbanceParameter)
            
            if ~isempty(Xobj.VlevelValues)
                assert(length(Xobj.VlevelValues)==length(Xobj.ClevelNames),...
                    'openCOSSAN:DesignOfExperiments',...
                    'The length of level values (%i) must be equal to the length of levelNames (%i)',...
                    length(Xobj.VlevelValues),length(Xobj.ClevelNames))
            end
        end % constructor
    end % methods
end

