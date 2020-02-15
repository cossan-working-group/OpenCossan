function simData = apply(Xobj,Pinput)
    % APPLY  The method used the Input provided to evaluate the Evaluator object and returns an
    % object of type SimulationData. The accepted input are:
    % * Table object
    % * Input object
    % * Structure
    % * Samples object
    %
    %  Usage:  XSimout = Xev.apply(Pinput)
    %
    % See Also: http://cossan.co.uk/wiki/index.php/Apply@Evaluator
    %
    %
    % Author: Edoardo Patelli Institute for Risk and Uncertainty, University of Liverpool, UK email
    % address: openengine@cossan.co.uk Website: http://www.cossan.co.uk
    
    % ===================================================================== This file is part of
    % openCOSSAN.  The open general purpose matlab toolbox for numerical analysis, risk and
    % uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify it under the terms of the
    % GNU General Public License as published by the Free Software Foundation, either version 3 of
    % the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    % without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
    % the GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License along with openCOSSAN.  If
    %  not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    import opencossan.common.outputs.SimulationData
    import opencossan.highperformancecomputing.*
    
    %% Process Inputs
    switch class(Pinput)
        case 'opencossan.common.inputs.Input'
            if isempty(Pinput.Samples)
                % Use the default values (i.e. mean) of the Random Variables if no samples are
                % present in the Input object
                TableInput=Pinput.getDefaultValues();
            else
                TableInput=Pinput.getTable;
            end
        case 'struct'
            TableInput = struct2table(Pinput);
        case 'table'
            % This should be the default way to pass the realizations to the Evaluator object
            TableInput=Pinput;
        otherwise
            error('openCOSSAN:evaluator:apply:wrongInputType',...
                'The input of type %s is not supported',class(Pinput));
    end
    
    if isempty(Xobj.CXsolvers)
        simData = SimulationData('Description', 'Created by Evaluator with no workers.', ...
            'samples', TableInput);
        return
    end
    
    if Xobj.LverticalSplit
        % Setting the JobManager
        if ~isempty(Xobj.CSqueues{1})
            % Setting the JobManager
            Xjob=JobManager('XjobManagerInterface',Xobj.XjobInterface, ...
                'Squeue',Xobj.CSqueues{1},'Shostname',Xobj.CShostnames{1}, ...
                'SparallelEnvironment',Xobj.CSparallelEnvironments{1},...
                'Nslots',Xobj.Vslots(1),...
                'Nconcurrent',Xobj.Vconcurrent(1),...
                'Sdescription','JobManager created by Evaluator.executeWorkers');
            
            % TODO: Not implemented
            TableOutput=executeWorkersGrid(Xobj,XSimInp,Xjob);
        else
            TableOutput=executeWorkersVertical(Xobj,TableInput);
        end
    else
        
        % Setting the JobManager
        if ~isempty(Xobj.CSqueues{1})
            % Setting the JobManager
            Xjob=JobManager('XjobManagerInterface',Xobj.XjobInterface, ...
                'Squeue',Xobj.CSqueues{1},'Shostname',Xobj.CShostnames{1}, ...
                'SparallelEnvironment',Xobj.CSparallelEnvironments{1},...
                'Nslots',Xobj.Vslots(1),...
                'Nconcurrent',Xobj.Vconcurrent(1),...
                'Sdescription','JobManager created by Evaluator.executeWorkers');
            
            % TODO: Not implemented
            TableOutput=executeWorkersGrid(Xobj,XSimInp,Xjob);
        else
            TableOutput=executeWorkersHorizontal(Xobj,TableInput);
        end
    end
    % Export data
    simData = SimulationData('Samples',[TableInput, TableOutput]);
end