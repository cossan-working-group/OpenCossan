function makePlots(Xoutput,type)

switch lower(type)
    case 'mc'
        Mall = Xoutput.getValues;
        labeledFail = categorical(Mall(:,end)<0,[true false],{'Fail','Safe'});
        xnames = Xoutput.Cnames(1:end-1);
        figure,
        gplotmatrix(Mall(:,1:end-1),[],labeledFail,'rb','o.',[],[],'grpbars',xnames)

case 'ls'
        Nvs = length(Xoutput.Cnames);
        Mall = struct2array(Xoutput.Tvalues);
        Mall = reshape(Mall,Nvs,Xoutput.Nsamples)';
        Mx = Mall(:,1:end-3);
        Vg = [Xoutput.Tvalues.Vg];
        labeledFail = categorical(Vg<0,[true false],{'Fail','Safe'});
        xnames = Xrvs.Cmembers;
        color = lines(size(Mx,2));
        figure,
        gplotmatrix(Mx,[],labeledFail,'rb','o.',[],[],'grpbars',xnames)
        Xoutput.plotLines
    case 'als'
            SperfName = Xpm.XperformanceFunction.Soutputname;
            XlineData = LineData('Sdescription','My first Line Data object',...
                'Xals',Xsimulator,'LdeleteResults',false,...
                'Sperformancefunctionname',SperfName,...
                'Xinput',Xin);
            if length(Xrvs.Cmembers)==2
                XlineData.plotLimitState('XsimulationData',Xoutput,'Xmodel',Xpm);
            end
            XlineData.plotLines
            Nvs = length(Xoutput.Cnames);
            Mall = struct2array(Xoutput.Tvalues);
            Mall = reshape(Mall,Nvs,Xoutput.Nsamples)';
            Mx = Mall(:,1:end-3);
            Vg = [Xoutput.Tvalues.Vg];
            labeledFail = categorical(Vg<0,[true false],{'Fail','Safe'});
            xnames = Xrvs.Cmembers;
            color = lines(size(Mx,2));
            figure,
            gplotmatrix(Mx,[],labeledFail,'rb','o.',[],[],'grpbars',xnames)
end