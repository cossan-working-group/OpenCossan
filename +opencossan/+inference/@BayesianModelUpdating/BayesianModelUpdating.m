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
        
        Xmodel                  %The model to be updated
        Coutputnames            %The model outputs to be updated against
        XLog                    %The logLikelihood Cossan Object
        Nsamples=200            %The number of samples from the posterior to be generated
        Prior                   %The Prior Pdf to be updated, to either be taken from the model or 
                                %To be inputed in case if no model
                                %provided, is of type RandomVariableSet
        PlotGraphics = 0        %Option to plot the pdfs and samples
    end
    
    methods
        
        function obj = BayesianModelUpdating(varargin)
           
            p = inputParser;
            p.FunctionName = 'opencossan.inference.BayesianModelUpdating';
            
            p.addParameter('Xmodel',obj.Xmodel);
            p.addParameter('XLogLikelihood',obj.XLog);
            p.addParameter('Nsamples',obj.Nsamples);
            p.addParameter('Coutputnames',obj.Coutputnames);
            p.addParameter('Prior',obj.Prior);
            p.addParameter('PlotGraphics', obj.PlotGraphics);
            
            
            
            p.parse(varargin{:});
            
            obj.Xmodel = p.Results.Xmodel;
            obj.Coutputnames = p.Results.Coutputnames;
            obj.PlotGraphics = p.Results.PlotGraphics;
            obj.Nsamples = p.Results.Nsamples;
            
            if isempty(p.Results.XLogLikelihood)
                error('openCOSSAN:inference:BayesianModelUpdating',...
                        'A LogLikelihood object must be passed');
            else
                obj.XLog= p.Results.XLogLikelihood;
            end
            
            %If the model is empty, then a RvSet will be an expected input
            % for a prior. Otherwise this will be taken from the model
            if isempty(obj.Xmodel)
                if isempty(p.Results.Prior)
                    error('openCOSSAN:inference:BayesianModelUpdating',...
                        'Either a model or a Prior must be passed');
                end
                obj.Prior = p.Results.Prior;
                obj.Coutputnames = obj.Prior.Cmembers;
            else
                name = obj.Xmodel.Input.RandomVariableSetNames;
                obj.Prior = obj.Xmodel.Input.RandomVariableSets.(name{1});
            end
            
        end
       
        % This line should return simulation data?
       Xmodel = applyTMCMC(obj);
       
    end
    
end