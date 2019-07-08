classdef LatinHypercubeSampling < Simulations
    %LATINHYPERCUBESSAMPLING Summary of this class goes here
    %   Detailed explanation goes here
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/@LatinHypercubeSampling
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
        Lsmooth=true % If is false produces points at the midpoints of the
        % above intervals: 0.5/n, 1.5/n, ..., 1-0.5/n.
        
        Scriterion='none'   % iteratively generates latin hypercube samples
        % to find the best one according to the
        % criterion criterion, which can be one of the
        % following strings:
        % 'none' No iteration
        % 'maximin' Maximize minimum distance between points
        % 'correlation' Reduce correlation
        Niterations=5  %  Number of iterates used in an attempt to improve
        % the design according to the specified criterion.
    end
    
    properties (Dependent=true)
        Ssmooth             % Convert the logic values to a string
    end
    
    methods
        
        %% Methods inheritated from the superclass
        display(Xobj)             % This method shows the summary of the Xobj
        
        Xo=apply(Xobj,varargin)   % Perform the simulation
        
        varargout=computeFailureProbability(Xobj,varargin) % Compute the failure
        % probability associated to the
        % ProbabilisticModel/SystemReliability
        
        
        %% constructor
        function Xobj= LatinHypercubeSampling(varargin)
            %COMPUTEFAILUREPROBABILITY method. This method compute the FailureProbability associate to a
            % ProbabilisticModel/SystemReliability/MetaModel by means of a Monte Carlo
            % simulation object. It returns a FailureProbability object.
            %
            % See also:
            % https://cossan.co.uk/wiki/index.php/@LatinHypercubeSampling
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
            OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'lverbose'}
                        Xobj.Lverbose=varargin{k+1};
                    case {'cov'}
                        Xobj.CoV=varargin{k+1};
                    case {'timeout'}
                        Xobj.timeout=varargin{k+1};
                    case {'nsamples'}
                        Xobj.Nsamples=varargin{k+1};
                    case {'conflevel'}
                        Xobj.confLevel=varargin{k+1};
                    case {'nbatches'}
                        Xobj.Nbatches=varargin{k+1};
                    case {'lexportsamples'}
                        Xobj.Lexportsamples=varargin{k+1};
                    case {'lintermediateresults'}
                        Xobj.Lintermediateresults=varargin{k+1};
                    case {'sbatchfolder'}
                        Xobj.SbatchFolder=varargin{k+1};
                    case {'lsmooth'}
                        Xobj.Lsmooth=varargin{k+1};
                    case {'scriterion'}
                        if any(strcmpi(varargin{k+1},{'none' 'maximin' 'correlation'}))
                            Xobj.Scriterion=varargin{k+1};
                        else
                            error('openCOSSAN:simulations:Xlatinhypercubesampling',...
                                ['No valid criterion selected ' varargin{k+1} ...
                                ' (allowed values: none maximin correlation) ']);
                        end
                    case {'niterations'}
                        Xobj.Niterations=varargin{k+1};
                    case {'nseedrandomnumbergenerator'}
                        Nseed       = varargin{k+1};
                        Xobj.RandomNumberGenerator = ...
                            RandStream('mt19937ar','Seed',Nseed);
                    case {'xrandomnumbergenerator'}
                        if isa(varargin{k+1},'RandStream'),
                            Xobj.RandomNumberGenerator  = varargin{k+1};
                        else
                            warning('openCOSSAN:simulations:LatinHypercubeSampling',...
                                ['argument associated with (' varargin{k} ') is not a RandStream object']);
                        end
                    otherwise
                        error('openCOSSAN:simulations:Xlatinhypercubesampling',...
                            ['Property Name (' varargin{k} ') not allowed']);
                end
            end
        end % constructor
        
        function Ssmooth=get.Ssmooth(Xobj)
            if Xobj.Lsmooth
                Ssmooth='on';
            else
                Ssmooth='off';
            end
        end
        
    end % methods
    
end

