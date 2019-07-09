function disp(Xobj)
% Dysplay This method reports a summary of the FaultTree object on the
% Matlab console
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria

%%  Output to Screen
% Name and description
opencossan.OpenCossan.cossanDisp('===================================================================',3);
opencossan.OpenCossan.cossanDisp([' ' class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
opencossan.OpenCossan.cossanDisp('===================================================================',3);
% Main paramenters
opencossan.OpenCossan.cossanDisp(['The FaultTree contains ' num2str(length(Xobj.VnodeConnections)) ' nodes'])

for inode=1:length(Xobj.VnodeConnections)
    opencossan.OpenCossan.cossanDisp(['Node #' num2str(inode) ' (' Xobj.CnodeNames{inode} ') Node Type: ' Xobj.CnodeTypes{inode} ' Connection: ' num2str(Xobj.VnodeConnections(inode)) ])
end
% Show cut-set
opencossan.OpenCossan.cossanDisp('-------------------------------------------------------------------');
if isempty(Xobj.McutSets)
    opencossan.OpenCossan.cossanDisp('Cut-Set of the Fault Tree not identified')
else
    opencossan.OpenCossan.cossanDisp([num2str(size(Xobj.McutSets,2)) ' cut-sets identified']);
    if isempty(Xobj.CminimalCutSets)
       opencossan.OpenCossan.cossanDisp('Minimal Cut-Sets not identified')
    else
        for imcs=1:length(Xobj.CminimalCutSets)
            opencossan.OpenCossan.cossanDisp(['Minimal Cut-Set #' num2str(imcs) ': ']);
            opencossan.OpenCossan.cossanDisp(Xobj.CminimalCutSets{imcs});
        end
    end
end
opencossan.OpenCossan.cossanDisp('-------------------------------------------------------------------');
