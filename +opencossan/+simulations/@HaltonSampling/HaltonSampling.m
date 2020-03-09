classdef HaltonSampling < opencossan.simulations.Simulations
    %HaltonSampling class
    %   Haltonset is a quasi-random point set class that produces points
    %   from the Halton sequence.
    %   This class is based on the Haltonset Matlab class
    %   These sequences use different prime bases to form successively
    %   finer uniform partitions of the unit interval in each dimension.
    
    properties
        Nskip=1           % Number of initial points omitted
        Nleap=0            % Interval between points
        ScrambleMethod    % Scramble settings
    end
    
    methods
        
        %% Methods inheritated from the superclass
        
        Xo=apply(Xobj,varargin)   % Perform the simulation
        
        varargout=computeFailureProbability(Xobj,varargin) % Compute the failure
        % probability associated to the
        % ProbabilisticModel/SystemReliability
        
        %% constructor
        function Xobj= HaltonSampling(varargin)
            %HALTONSAMPLING method.
            %
            % See also:
            % https://cossan.co.uk/wiki/index.php/@HaltonSampling
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
                    case {'lintermediateresults'}
                        Xobj.Lintermediateresults=varargin{k+1};
                    case {'nskip'}
                        Xobj.Nskip=varargin{k+1};
                    case {'nleap'}
                        Xobj.Nleap=varargin{k+1};
                    case {'scramblemethod','sscramblemethod'}
                        Xobj.ScrambleMethod =varargin{k+1};    % Scramble settings
                    case {'nseedrandomnumbergenerator'}
                        Nseed       = varargin{k+1};
                        Xobj.RandomNumberGenerator = ...
                            RandStream('mt19937ar','Seed',Nseed);
                    case {'xrandomnumbergenerator'}
                        if isa(varargin{k+1},'RandStream'),
                            Xobj.RandomNumberGenerator  = varargin{k+1};
                        else
                            warning('openCOSSAN:simulations:HaltonSampling',...
                                ['argument associated with (' varargin{k} ') is not a RandStream object']);
                        end
                    otherwise
                        error('openCOSSAN:simulations:HaltonSampling:HaltonSampling',...
                            ['Field name (' varargin{k} ') not allowed']);
                end
            end
            
            %% Check if the field Nleap and Nskip have been defined
            if isempty(Xobj.Nskip) || isempty(Xobj.Nleap)
                error('openCOSSAN:simulations:HaltonSampling',...
                    'Please provide both of the field name Nskip and Nleap');
            end
            
            if Xobj.Nbatches>Xobj.Nsamples
                error('openCOSSAN:simulations:HaltonSampling',...
                    ['The number of batches (' num2str(Xobj.Nbatches) ...
                    ') can not be greater than the number of samples (' ...
                    num2str(Xobj.Nsamples) ')' ]);
            end
            
        end % constructor
    end % methods
    
    
end

