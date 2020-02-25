function makePlots(Xoutput,type)

Mall = Xoutput.getValues;
labeledFail = categorical(Mall(:,end)<0,[true false],{'Fail','Safe'});
xnames = Xoutput.Cnames(1:end-1);

switch lower(type)
    case 'mc'
        figure,
        gplotmatrix(Mall(:,1:end-1),[],labeledFail,'rb','o.',[],[],'grpbars',xnames)
        
    case 'ls'
        figure,
        gplotmatrix(Mall(:,1:end-1),[],labeledFail,'rb','o.',[],[],'grpbars',xnames)
        Xoutput.plotLines;
    case 'als'
        figure,
        gplotmatrix(Mx,[],labeledFail,'rb','o.',[],[],'grpbars',xnames)
end