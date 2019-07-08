function  CXresults = extremize(Xobj)
% EXTREMIZE This method is a common interface for different reliability based
%optimization approaches.
%
% See also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/extremize@IntervalAnalysis


CSsolverSuperclass=superclasses(Xobj.Xsolver);

% perform the optimization
switch CSsolverSuperclass{1}
    case 'Optimizer'
    %     if Xobj.LminMax % so far this option can be available for GA only
    %         XoptimizationProblem=Xobj.CXoptimizationProblem{1};
    %         XoptimizationProblem.VinitialSolution=Xobj.VinitialSolution;
    %         CXresults{1} = Xobj.Xsolver.apply('XOptimizationProblem',XoptimizationProblem);
    %     else
%     if isa(Xobj.Xsolver,'GeneticAlgorithms')
%         % optimization will be performed with GA
%     else
%         % optimization will be performed with any other methods
%     end
    CXresults=cell(1,2);
    % loop to perform both min and max optimization
    for n=1:2
        XoptimizationProblem=Xobj.CXMinMaxOptProblems{n};
        XoptimizationProblem.VinitialSolution=Xobj.VinitialSolution;
        CXresults{n} = Xobj.Xsolver.apply('XOptimizationProblem',XoptimizationProblem);
    end
        
    case 'Simulations'
    
    Xsamples=Xobj.Xsolver.sample('Xinput',Xobj.XinputEquivalent);
    CXresults{1}  = Xobj.Xmodel.apply(Xsamples);
end

return
