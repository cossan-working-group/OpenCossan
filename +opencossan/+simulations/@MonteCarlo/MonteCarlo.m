classdef MonteCarlo < opencossan.simulations.Simulations
    %MONTECARLO Monte Carlo simulation method
    % 
    % See also: https://cossan.co.uk/wiki/index.php/@MonteCarlo
    %
    % Author: Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    % =====================================================================
    % This file is part of OpenCossan.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % OpenCossan is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % OpenCossan is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License
    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================

    
    methods
        
       %% Methods inheritated from the superclass 
       display(Xobj)    % show object details 
       
       XsimOut = apply(Xmc,Xtarget)     % Performe Monte Carlo Simulation
             
       [Xpf,XsimOut]=computeFailureProbability(Xobj,Xtarget)      % Esitmate FailureProbability
       
       Xsamples = sample(Xobj,varargin) % Generate samples using MC method
        
        %% constructor 
        function Xobj= MonteCarlo(varargin)
            % Validate input arguments
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
                    case {'sbatchfolder'}
                        Xobj.SbatchFolder=varargin{k+1};   
                    case {'lexportsamples'}
                        Xobj.Lexportsamples=varargin{k+1};
                    case {'lintermediateresults'}
                        Xobj.Lintermediateresults=varargin{k+1};
                    case {'nseedrandomnumbergenerator'}
                        Nseed       = varargin{k+1};
                        Xobj.XrandomStream = ...
                            RandStream('mt19937ar','Seed',Nseed);
                    case {'xrandomnumbergenerator'}
                        if isa(varargin{k+1},'RandStream'),
                            Xobj.XrandomStream  = varargin{k+1};    
                        else
                            warning('openCOSSAN:simulations:MonteCarlo',...
                              ['argument associated with (' varargin{k} ') is not a RandStream object']);
                        end
                    otherwise
                        error('openCOSSAN:simulations:MonteCarlo',...
                              ['Field name (' varargin{k} ') not allowed']);
                end
            end 
            
            if Xobj.Nbatches>Xobj.Nsamples
                error('openCOSSAN:simulations:MonteCarlo',...
                      ['The number of batches (' num2str(Xobj.Nbatches) ...
                      ') can not be greater than the number of samples (' ...
                      num2str(Xobj.Nsamples) ')' ]);
            end
        end % constructor

    end % methods 
        
end

