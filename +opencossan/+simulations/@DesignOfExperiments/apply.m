function XsimOut = apply(Xobj,Xtarget)
%APPLY method. This method applies DESIGNOFEXPERIMENTS simulation to the object
%passed as the argument
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

%% Check inputs
[Xobj, Xinput]=checkInputs(Xobj,Xtarget);

%%  Initialize variables
Xobj.isamples = 0;
Xobj.ibatch   = 0;
SexitFlag     = [];

assert(isa(Xinput,'opencossan.common.inputs.Input'),'openCOSSAN:DesignOfExperiments:apply',...
        ['A opencossan.common.inputs.Input object is required to perform a DesignOfExperiments analysis!!!!',...
        '\n Provided object of class %s'],class(Xinput))

%% DesignOfExperiments simulation

while isempty(SexitFlag)
    
    Xobj.ibatch = Xobj.ibatch + 1;
    
    % Lap time for each batch
    OpenCossan.setLaptime('description',[' Batch #' num2str(Xobj.ibatch)]);
    
    % Number of samples current batch    
    if Xobj.ibatch==Xobj.Nbatches || Xobj.Nsimxbatch==0
        Ns=Xobj.Nlastbatch;
    else
        Ns=Xobj.Nsimxbatch;
    end
    
    % update counter for Nsamples
    Xobj.isamples = Xobj.isamples + Ns;
    
    % Generate samples
    Xs = Xobj.sample('Xinput',Xinput);
        
    Xinput=set(Xinput,'Xsamples',Xs);
    
    OpenCossan.cossanDisp(['Design of Experiments simulation Batch ' num2str(Xobj.ibatch) ...
            ' ( ' num2str(Ns) ' samples)' ],4)
    
    %% evaluate Xtarget model 
    Xout = apply(Xtarget,Xinput);
        
    %% Export results
    
    if ~Xobj.Lintermediateresults
        XsimOut(Xobj.ibatch)=Xout;  %#ok<AGROW>
    else
        exportResults(Xobj,'Xsimulationoutput',Xout);
        % Keep in memory only the SimulationData of the last batch
        XsimOut=Xout; 
    end
        
    % check termination criteria
    SexitFlag=checkTermination(Xobj,XsimOut);
end

% Add termination criteria to the FailureProbability
XsimOut(end).SexitFlag=SexitFlag;
XsimOut(end).SbatchFolder=[OpenCossan.getCossanWorkingPath filesep Xobj.SbatchFolder];

OpenCossan.setLaptime('description','End apply@DesignOfExperiments');
