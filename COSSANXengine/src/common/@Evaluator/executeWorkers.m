function XSimOut = executeWorkers(Xobj,XSimInp)
% EXECUTEWORKERS  This is a protected method of evaluator to run the
% analysis in verticla chunks.
%
% It requires a structure of Simulation Data object
%
%  Usage:  XSimout = executeWorkers(Xobj,XSimInp)
%
% See Also: http://cossan.co.uk/wiki/index.php/executeWorkers@Evaluator
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



%% The analysis is split over the number of samples

Nsamples=XSimInp.Nsamples;

% Setting the JobManager
if ~isempty(Xobj.CSqueues{1})
    % Setting the JobManager
    Xjob=JobManager('XjobManagerInterface',Xobj.XjobInterface, ...
        'Squeue',Xobj.CSqueues{1},'Shostname',Xobj.CShostnames{1}, ...
        'SparallelEnvironment',Xobj.CSparallelEnvironments{1},...
        'Nslots',Xobj.Vslots(1),...
        'Nconcurrent',Xobj.Vconcurrent(1),...
        'Sdescription','JobManager created by Evaluator.executeWorkers');
end

for ns=1:Nsamples
    
    % process each sample
    Tinput=XSimInp.Tvalues(ns);
    
    % Predefine and reset SimulationData
    XSimOutInner=[];
    
    %% Evaluator execution
    for n=1:length(Xobj.CXsolvers)
        OpenCossan.cossanDisp(['[Status:Evaluator  ]  * Processing solver ' ...
            num2str(n) '/' num2str(length(Xobj.CXsolvers))],3)
        if ~isempty(XSimOutInner)
            TinputSolver=Evaluator.addField2Structure(Xobj.CXsolvers{n},XSimOutInner,Tinput);
        else
            TinputSolver=Tinput;
        end
        
        switch class(Xobj.CXsolvers{n})
            case 'Connector'
                % The connector requires always a Structure
                XSimOutTmp=Xobj.CXsolvers{n}.run(TinputSolver);
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
                % evaluate Mio object
                XSimOutTmp=Xobj.CXsolvers{n}.run(PinputMio);
            case 'SolutionSequence'
                XSimOutTmp=Xobj.CXsolvers{n}.apply(TinputSolver);
            otherwise
                % Create empty SimulationData object
                XSimOutTmp=SimulationData;
        end
        
            if n>1
                XSimOutInner=XSimOutInner.merge(XSimOutTmp);
            else
                XSimOutInner=XSimOutTmp;
            end
    end
    
    % Merge simulation 
    if ns>1
        XSimOut=XSimOut.merge(XSimOutInner);
    else
        XSimOut=XSimOutInner;
    end
    
end

%% Export results
% Merge simulation output object created with the apply of target object
% and Simulation output containing the values of the input
XSimOut=XSimInp.merge(XSimOut);

% Add input samples to the Simulation output object
XSimOut.Sdescription= [XSimOut.Sdescription ' - (executeWorkers@evaluator)'];

end



