function display(Xobj)
% Dysplay This method reports a summary of the FaultTree object on the
% Matlab console
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria

%%  Output to Screen
% Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([' ' class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',3);
% Main paramenters
OpenCossan.cossanDisp(['The FaultTree contains ' num2str(length(Xobj.VnodeConnections)) ' nodes'])

for inode=1:length(Xobj.VnodeConnections)
    OpenCossan.cossanDisp(['Node #' num2str(inode) ' (' Xobj.CnodeNames{inode} ') Node Type: ' Xobj.CnodeTypes{inode} ' Connection: ' num2str(Xobj.VnodeConnections(inode)) ])
end
% Show cut-set
OpenCossan.cossanDisp('-------------------------------------------------------------------');
if isempty(Xobj.McutSets)
    OpenCossan.cossanDisp('Cut-Set of the Fault Tree not identified')
else
    OpenCossan.cossanDisp([num2str(size(Xobj.McutSets,2)) ' cut-sets identified']);
    if isempty(Xobj.CminimalCutSets)
       OpenCossan.cossanDisp('Minimal Cut-Sets not identified')
    else
        for imcs=1:length(Xobj.CminimalCutSets)
            OpenCossan.cossanDisp(['Minimal Cut-Set #' num2str(imcs) ': ']);
            OpenCossan.cossanDisp(Xobj.CminimalCutSets{imcs});
        end
    end
end
OpenCossan.cossanDisp('-------------------------------------------------------------------');
