function display(Xobj)
%DISPLAY  Displays the summary of an object of class FailureProbability
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@FailureProbability
%
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli

%% Output to Screen
for n=1:length(Xobj)
    
%  Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xobj(n)) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',3);
% main paramenters
if Xobj(n).Nbatches==0
    OpenCossan.cossanDisp('No values availables ',2);
else
    OpenCossan.cossanDisp(['* Results obtained with ' Xobj(n).Smethod ' method' ],2);
    OpenCossan.cossanDisp( '** First Moment',2);
    OpenCossan.cossanDisp(['*** Pfhat     = ' sprintf('%9.3e',Xobj(n).pfhat) ...
                    sprintf(' (Beta: %6.3f)',Xobj(n).reliabilityIndex)],2);
    OpenCossan.cossanDisp(['*** Std       = ' sprintf('%9.3e',Xobj(n).stdPfhat)],2)
    OpenCossan.cossanDisp(['*** CoV       = ' sprintf('%9.3e',Xobj(n).cov)],2);
    OpenCossan.cossanDisp( '** Second Moment',2);
    OpenCossan.cossanDisp(['*** variance  = ' sprintf('%9.3e',Xobj(n).variance)],2);
    OpenCossan.cossanDisp( '** Simulation details',2);
    OpenCossan.cossanDisp(['*** # samples  = ' sprintf('%9.3e',Xobj(n).Nsamples)],2);
    OpenCossan.cossanDisp(['*** # batches  = ' sprintf('%9i',Xobj(n).Nbatches)],2);
    OpenCossan.cossanDisp(['*** # lines    = ' sprintf('%9i',Xobj(n).Nlines)],2);
    OpenCossan.cossanDisp(['*** Exit Flag = ' Xobj(n).SexitFlag],2);
end
end

