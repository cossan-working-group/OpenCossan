function XSimOut = apply(Xobj,Pinput)
% APPLY  The method used the Input provided to evaluate the Evaluator
% object and returns an object of type SimulationData.
% The accepted input are:
% * Input object
% * Structure
% * Samples object
%
%  Usage:  XSimout = Xev.apply(Pinput)
%
% See Also: http://cossan.co.uk/wiki/index.php/Apply@Evaluator
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

%% Process Inputs
switch class(Pinput)
    case 'Input'
        if isempty(Pinput.Xsamples) % Use the default values (mean) of the RV if no sample are present in the Xinput
            Tinput=Pinput.get('defaultvalues');
        else
            Tinput=Pinput.getStructure;
        end
        assert(~isempty(Tinput),'openCOSSAN:common:Evaluator:apply',...
            'It is not possible to extract structure of samples from Input object. Input object migth be empty.');
    case 'Samples'
        Tinput=Pinput.Tsamples;
    case 'struct'
        Tinput=Pinput;
    otherwise
        error('openCOSSAN:evaluator:apply',...
            'The input of type %s is not supported',class(Pinput));
end



% Add input to the simulation data object
XSimInp=SimulationData('Tvalues',Tinput);

if isempty(Xobj.CXsolvers)
    XSimOut=XSimInp;
    % Add input samples to the Simulation output object
    XSimOut.Sdescription= 'created by the Evaluator';
    return
end

if Xobj.LverticalSplit
    XSimOut=executeWorkers(Xobj,XSimInp);
else
    
    
    %% Evaluator execution
    for n=1:length(Xobj.CXsolvers)
        OpenCossan.cossanDisp(['[Status:Evaluator  ]       * Processing solver ' ...
            num2str(n) '/' num2str(length(Xobj.CXsolvers))],3)
        
        % Setting the JobManager
        if ~isempty(Xobj.CSqueues{n})
            % Setting the JobManager
            Xjob=JobManager('XjobManagerInterface',Xobj.XjobInterface, ...
                'Squeue',Xobj.CSqueues{n},'Shostname',Xobj.CShostnames{n}, ...
                'SparallelEnvironment',Xobj.CSparallelEnvironments{n},...
                'Nslots',Xobj.Vslots(n),...
                'Nconcurrent',Xobj.Vconcurrent(n),...
                'Sduration',Xobj.Sduration,...
                'Sdescription','JobManager created by Evaluator.apply');
        end
        
        if exist('XSimOut','var')
            TinputSolver=Evaluator.addField2Structure(Xobj.CXsolvers{n},XSimOut,Tinput);
        else
            TinputSolver=Tinput;
        end
        
        switch class(Xobj.CXsolvers{n})
            case 'Connector'
                % The connector requires always a Structure
                if isempty(Xobj.CSqueues{n})
                    XSimOutTmp=Xobj.CXsolvers{n}.run(TinputSolver);
                else
                    Xc = Xobj.CXsolvers{n};
                    if Xc.Lremoteprepost
                        Xjob.Spreexecmd = Xc.SpreExecutionCommand;
                        Xc.SpreExecutionCommand = '';
                        Xjob.Spostexecmd = Xc.SpostExecutionCommand;
                        Xc.SpostExecutionCommand = '';
                    end
                    % Run connector
                    XSimOutTmp=Xc.runJob('Tinput',TinputSolver, ...
                        'Xjobmanager',Xjob,'LremoteInjectExtract',Xobj.LremoteInjectExtract);
                end
            case {'Mio'}
                % Prepare inputs
                if Xobj.CXsolvers{n}.Liostructure
                    PinputMio=TinputSolver;
                elseif Xobj.CXsolvers{n}.Liomatrix
                    PinputMio = zeros(length(Tinput),length(Xobj.CXsolvers{n}.Cinputnames));
                    if exist('XSimOut','var')
                        switch class(Pinput)
                            case 'Samples'
                                % Check variables present in the SimulationData object
                                CmioInputNames=Xobj.CXsolvers{n}.Cinputnames;
                                Vindout=ismember(CmioInputNames,XSimOut.Cnames);
                                % Extract quantity of interest
                                MoutOUT=XSimOut.getValues('Cnames',CmioInputNames(Vindout));
                                
                                % Process Inputs
                                % Extract Matrix
                                MoutIN  = Pinput.MsamplesPhysicalSpace;
                                Vindinput=ismember(CmioInputNames,Pinput.Cnames);
                                
                                % Reorder Matrix
                                PinputMio=[MoutIN(:,Vindinput) MoutOUT];
                            case 'Input'
                                % Check variables present in the SimulationData object
                                CmioInputNames=Xobj.CXsolvers{n}.Cinputnames;
                                Vindout=ismember(CmioInputNames,XSimOut.Cnames);
                                % Extract quantity of interest
                                MoutOUT=XSimOut.getValues('Cnames',CmioInputNames(Vindout));
                                
                                % Process Inputs
                                Vindinput=ismember(CmioInputNames,Pinput.Cnames);
                                MoutIN  = Pinput.getValues('Cnames',CmioInputNames(Vindinput));
                                
                                % Reorder Matrix
                                PinputMio(:,Vindout) = MoutOUT;
                                PinputMio(:,Vindinput)= MoutIN;
                            case 'struct'
                                % No conversion required
                                PinputMio=TinputSolver;
                        end
                    else
                        PinputMio=Pinput;
                    end
                else
                    %TODO: INPUT/OUTPUT separate matrix
                    PinputMio=TinputSolver;
                end
                
                if isempty(Xobj.CSqueues{n})
                    XSimOutTmp=Xobj.CXsolvers{n}.run(PinputMio);
                else
                    if isa(PinputMio,'Input')
                        XSimOutTmp=Xobj.CXsolvers{n}.runJob('Xinput',PinputMio, ...
                            'Xjobmanager',Xjob);
                    elseif isa(PinputMio,'Samples')
                        XSimOutTmp=Xobj.CXsolvers{n}.runJob('Xsamples',PinputMio, ...
                            'Xjobmanager',Xjob);
                    elseif isstruct(PinputMio)
                        XSimOutTmp=Xobj.CXsolvers{n}.runJob('Tinput',PinputMio, ...
                            'Xjobmanager',Xjob);
                    elseif isnumeric(PinputMio)
                        XSimOutTmp=Xobj.CXsolvers{n}.runJob('Minput',PinputMio, ...
                            'Xjobmanager',Xjob);
                    else
                        % You should never arrive here if the code is correct...
                        error('OpenCossan:Evaluator:applyErrorCode','You should never arrive here if the code is correct..');
                    end
                end
                
            case 'SolutionSequence'
                if ~isempty(Xobj.CSqueues{n})
                    % Add Job Manager to the SolutionSequence object
                    Xobj.CXsolvers{n}.XjobManager=Xjob;
                end
                XSimOutTmp=Xobj.CXsolvers{n}.apply(TinputSolver);
            otherwise
                % Create empty SimulationData object
                XSimOutTmp=SimulationData;
        end
        
        if n>1
            XSimOut=XSimOut.merge(XSimOutTmp);
        else
            XSimOut=XSimOutTmp;
        end
    end
    
    %% Export results
    % Merge simulation output object created with the apply of target object
    % and Simulation output containing the values of the input
    XSimOut=XSimInp.merge(XSimOut);
    
    % Add input samples to the Simulation output object
    XSimOut.Sdescription= [XSimOut.Sdescription ' - apply(@evaluator)'];
    
    
    
end


end



