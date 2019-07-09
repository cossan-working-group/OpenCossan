function disp(Xobj)
%DISPLAY  Displays the summary of an object of class FailureProbability
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@FailureProbability
%
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli
import opencossan.*
%% Output to Screen
for n=1:length(Xobj)
    
%  Name and description
opencossan.OpenCossan.cossanDisp('===================================================================',3);
opencossan.OpenCossan.cossanDisp([ class(Xobj(n)) ' Object  -  Description: ' Xobj.Sdescription],1);
opencossan.OpenCossan.cossanDisp('===================================================================',3);
% main paramenters
if Xobj(n).Nbatches==0
    opencossan.OpenCossan.cossanDisp('No values availables ',2);
else
    opencossan.OpenCossan.cossanDisp(['* Results obtained with ' Xobj(n).Smethod ' method' ],2);
    opencossan.OpenCossan.cossanDisp( '** First Moment',2);
    opencossan.OpenCossan.cossanDisp(['*** Pfhat     = ' sprintf('%9.3e',Xobj(n).pfhat)],2);
    opencossan.OpenCossan.cossanDisp(['*** Std       = ' sprintf('%9.3e',Xobj(n).stdPfhat)],2)
    opencossan.OpenCossan.cossanDisp(['*** CoV       = ' sprintf('%9.3e',Xobj(n).cov)],2);
    opencossan.OpenCossan.cossanDisp( '** Second Moment',2);
    opencossan.OpenCossan.cossanDisp(['*** variance  = ' sprintf('%9.3e',Xobj(n).variance)],2);
    opencossan.OpenCossan.cossanDisp( '** Simulation details',2);
    opencossan.OpenCossan.cossanDisp(['*** # samples  = ' sprintf('%9.3e',Xobj(n).Nsamples)],2);
    opencossan.OpenCossan.cossanDisp(['*** # batches  = ' sprintf('%9i',Xobj(n).Nbatches)],2);
    opencossan.OpenCossan.cossanDisp(['*** # lines    = ' sprintf('%9i',Xobj(n).Nlines)],2);
    opencossan.OpenCossan.cossanDisp(['*** Exit Flag = ' Xobj(n).SexitFlag],2);
end
end

