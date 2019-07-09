function  [CXresults, varargout]  = extremize(Xobj)
%EXTREMIZE This method is a common interface for different reliability based
%optimization approaches using p-boxes.
%
% See also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/extremize@UncertaintyPropagation

global NiterationsUP Lmaximize

CSsuperclassSolver=superclasses(Xobj.Xsolver);

% perform the optimization
switch CSsuperclassSolver{1}
    case 'Optimizer'
        CXresults=cell(1,2);
        % loop to perform both min and max optimization
        for n=1:2
            Lmaximize=~logical(n-2); % if n=2 change the flag to true
            XoptimizationProblem=Xobj.CXMinMaxOptProblems{n};
            XoptimizationProblem.VinitialSolution=Xobj.VinitialSolution;
            CXresults{n} = Xobj.Xsolver.apply('XOptimizationProblem',XoptimizationProblem);
        end
    case 'Simulations'
        Lmaximize=false;
        Xsamples=Xobj.Xsolver.sample('Xinput',Xobj.XinputMapping);
        CXresults{1}  = Xobj.Xmodel.apply(Xsamples);
    case 'Sensitivity'
% %         Xobj.XprobabilisticModel.Xmodel.Xinput=Xobj.XinputMapping;
%         Xlsfd = Xobj.Xsolver;
%         Xlsfd=Xlsfd.addModel(Xobj.Xmodel);
%         Xgradient = Xlsfd.computeGradient;      
end

varargout{1}=NiterationsUP;

clear('global','NiterationsUP','NevaluationsUP','Lmaximize')
end
