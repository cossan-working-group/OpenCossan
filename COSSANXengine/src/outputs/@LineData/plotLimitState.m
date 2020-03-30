function varargout=plotLimitState(Xobj,varargin)
%PLOTLINES plots the value of the performance function on the lines
%

Stitle1='Physical State Space';
Stitle2='Standard Normal Space';
SxLabel='variable #1';
SyLabel='variable #2';
Smarker='o';
Svisible='on';
lineWidth=1;
Ltext=false;
Npoints=100;
Vsupport=[-6,6];
Vset=0:5;
LmakeLines=false;
Llegend=true;
%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'sfigurename'
            Sfigurename=varargin{k+1};
        case 'stitle'
            Stitle=varargin{k+1};
        case 'linewidth'
            lineWidth=varargin{k+1};
        case 'smarker'
            Smarker=varargin{k+1};
        case 'xsimulationdata'
            XsimulationData=varargin{k+1};
        case 'llegend'
            Llegend=varargin{k+1};
        case 'npoints'
            Npoints=varargin{k+1};
        case 'vsupport'
            Vsupport=varargin{k+1};
        case 'vset'
            Vset=varargin{k+1};
        case 'xmodel'
            Xmodel=varargin{k+1};
        case 'lmakelines'
            LmakeLines=varargin{k+1};
        case 'nlines'
            Nlines=varargin{k+1};
        case 'cdisplaynames'
            CdisplayNames=varargin{k+1};
        otherwise
            error('openCOSSAN:LineSamplingData:plotLines',...
                ['Field name (' varargin{k} ') not allowed']);
    end
end

if exist('CdisplayNames','var')
    SxLabel=CdisplayNames{1};
    SyLabel=CdisplayNames{2};
end

%% Check the LineSamplingData object

% if ~isa(Xobj.Xsimulator,'AdvancedLineSampling')
%     Vset=Xobj.Tlines.Line_1.VlineDistances;
%     Valpha=Xobj.Tlines.Line_1.Valpha;
%     LmakeLines=true;
%     Valpha_start=Valpha;
% else
%     Valpha_start=Xobj.VinitialDirection;
%     Valpha_last=Xobj.VimportantDirection;
%     Valpha=Valpha_last;
% end

MidSNS=Xobj.MimportantDirectionSNS;
MidPHY=Xobj.MimportantDirectionPHY;

MlspSNS=Xobj.MlimitStateCoordsSNS;
MlspPHY=Xobj.MlimitStateCoordsPHY;

% %% Retrieve info from the Line Sampling Data object
% MstatePoints=Xobj.Xinput.map2stdnorm(cell2mat(Xobj.CMstatePoints));
% MstatePoints=MstatePoints(~isnan(MstatePoints(:,1)),:);
% MstatePointsPhysical=cell2mat(Xobj.CMstatePoints);
% MstatePointsPhysical=MstatePointsPhysical(~isnan(MstatePointsPhysical(:,1)),:);

% get hyperplane points
%     MorthPlanePoints=MstatePoints'-MstatePoints'*Valpha(:)*Valpha(:)';
MhyperPlanePoints=Xobj.MhyperplaneCoords;

if size(MhyperPlanePoints,2)>2
    error('openCOSSAN:outputs:LineSamplingData:plotLimitState',...
        'You cannot plot a limit state with more than 3 uncertain variables!')
end

% count number of lines
if ~exist('Nlines','var')
    Nlines=size(MhyperPlanePoints,1);
end

Valpha_start=transpose(MidSNS(1,:))/norm(MidSNS(1,:));
Valpha_last=transpose(MidSNS(end,:))/norm(MidSNS(end,:));

% overimpose lines on the graphs
if LmakeLines
    CMpointOnLinesSNS=cell(1,Nlines);
    CMpointOnLinesPHY=cell(1,Nlines);
    VrandomOrder=randperm(size(MhyperPlanePoints,1));
    for i=1:Nlines
        iLine=VrandomOrder(i);
        CMpointOnLinesSNS{i}=repmat(MhyperPlanePoints(iLine,:),length(Vset),1)+...
            bsxfun(@times,Vset,Valpha)'; 
        CMpointOnLinesPHY{i}=Xobj.Xinput.map2physical(CMpointOnLinesSNS{i});
    end
end
%% Start the plot

fh=figure;
varargout{1}=fh;

% Make a grid for the isodensity curves and the limit state surface
xx=linspace(Vsupport(1),Vsupport(2),Npoints);
[X,Y]=meshgrid(xx);
Mdata=[X(:),Y(:)];

% Evaluate limit state surface using the model
if exist('Xmodel','var')
    Xsample_grid=Samples('Xinput',Xobj.Xinput,...
        'MsamplesStandardNormalSpace',Mdata);
    XsimOut=apply(Xmodel,Xsample_grid);
    SoutputName=Xmodel.XperformanceFunction.Soutputname;
    Vmodel_output=XsimOut.getValues('Sname',SoutputName);
    Z=reshape(Vmodel_output,Npoints,Npoints);
end

Cnames=Xobj.Xinput.CnamesRandomVariable;
CnamesRVS=Xobj.Xinput.CnamesRandomVariableSet;
Xrvs=Xobj.Xinput.Xrvset.(CnamesRVS{1});

% samples in physical space
Mphy=map2physical(Xrvs,Mdata);
Xphy=reshape(Mphy(:,1),Npoints,Npoints);
Yphy=reshape(Mphy(:,2),Npoints,Npoints);

% density function in standard space
pdfSNS= Xrvs.evalpdf('MsamplesStandardNormalSpace',Mdata);
ZpdfSNS=reshape(pdfSNS,Npoints,Npoints);

% density function in original space
pdfPHY= Xrvs.evalpdf('MsamplesPhysicalSpace',Mphy);
ZpdfPHY=reshape(pdfPHY,Npoints,Npoints);

% extract evaluation points
CMxLines=cell(1,Nlines);
CMsLines=cell(1,Nlines);

MX(1,:)=transpose(XsimulationData.getValues('Sname',Cnames{1}));
MX(2,:)=transpose(XsimulationData.getValues('Sname',Cnames{2}));
istart=1;
for iLine=1:Nlines-1
    iend=istart+Xobj.VNlineEvaluations(iLine)-1;
    Mx=MX(:,istart:iend);
    Ms=Xobj.Xinput.map2stdnorm(Mx);
    CMxLines{iLine}=Mx;
    CMsLines{iLine}=Ms;
    istart=iend+1;
end
MS=Xobj.Xinput.map2stdnorm(MX);
% % extract evaluation points on the remaining lines
% XsimL=Xobj.Tlines.Line_1.XSimulationData;
% Cnames=XsimL.Cnames;
% Vset=Xobj.Tlines.Line_1.VlineDistances;
% for i=1:Nlines-1
%     MxL=[];
%     for j=1:length(Vset)
%         MxL(1,j)=getfield(XsimL.Tvalues(j+length(Vset)*(i-1)),Cnames{1});
%         MxL(2,j)=getfield(XsimL.Tvalues(j+length(Vset)*(i-1)),Cnames{2});
%     end
%     MsL=Xobj.Xinput.map2stdnorm(MxL);
%     CMxLines{i+1}=MxL;
%     CMsLines{i+1}=MsL;
% end

% MX=cell2mat(CMxLines);
% MS=cell2mat(CMsLines);


subplot(121) %physical space
if exist('Xmodel','var')
    % Plot the limit state surface if a model is defined
    [~,hplotPHY]=contour(Xphy,Yphy,Z,[0,0]);
    set(hplotPHY,'linewidth',2,'color','black')
end
hold on
% plot 5 isodensity curves
[~,hisoprob2]=contour(Xphy,Yphy,ZpdfPHY,5);
set(hisoprob2,'linewidth',1,'linecolor','blue')
% place a dot in the mean state
hs1=scatter(Xrvs.Xrv{1}.mean,...
    Xrvs.Xrv{2}.mean);
set(hs1,'marker','o','markerfacecolor','green','markeredgecolor','blue')
hold on
% plot evaluation points
hs3=scatter(MX(1,:),MX(2,:));
set(hs3,'marker','o','markerfacecolor',[0.9,0.9,0.9],'markeredgecolor','blue')
% plot lines
VstartDirPhy=Xobj.Xinput.map2physical(Valpha_start'*max(Vsupport));
hstartDir=line([Xrvs.Xrv{1}.mean,VstartDirPhy(1)],...
    [Xrvs.Xrv{2}.mean,VstartDirPhy(2)]);
% Mline0=CMxLines{1};
% hstartDir=line(Mline0(1,:),Mline0(2,:));
set(hstartDir,'color','red','linewidth',2,'linestyle','--');
for iLine=1:Nlines-1
    Mlines=CMxLines{iLine};
    hl=line(Mlines(1,:)',Mlines(2,:)');
    set(hl,'color',[rand,rand,rand]);
end

% TODO: replace mean with median, use general names like CSnames
if isa(Xobj.Xals,'AdaptiveLineSampling')
    % plot last direction
    VlastDirPhy=Xobj.Xinput.map2physical(Valpha_last'*max(Vsupport));
    hlastDir=line([Xrvs.Xrv{1}.mean,VlastDirPhy(1)],...
        [Xrvs.Xrv{2}.mean,VlastDirPhy(2)]);
    set(hlastDir,'color','green','linewidth',2,'linestyle','-.');
end
% plot the limit state points
    hs2=scatter(MlspPHY(:,1),MlspPHY(:,2));
    set(hs2,'marker','square','markerfacecolor','yellow','markeredgecolor','blue')

% if LmakeLines
%     for iLine=1:Nlines
%         Mline=CMpointOnLinesPHY{iLine};
%         hlines=line(Mline(:,1),Mline(:,2));
%         set(hlines,'marker','*','color',[rand,rand,rand],'markersize',6)
%     end
% end

% finish the plot
grid('on')
xlabel(SxLabel,'fontsize',14)
ylabel(SyLabel,'fontsize',14)
title(Stitle1,'fontsize',14)
if Llegend
    if isa(Xobj.Xals,'AdaptiveLineSampling')
        legend([hisoprob2,hs2,hs3,hl,hstartDir,hlastDir],...
            'isodensity curves','limit state points',...
            'evaluation points','performance lines',...
            'initial direction','updated direction');
    else
        legend([hisoprob2,hs2,hs3,hl,hstartDir],...
            'isodensity curves','limit state points',...
            'evaluation points','performance lines','importance direction');
    end
end

set(gca(fh),'FontSize',14);



subplot(122) %standard space
if exist('Xmodel','var')
    % Plot the limit state surface if a model is defined
    [~,hplotSNS]=contour(X,Y,Z,[0,0]);
    set(hplotSNS,'linewidth',2,'color','black')
end
hold on
% plot 5 isodensity curves
[~,hisoprob1]=contour(X,Y,ZpdfSNS,5);
set(hisoprob1,'linewidth',1,'linecolor','cyan')
hold on
% plot evaluation points
hs5=scatter(MS(1,:),MS(2,:));
set(hs5,'marker','o','markerfacecolor',[0.9,0.9,0.9],'markeredgecolor','blue')
% plot lines
VstartDirSns=Valpha_start*max(Vsupport);
hstartDir=line([0;VstartDirSns(1)],[0;VstartDirSns(2)]);
set(hstartDir,'color','red','linewidth',2,'linestyle','--');
% Mline0=CMsLines{1};
for iLine=1:Nlines-1
    Mlines=CMsLines{iLine};
    hl=line(Mlines(1,:),Mlines(2,:));
    set(hl,'color',[rand,rand,rand]);
end

if isa(Xobj.Xals,'AdaptiveLineSampling')
    % plot last direction
    VlastDirSns=Valpha_last*max(Vsupport);
    hlastDir=line([0,VlastDirSns(1)],[0,VlastDirSns(2)]);
    set(hlastDir,'color','green','linewidth',2,'linestyle','-.');
end

% plot the limit state points
    hs4=scatter(MlspSNS(:,1),MlspSNS(:,2));
    set(hs4,'marker','square','markerfacecolor','yellow','markeredgecolor','black')

% if LmakeLines
%     for iLine=1:Nlines
%         Mline=CMpointOnLinesSNS{iLine};
%         hlines=line(Mline(:,1),Mline(:,2));
%         set(hlines,'marker','*','color',[rand,rand,rand],'markersize',6)
%     end
% end

grid('on')
xlabel(SxLabel,'fontsize',14)
ylabel(SyLabel,'fontsize',14)
title(Stitle2,'fontsize',14)

if isa(Xobj.Xals,'AdaptiveLineSampling')
    if Llegend
        legend([hisoprob1,hs4,hs5,hl,hstartDir,hlastDir],...
            'isodensity curves','limit state points',...
            'evaluation points','performance lines',...
            'initial direction','updated direction');
    end
else
    if Llegend
        legend([hisoprob1,hs4,hs5,hl,hstartDir],...
            'isodensity curves','limit state points',...
            'evaluation points','performance lines','importance direction');
    end
end

set(gca(fh),'FontSize',14);

if exist('Sfigurename','var')
    saveas(fh,Sfigurename,'eps')
end

end %method
