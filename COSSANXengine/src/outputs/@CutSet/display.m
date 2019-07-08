function display(Xobj)
%DISPLAY  Displays the object CutSet
%
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/@CutSet
%
% Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
% Author: Edoardo-Patelli

%%  Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',3);

% Main paramenters
if isempty(Xobj.XFaultTree)
    OpenCossan.cossanDisp(' * FaultTree: not defined',1)
end

% Main paramenters
if isempty(Xobj.XDesignPoint)
    OpenCossan.cossanDisp(' * DesignPoint: not defined',1)
else
    OpenCossan.cossanDisp([' * DesignPoint: Reliability index '  ,...
        sprintf('%10.3e (beta)',Xobj.XDesignPoint.ReliabilityIndex)  ],1)
end


% Main paramenters
if isempty(Xobj.XFailureProbability)
    OpenCossan.cossanDisp(' * FailureProability : not defined',1)
else
    OpenCossan.cossanDisp([' * FailureProability : ' ...
        sprintf('%10.3e (pfhat)',Xobj.failureProbability) ],1) 
end

%% Show the bounds
if ~isempty(Xobj.lowerBound)
    OpenCossan.cossanDisp([' * Lower bound: ' sprintf('%8.3e',Xobj.lowerBound) ],1)
end

if ~isempty(Xobj.upperBound)
    OpenCossan.cossanDisp([' * Upper bound: ' sprintf('%8.3e', Xobj.upperBound) ],1)
end

%% Show the failure probability of the cutset
OpenCossan.cossanDisp([' * Failure Probability : ' sprintf('%8.3e',Xobj.failureProbability) ],1)
if ~isempty(Xobj.kappa)
    OpenCossan.cossanDisp([' * Kappa value : ' sprintf('%8.3e',Xobj.kappa) ],1)
end
