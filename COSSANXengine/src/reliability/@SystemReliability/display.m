function display(Xsys)
%DISPLAY  Displays the summary of the probabilistic model
%   DISPLAY(Xsys)
%
%   Example: DISPLAY(Xsystem) will output the summary of the Xsystem object
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/@SystemReliability
%
% Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
% Author: Edoardo-Patelli

%%  Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xsys) ' Object  -  Description: ' Xsys.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',3);

%% Display Xtree
if isempty(Xsys.XFaultTree)
    OpenCossan.cossanDisp(' * FaultTree object NOT defined',2);
else
    OpenCossan.cossanDisp(' * FaultTree object defined',2);
end

OpenCossan.cossanDisp([' * ' num2str(length(Xsys.Cnames)) ' basic events defined'])

for ipm=1:length(Xsys.Cnames)
    Sstring=sprintf(' ** #%i: %10s',ipm,Xsys.Cnames{ipm});
    
    if ~isempty(Xsys.XfailureProbability)
        Sstring=strcat(Sstring,sprintf(' | pfhat=%10.3e ',Xsys.XfailureProbability(ipm).pfhat));
    end
    
    if ~isempty(Xsys.XdesignPoints)
        Sstring=strcat(Sstring,sprintf(' | Reliablity index = %10.3e ',Xsys.XdesignPoints{ipm}.ReliabilityIndex));
    end
    
    OpenCossan.cossanDisp(Sstring,3)
end







