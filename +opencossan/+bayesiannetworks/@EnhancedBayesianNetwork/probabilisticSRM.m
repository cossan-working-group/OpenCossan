function NewNodesObj = probabilisticSRM(EBN, varargin)
% PROBABILISTICSRM method for the class enhancedBayesianNetwork
% The method allows to compute the probabilistic model in
% order to fill the CPTs of the new reduced BN
%
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

%% Process Input
p = inputParser;
p.FunctionName = 'opencossan.bayesiannetworks.EnhancedBayesianNetwork.probabilisticSRM';
p.addParameter('NodesNames',[]); 
p.addParameter('Lpar',false);
p.addParameter('useMarkovEnvelopes',false);
p.addParameter('Simulation',{});
p.parse(varargin{:});
% Assign input 
Nodes   = p.Results.NodesNames;               
Lpar    = p.Results.Lpar;
SimObj  = p.Results.Simulation;   
LMEnvelopes = p.Results.useMarkovEnvelopes;


%% Extract info from net
Lform=isempty(SimObj);

%% INIZIALISE VARIABLES
TopologicalOrder=EBN.TopologicalOrder;
NetNames        = EBN.NodesNames;
% Reorder input nodes in topological order
InputNodes                  = unique([Nodes,EBN.ParentNodes(ismember(EBN.NodesNames,intersect(Nodes,EBN.ProbabilisticNodes)))]); %nodes2compute+parents of probabilistic nodes in the envelope
[~,NodesIndTop,NodesIndex]  = intersect(NetNames(TopologicalOrder),InputNodes,'stable'); % Index of the nodes of the envelope in the net (topological order)
NodesIndNet                 = TopologicalOrder(NodesIndTop);  % topological index of nodes in net
SizeNodes                   = EBN.NodesSize(NodesIndNet);   % Sizes of the nodes of the envelope (topological order)
InputNodes                  = InputNodes(NodesIndex);    % Names of the ME nodes in topological order
[CSdiscrete, disInd]        = intersect(InputNodes,EBN.DiscreteNodes,'stable');    % Discrete nodes: contains new children!
SizeDiscrete                = SizeNodes(disInd); % Vector of sized of discrete nodes
Vsrm                        = SizeDiscrete;
% Initialize CPT of the envelope
if length(SizeDiscrete)>1
    CPTtotal    = cell(SizeDiscrete);  % only discrete nodes appears in the CPTtotal
else
    CPTtotal    = cell(1,SizeDiscrete);
end

% Build empty evaluator obj
Xev = opencossan.workers.Evaluator;

%% PREPARE ANALYSIS
% Identify nodes to compute
CnewNodesName = EBN.nodes2compute('DiscreteNodes',CSdiscrete,'InputNodes',InputNodes);
Node2compute  = EBN.Nodes(ismember(EBN.NodesNames,CnewNodesName));
[~,newChInd]  = intersect(CSdiscrete,CnewNodesName,'stable');       % New children (node2compute) index in CSdiscrete
newNoInd      = TopologicalOrder(NodesIndTop(disInd(newChInd)));    % Index of children in the overall network

% CANNOT EXPLOIT BOOLEAN PROPERTY IF USING MARKOV ENVELOPES
if ~LMEnvelopes && EBN.Nodes(newNoInd).Lboolean
    Lboolean        = true;
    Vsrm            = [SizeDiscrete(1,1:end-1),1];
    LcomputedOutcome= find(~cellfun(@isempty,EBN.CPDs{newNoInd}));
    if length(LcomputedOutcome)>1
        LcomputedOutcome=1;
    end
end

%% RELIABILITY ANALYSIS
% No need to initialize cossan anymore. TODO: TEST!
%SoriginalWorkingPath = opencossan.OpenCossan.getWorkingPath;
for iSRM=1:prod(Vsrm)
    XsimParfor = SimObj; % create a local simulator on each worker
%     try 
%         OpenCossan.cossanDisp('Checking COSSAN initialization...',4)
%         OpenCossan.setWorkingPath(SoriginalWorkingPath);
%     catch
%         disp('Initializing COSSAN on workers.')
%         OpenCossan('SworkingPath',SoriginalWorkingPath);
%     end
    
    % Preallocate Script cell to compute
    CSscript=cell(1,1+2*length(CnewNodesName));
    CSscript(1,1)={'TableOutput.out='};
    CSscript(1,end)={';'};
    CSscript(1,3:2:end-2)={','};
    
    % Combination of states of the discrete nodes of the MarkovEnvelope (discrete Grandpas included)
    combination = num2cell(opencossan.common.utilities.myind2sub(Vsrm,iSRM));     
    if Lboolean && (any(cellfun(@isempty,EBN.CPDs{newNoInd}(:))))
        combination{end} = find(~cellfun(@isempty,EBN.CPDs{newNoInd})); 
    elseif Lboolean && ~(any(cellfun(@isempty,EBN.CPDs{newNoInd}(:))))
        combination{end} = 1; 
    end
    
    % Prepare input
    Xinput= EBN.probabilisticInput('Combination',combination,...
        'CombinationNames',CSdiscrete,'Node',Node2compute);
    
    % Extract Script from nodes to compute 
    for inew=1:length(CnewNodesName) 
        [~,IndDisPA]   = find(ismember(CSdiscrete,intersect(InputNodes,Node2compute(inew).Parents,'stable')));  
        IndDisPA(IndDisPA==0)=[];
        [~,indexdiscreteparents]    = intersect(CSdiscrete,[EBN.Nodes(newNoInd(inew)).Parents,CnewNodesName(inew)],'stable');
        CPDSizeDiscreteparents      = SizeDiscrete(indexdiscreteparents);
        if length(CPDSizeDiscreteparents)==1 %nondiscrete parents
            CPDSizeDiscreteparents  = [1, CPDSizeDiscreteparents];
            CPD                     = reshape(EBN.Nodes(newNoInd(inew)).CPD,CPDSizeDiscreteparents);
            CSscript(1,2*inew)      = CPD(combination{newChInd(inew)});
        elseif all(CPDSizeDiscreteparents==1)
            CPD                     = reshape(EBN.Nodes(newNoInd(inew)).CPD,[CPDSizeDiscreteparents,EBN.Nodes(newNoInd(inew)).Size]);
            CSscript(1,2*inew)      = CPD(combination{[IndDisPA,newChInd(inew)]});
        else
            CPD                     = reshape(EBN.Nodes(newNoInd(inew)).CPD,CPDSizeDiscreteparents); % N.B. size probabilistic nodes always one!
            CSscript(1,2*inew)      = CPD(combination{[IndDisPA,newChInd(inew)]});
        end   
    end
    
      
    % Build Performance Function
    Xpf=opencossan.reliability.PerformanceFunction('Script',[CSscript{1,:}], ...
                'Format','table','OutputName','out',...
                'InputNames', cellstr(Xinput.Names),'IsFunction',false);
%     Xpf=PerformanceFunction('Sdescription', 'Performance function', ...
%                 'Sscript',[CSscript{1,:}],'Sformat','table', ...
%                 'Outputname','out','Cinputnames', Xinput.Cnames,'Lfunction',false);            
                
    % Build Probabilistic Model
    model = opencossan.common.Model('Input', Xinput, 'Evaluator', Xev);
    Xpm=opencossan.reliability.ProbabilisticModel('Model',model,...
        'performanceFunction',Xpf);
%     XprobModelBeamMatlab = opencossan.reliability.ProbabilisticModel(...
%     'Model', XmodelBeamMatlab, 'PerformanceFunction', Xperfun);
    
   %% COMPUTE FAILURE PROBABILITY
    if Lform 
        % Identify design point    
        Xdp             = Xpm.designPointIdentification;
        % Collect Result
        CPTtotal{iSRM}  = Xdp.form; 
    elseif isa(XsimParfor,'opencossan.simulations.MonteCarlo')
        if Lpar
            worker = getCurrentWorker;
            XsimParfor.SbatchFolder=['temp_folder_EBN' filesep 'task' num2str(worker.ProcessId)];
            disp(XsimParfor.SbatchFolder)
        end
    elseif isa(XsimParfor,'opencossan.simulations.LineSampling') && ~isempty(EBN.Nodes(newNoInd).MimportantDirection)
        [~,~,indInp ]=intersect([Xinput.CnamesRandomVariable,Xinput.CnamesIntervalVariable],...
                lower(setdiff(EBN.Nodes(newNoInd(inew)).Parents,EBN.DiscreteNodes,'stable')),'stable');
            VimportantDirInNode=EBN.Nodes(newNoInd(inew)).MimportantDirection(combination{newChInd(inew)},:);
            XsimParfor.Valpha=VimportantDirInNode(indInp);
    elseif isa(XsimParfor,'opencossan.simulations.AdaptiveLineSampling') && ~isempty(EBN.Nodes(newNoInd).MimportantDirection)
        [~,~,indInp ]=intersect([Xinput.CnamesRandomVariable,Xinput.CnamesIntervalVariable],...
                lower(setdiff(EBN.Nodes(newNoInd(inew)).Parents,EBN.DiscreteNodes,'stable')),'stable');
            VimportantDirInNode=EBN.Nodes(newNoInd(inew)).MimportantDirection(combination{newChInd(inew)},:);
            XsimParfor.Vdirection=VimportantDirInNode(indInp);        
    elseif isa(XsimParfor,'opencossan.simulations.AdaptiveLineSampling') && isempty(EBN.Nodes(newNoInd).MimportantDirection)
        Xlsfd=sensitivity.LocalSensitivityFiniteDifference('Xtarget',Xpm, 'Coutputnames',{'out'});
        Xgrad = Xlsfd.computeGradient;
        XsimParfor.VdirectionSNS= -Xgrad.Valpha;    
    end
    
    % Compute failure probability
    Xpf=Xpm.computeFailureProbability(XsimParfor); 
    % Collect Result
    CPTtotal{iSRM}=Xpf.pfhat;             
    
end

%% BUILD NEW NODES
if Lboolean && LcomputedOutcome==1
    CPTtotal(prod(Vsrm)+1:end)  = num2cell(1-cell2mat(CPTtotal(1:prod(Vsrm))));
elseif Lboolean && LcomputedOutcome==2
    CPTtotal(prod(Vsrm)+1:end)  = CPTtotal(1:prod(Vsrm));
    CPTtotal(1:prod(Vsrm))      = num2cell(1-cell2mat(CPTtotal(prod(Vsrm)+1:end)));
end
NewNodesObj = EBN.buildNewCrispNodes(CnewNodesName, CPTtotal, CSdiscrete, SizeDiscrete);

end

