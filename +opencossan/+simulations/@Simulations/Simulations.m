classdef (Abstract) Simulations
    % Abstract class for creating simulations methods
    % Subclass constructor should accept
    % property name/property value pairs
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/@Simulation
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
    
    properties (Dependent = true, SetAccess = protected)
        SbatchName     % File name of the current batch
    end
    
    properties % Public access
        Sdescription                 % Description of the object
        Lverbose=false               % Be verbose
        CoV                          % Termination criteria coefficient of variation (CoV) (0= no termination criteria adopted)
        timeout                      % Termination criteria Time in seconds  (0= no termination criteria adopted)
        Nsamples=1                   % Termination criteria Nsamples (0= no termination criteria adopted)
        confLevel=0                  % Set Confidence Interval (0= no termination criteria adopted) (NOT IMPLEMENTED)
        Nbatches=1                   % number of batches
        Lintermediateresults=true    % save SimulationData object after each batch
        XrandomStream                % field containing RandStream object
        SbatchFolder                 % Define the name of the folder used to
        % store intermediated results
    end
    
    properties (Hidden, SetAccess = protected)
        SbatchFileNames='SimulationData_batch_' % Define the name of the
        % intermediated results
        initialLaptime                % Store the initial laptime number of the simulation
        ibatch=0                      % Store the current number of batch
        isamples=0                    % Store the current number of samples
    end
    
    methods 
        simData = apply(obj, model);
    end
    
    methods (Abstract)        
        [Xpf, XsimOut]=computeFailureProbability(Xobj,Xtarget) % Compute the failure
        % probability associated to the
        % ProbabilisticModel/SystemReliability
        
        Xsamples=sample(Xobj,varargin) % Generate samples in the unit hypercube
                
        
    end % methods
    
    methods     
        function SbatchName = get.SbatchName(Xobj)
            SbatchName =  [Xobj.SbatchFileNames ...
                num2str(Xobj.ibatch) '_of_' num2str(Xobj.Nbatches)];
        end % Modulus get method
        
        exportResults(Xobj,varargin) % This method is used to export
        % the SimulationData
        
    end % methods
    
    % Define protected methods
    methods (Access=protected)
        
        [Xobj, Xinput]=checkInputs(Xobj,Xtarget) % Validate the input and initialize the random generator stream (if necessary)
        
        [exit, flag] = checkTermination(Xobj,Xresults) % Check the termination criteria 
        
        function restoreRandomStream(Xobj) % This method restore the OpenCossan random stream as a global stream
            %% Restore RandomStream
            
            
            if ~isempty(Xobj.XrandomStream) 
                RandStream.setGlobalStream(opencossan.OpenCossan.getRandomStream);
            end
        end
        
        
    end
    
end


