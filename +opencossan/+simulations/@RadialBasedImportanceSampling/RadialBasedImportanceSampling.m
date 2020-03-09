classdef RadialBasedImportanceSampling < opencossan.simulations.Simulations
    %RADIALBASEDIMPORTANCESAMPLING COSSAN class to perform reliability
    %analysis
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/computeFailureProbability@Simulation
    %
    % Author: Silvia Tolo
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
    
    %% Properties
    properties %public access
        MVdirection             %Initial Important directions in the physical space
        acceptableError = 0.2   %Termination for acceptable error
    end
    
    properties(Access=private) %private access
        %Nsim
        DeltaBeta=0.1/1.1;
    end
    
    methods
        
        % compute failure probability
        Xpf = computeFailureProbability(Xobj,Xpm)
        
        XsimOut = apply(Xobj,Xtarget) % Perform the simulation
        
        
        Xsamples=sample(Xobj,varargin) % Generate samples in the unit hypercube
        
        [beta, MPoints, VpfValues] = lineSearch(Xobj, varargin)
        
        %% Constructor
        
        function Xobj=RadialBasedImportanceSampling(varargin)
            % RadialBasedImportanceSampling constructor
            %
            % See also:
            % https://cossan.co.uk/wiki/index.php/@RadialBasedImportanceSampling
            %
            % Author: Silvia Tolo
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
            OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    %% properties inherited from Simulations
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
                    case {'sbatchfolder'}
                        Xobj.SbatchFolder=varargin{k+1};
                        %                     case {'lexportsamples'}
                        %                         Xobj.Lexportsamples=varargin{k+1};
                    case {'lintermediateresults'}
                        Xobj.Lintermediateresults=varargin{k+1};
                    case {'nseedrandomnumbergenerator'}
                        Nseed       = varargin{k+1};
                        Xobj.RandomNumberGenerator = ...
                            RandStream('mt19937ar','Seed',Nseed);
                    case {'xrandomnumbergenerator'}
                        if isa(varargin{k+1},'RandStream'),
                            Xobj.RandomNumberGenerator  = varargin{k+1};
                        else
                            warning('openCOSSAN:simulations:MonteCarlo',...
                                ['argument associated with (' varargin{k} ') is not a RandStream object']);
                        end
                        %% properties specific to RadialBasedImpotanceSampling
                    case {'mvdirection'}
                        Xobj.MVdirection=varargin{k+1};
                    case {'acceptableerror'}
                        Xobj.acceptableError
                    otherwise
                        error('openCOSSAN:simulations:MonteCarlo',...
                            ['Field name (' varargin{k} ') not allowed']);
                end
            end
            
            if Xobj.Nbatches>Xobj.Nsamples
                error('openCOSSAN:simulations:RadialBasedImportanceSampling',...
                    ['The number of batches (' num2str(Xobj.Nbatches) ...
                    ') can not be greater than the number of samples (' ...
                    num2str(Xobj.Nsamples) ')' ]);
            end
            
            
        end % end constructor
        
    end %end methods
    
    
    
end %end class

