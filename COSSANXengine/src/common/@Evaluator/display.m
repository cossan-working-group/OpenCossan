function display(Xobj)
%DISPLAY  Display the details of the Evaluator object
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

%% Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([' Evaluator Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',2);
%% Show the embedded object
if isempty(Xobj.CXsolvers)
    OpenCossan.cossanDisp(' The evaluator contains no solvers',1);
else
    OpenCossan.cossanDisp(' The evaluator contains: ',1);
    for n=1:length(Xobj.CXsolvers)
        OpenCossan.cossanDisp([sprintf('%2i: ',n) ' Solver ' Xobj.CSnames{n} ...
            ' (' Xobj.CXsolvers{n}.Sdescription ') ' ],1);
        OpenCossan.cossanDisp(['    * type ' class(Xobj.CXsolvers{n}) ],1)
        if isempty(Xobj.CSqueues{n})
            OpenCossan.cossanDisp(['    * evaluate on the localhost'],1)
        else
            if isempty(Xobj.CShostnames{n})
                OpenCossan.cossanDisp(['    * evaluate on the grid queue ' Xobj.CSqueues{n}],1)
            else
                OpenCossan.cossanDisp(['    * evaluate on the grid queue ' ...
                    Xobj.CSqueues{n} ' and hostname ' Xobj.CShostnames{n}],1)
            end
        end
    end
end







