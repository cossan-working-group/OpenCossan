classdef BayesianModelUpdating
    
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
    
    %Development notes: We will be updating all of the randomVariables
    %that are passed via the Xmodel or by the Prior set. There is no
    %impementation of a method for the mixed epistemic and aleatoric
    %uncertrainties. Here we only treat epistemic uncertainty, all Random
    %Variables are to be reduced so there is no need to spectify a
    %'Cinputnames' property
    
    %Manditory inputs: Xmodel or Prior
    %                  LogLikelihood
    
    
    properties
        
        Model(1,1)  opencossan.common.Model           %The model to be updated
        OutputNames  (1,:) string         %The model outputs to be updated against
        LogLikelihood(1,1) opencossan.inference.LogLikelihood                    %The logLikelihood Cossan Object
        Nsamples(1,1) {mustBeInteger}=200         %The number of samples from the posterior to be generated
        Prior(1,1)  opencossan.common.inputs.random.RandomVariableSet                 %The Prior Pdf to be updated, to either be taken from the model or 
                                %To be inputed in case if no model
                                %provided, is of type RandomVariableSet        
    end
    
    methods
        
        function obj = BayesianModelUpdating(varargin)
           
            p = inputParser;
            p.FunctionName = 'opencossan.inference.BayesianModelUpdating';
            
            %p.addParameter('model',obj.model);
            p.addParameter('LogLikelihood',[]);
            p.addParameter('Nsamples',obj.Nsamples);
            p.addParameter('OutputNames',[]);
            p.addParameter('Prior',[]);
            
            
            
            p.parse(varargin{:});
            
            %obj.Model = p.Results.Model;
            obj.OutputNames = p.Results.OutputNames;
            obj.Nsamples = p.Results.Nsamples;
            
            if isempty(p.Results.LogLikelihood)
                error('openCOSSAN:inference:BayesianModelUpdating',...
                        'A LogLikelihood object must be passed');
            else
                obj.LogLikelihood= p.Results.LogLikelihood;
            end
            
            obj.Model = obj.LogLikelihood.Model;
            % If the Prior is empty, the prior will be taken from the
            % RvSet of the model.
            if ~isempty(p.Results.Prior)
                obj.Prior = p.Results.Prior;
                obj.OutputNames = obj.Prior.Names;
            else
                name = obj.Model.Input.RandomVariableSetNames;
                obj.Prior = obj.Model.Input.RandomVariableSets.(name{1});
                obj.OutputNames = obj.Prior.Names;
            end
            
        end
       
        % This line should return simulation data?
       posterior = applyTMCMC(obj);
       posterior = applyTMCMC2(obj);
       plotTransitionalSamples(obj,posterior, names, indicies);
       
    end
    
end