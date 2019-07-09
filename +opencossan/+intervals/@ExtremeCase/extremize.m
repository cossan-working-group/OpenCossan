function  [CXresults, varargout]  = extremize(Xobj)
% EXTREMIZE This method is a common interface for different reliability based
%optimization approaches. 
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/extremize@ExtremeCase

global NiterationsEC NevaluationsEC  Lmaximize

if isempty(NiterationsEC)
    NiterationsEC=0;
end
if isempty(NevaluationsEC)
    NevaluationsEC=0;
end


% perform the optimization
if Xobj.LsearchByDoE 
    % optimize over specific points of the epistemic space
    if isempty(Xobj.Xdoe)
        warning('OpenCOSSAN:ExtremeCase:extremize',...
            'A Design of Experiment object was not passed to the constructor: a full factorial scheme will be adopted for the analysis')
        Xdoe = opencossan.simulations.DesignOfExperiments('SdesignType','FullFactorial',...
            'VlevelValues',ones(1,length(Xobj.XinputMapping.CnamesDesignVariable))*2,...
            'ClevelNames',Xobj.XinputMapping.CnamesDesignVariable);
    end
    Xsmp = Xdoe.sample('Xinput',Xobj.XinputMapping);
    CXresults{1}=apply(Xobj.Xmodel,Xsmp);
    
elseif Xobj.LsearchByLHS 
    % perform an euristic search in the epistemic space with Latin Hypercube Sampling
    Xlhs=opencossan.simulations.LatinHypercubeSampling('Nsamples',Xobj.NlhsSamples);
    Xsamples=Xlhs.sample('Xinput',Xobj.XinputMapping);
    CXresults{1}  = Xobj.Xmodel.apply(Xsamples);
    
elseif Xobj.LsearchByGA && Xobj.LminMax  % perform min/max optimization simultaneously
    % extract the optimization problem from the object
    XoptimizationProblem=Xobj.CXoptimizationProblem{1};
    CXresults{1} = Xobj.XgeneticAlgorithm.apply('XOptimizationProblem',XoptimizationProblem);
    
elseif Xobj.LsearchByGA
    CXresults=cell(1,2);
    % loop to perform both min and max optimization
    for n=1:2
        Lmaximize=~logical(n-2); % if n=2 change the flag to true
        XoptimizationProblem=Xobj.CXMinMaxOptProblems{n};
        CXresults{n} = Xobj.XgeneticAlgorithms.apply('XOptimizationProblem',XoptimizationProblem);
    end
end


varargout{1}=NiterationsEC;
% % Assign the outputs as requested
% Coutputs={MstatePointsEC,MfailurePointsEC,MatrixOfResults};
% for n=1:nargout-1
%     varargout{n}=Coutputs{n};
% end

clear('global','NiterationsEC','NevaluationsEC','Lmaximize')
return
