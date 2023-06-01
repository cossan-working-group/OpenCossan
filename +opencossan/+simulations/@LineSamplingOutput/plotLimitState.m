function varargout=plotLimitState(Xobj,varargin)
%PLOTLINES plots the value of the performance function on the lines
%
import opencossan.common.Samples
%% Initialisations
Stitle1='Standard Normal Space';
Stitle2='Physical State Space';
% SxLabel='variable #1';
% SyLabel='variable #2';
Smarker='o';
Svisible='on';
lineWidth=1;
NgridPoints=100;
Vsupport=[-6,6];
% Vset=0:5;
Llegend=true;

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'sfigurename'
            Sfigurename=varargin{k+1};
        case 'stitle'
            Stitle=varargin{k+1};
        case 'cstitles'
            CStitles=varargin{k+1};
        case 'smarker'
            Smarker=varargin{k+1};
        case 'svisible'
            Svisible=varargin{k+1};
        case 'linewidth'
            lineWidth=varargin{k+1};
        case 'llegend'
            Llegend=varargin{k+1};
        case 'cdisplaynames'
            CdisplayNames=varargin{k+1};
        case 'xsimulationdata'
            XsimulationData=varargin{k+1};
        case {'ngridpoints','npoints'}
            NgridPoints=varargin{k+1};
%         case 'vsupport'
%             Vsupport=varargin{k+1};
%         case 'vset'
%             Vset=varargin{k+1};
        case 'xmodel'
            Xmodel=varargin{k+1};
%         case 'nlines'
%             Nlines=varargin{k+1};
        otherwise
            error('openCOSSAN:LineSamplingData:plotLines',...
                ['Field name (' varargin{k} ') not allowed']);
    end
end

Cnames=Xobj.Xinput.CnamesRandomVariable;
if exist('CdisplayNames','var')
    SxLabel=CdisplayNames{1};
    SyLabel=CdisplayNames{2};
else
    SxLabel=Cnames{1};
    SyLabel=Cnames{2};
end
%% Check the data

assert(Xobj.Nvars<=2,...
    'openCOSSAN:outputs:LineSamplingOutput:plotLimitState',...
    'Maximum allowed number of variables for this plot is 2')
assert(length(Xobj.Xinput.CnamesRandomVariableSet)==1,...
    'openCOSSAN:outputs:LineSamplingOutput:plotLimitState',...
    'Only one random variable set is allowed for this plot')
assert(~isempty(Xobj.VdistanceOrigin),...
    'openCOSSAN:outputs:LineSamplingOutput:plotLimitState', ...
    'No data available in the object')
assert(~isempty(Xobj.VdistancePlane),...
    'openCOSSAN:outputs:LineSamplingOutput:plotLimitState', ...
    'No data available in the object')



%% Preprocess results (prepare for the plot)
% Retrieve performance function values
% Vg=Xobj.getValues('Sname',Xobj.SperformanceFunctionName);

CnamesRVS=Xobj.Xinput.CnamesRandomVariableSet;
Xrvs=Xobj.Xinput.Xrvset.(CnamesRVS{1});
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% WARNING: THIS MAY REQUIRE TOO MANY MODEL EVALUATIONS 
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Evaluate limit state surface using the model
if exist('Xmodel','var')
    NgridLS=30;
    % Make a grid of points for the limit state evaluation
    xx=linspace(Vsupport(1),Vsupport(2),NgridLS);
    [XlsSNS,YlsSNS]=meshgrid(xx);
    Mdata=[XlsSNS(:),YlsSNS(:)];
    MlsPHY=map2physical(Xrvs,Mdata);
    XlsPHY=reshape(MlsPHY(:,1),NgridLS,NgridLS);
    YlsPHY=reshape(MlsPHY(:,2),NgridLS,NgridLS);
    Xsample_grid=Samples('Xinput',Xobj.Xinput,...
        'MsamplesStandardNormalSpace',Mdata);
    Xobj.Xinput.Xsamples=Xsample_grid;
    XsimOut=apply(Xmodel,Xobj.Xinput);
    SoutputName=Xmodel.XperformanceFunction.Soutputname;
    Vmodel_output=XsimOut.getValues('Sname',SoutputName);
    Z=reshape(Vmodel_output,NgridLS,NgridLS);
end
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% Make a grid of points for the isodensity curves
xx=linspace(Vsupport(1),Vsupport(2),NgridPoints);
[X,Y]=meshgrid(xx);
Mdata=[X(:),Y(:)];
% Extract the random variable set from the input object
Xrvs=Xobj.Xinput.Xrvset.(CnamesRVS{1});
% samples in physical space
Mphy=map2physical(Xrvs,Mdata);
Xphy=reshape(Mphy(:,1),NgridPoints,NgridPoints);
Yphy=reshape(Mphy(:,2),NgridPoints,NgridPoints);
% density function in standard space
pdfSNS= Xrvs.evalpdf('MsamplesStandardNormalSpace',Mdata);
ZpdfSNS=reshape(pdfSNS,NgridPoints,NgridPoints);
% density function in original space
pdfPHY= Xrvs.evalpdf('MsamplesPhysicalSpace',Mphy);
ZpdfPHY=reshape(pdfPHY,NgridPoints,NgridPoints);


Nlines=Xobj.NprocessedLines;
% extract evaluation points
CMxLines=cell(1,Nlines);
CMsLines=cell(1,Nlines);
% matrix with evaluation points
MX(1,:)=transpose(Xobj.getValues('Sname',Cnames{1}));
MX(2,:)=transpose(Xobj.getValues('Sname',Cnames{2}));
Valpha=Xobj.VinitialDirectionSNS;
istart=1;
for iLine=1:Nlines
    iend=istart+Xobj.VnumPointLine(iLine)-1;
    Mx=MX(:,istart:iend);
    Ms=Xobj.Xinput.map2stdnorm(Mx);
    CMxLines{iLine}=Mx;
    CMsLines{iLine}=Ms;
    % calculate coordinates of limit state point
    c=Xobj.VdistancePlane(istart);
    d=Xobj.VlimitStateDistances(iLine);
    MlspSNS(:,iLine)=Ms(:,1)+(d-c)*Valpha;
    istart=iend+1;
end
MlspPHY=Xobj.Xinput.map2physical(MlspSNS')';
MS=Xobj.Xinput.map2stdnorm(MX);

%% Start the plot
fh1=figure('visible',Svisible);
haxe1=axes;
fh2=figure('visible',Svisible);
haxe2=axes;

hold(gca(fh1),'on');
hold(gca(fh2),'on');

title(gca(fh1),Stitle1,'fontsize',14)
title(gca(fh2),Stitle2,'fontsize',14)

xlabel(gca(fh1),SxLabel,'FontSize',14)
ylabel(gca(fh1),SyLabel,'FontSize',14)
xlabel(gca(fh2),SxLabel,'FontSize',14)
ylabel(gca(fh2),SyLabel,'FontSize',14)

if exist('Xmodel','var')
    % Plot the limit state surface if a model is defined
    [~,hplotSNS]=contour(haxe1,XlsSNS,YlsSNS,Z,[0,0]);
    set(hplotSNS,'linewidth',2,'color','black')
    [~,hplotPHY]=contour(haxe2,XlsPHY,YlsPHY,Z,[0,0]);
    set(hplotPHY,'linewidth',2,'color','black')
end

% plot 5 isodensity curves
[~,hisoprob1]=contour(haxe1,X,Y,ZpdfSNS,5);
% set(hisoprob1,'linewidth',1,'linecolor','cyan')
[~,hisoprob2]=contour(haxe2,Xphy,Yphy,ZpdfPHY,5);
% set(hisoprob2,'linewidth',1,'linecolor','blue')

% plot evaluation points
hs3=scatter(haxe1,MS(1,:),MS(2,:));
set(hs3,'marker','o','markerfacecolor',[0.9,0.9,0.9],'markeredgecolor','blue')
hs5=scatter(haxe2,MX(1,:),MX(2,:));
set(hs5,'marker','o','markerfacecolor',[0.9,0.9,0.9],'markeredgecolor','blue')
% plot initial direction
VstartDirSns=Xobj.VinitialDirectionSNS*max(Vsupport);
hinitDirS=plot(haxe1,[0,VstartDirSns(1)],[0,VstartDirSns(2)]);
set(hinitDirS,'color','green','linewidth',2,'linestyle','-');
% VinitDirPhy=Xobj.VinitialDirectionPHY;
VinitPolePhy=Xobj.Xinput.map2physical(VstartDirSns);
VmedianState=Xobj.Xinput.map2physical([0 0]);
hinitDirX=plot(haxe2,[VmedianState(1),VinitPolePhy(1)],...
    [VmedianState(2),VinitPolePhy(2)]);
set(hinitDirX,'color','green','linewidth',2,'linestyle','-');
% plot lines
for iLine=2:Nlines
    Mslines=CMsLines{iLine};
    hls=plot(haxe1,Mslines(1,:)',Mslines(2,:)');
    set(hls,'color',[rand,rand,rand]);
    Mxlines=CMxLines{iLine};
    hlx=plot(haxe2,Mxlines(1,:)',Mxlines(2,:)');
    set(hlx,'color',[rand,rand,rand]);
end
if Xobj.Lals
    set(hinitDirS,'color','red','linewidth',2,'linestyle','--');
    set(hinitDirX,'color','red','linewidth',2,'linestyle','--');
    % plot last direction
    VlastDirSns=Xobj.VlastDirectionSNS*max(Vsupport);
    hlastDirS=plot(haxe1,[0,VlastDirSns(1)],[0,VlastDirSns(2)]);
    set(hlastDirS,'color','green','linewidth',2,'linestyle','-.');
    VlastDirPhy=Xobj.VlastDirectionPHY*max(Vsupport);
    hlastDirX=plot(haxe2,[VmedianState(1),VlastDirPhy(1)],[VmedianState(2),VlastDirPhy(2)]);
    set(hlastDirX,'color','green','linewidth',2,'linestyle','-.');
    % plot the limit state points
    hs2=scatter(haxe1,Xobj.MlimitStateCoordsSNS(:,1),Xobj.MlimitStateCoordsSNS(:,2));
    set(hs2,'marker','square','markerfacecolor','yellow','markeredgecolor','black')
    hs4=scatter(haxe2,Xobj.MlimitStateCoordsPHY(:,1),Xobj.MlimitStateCoordsPHY(:,2));
    set(hs4,'marker','square','markerfacecolor','yellow','markeredgecolor','blue')
else
    % plot the limit state points
    hs2=scatter(haxe1,MlspSNS(1,:),MlspSNS(2,:));
    set(hs2,'marker','square','markerfacecolor','yellow','markeredgecolor','black')
    hs4=scatter(haxe2,MlspPHY(1,:),MlspPHY(2,:));
    set(hs4,'marker','square','markerfacecolor','yellow','markeredgecolor','blue')
end
% create box and grid
box(gca(fh1),'on');box(gca(fh2),'on');
grid(gca(fh1),'on');grid(gca(fh2),'on');
% create a legend
if Llegend
    if Xobj.Lals
        legend(haxe1,[hisoprob1,hs2,hs3,hls,hinitDirS,hlastDirS],...
            'isodensity curves','limit state points',...
            'evaluation points','performance lines',...
            'initial direction','updated direction');
        legend(haxe2,[hisoprob2,hs4,hs5,hlx,hinitDirX,hlastDirX],...
            'isodensity curves','limit state points',...
            'evaluation points','performance lines',...
            'initial direction','updated direction');
    else
        legend(haxe1,[hisoprob1,hs2,hs3,hls,hinitDirS],...
            'isodensity curves','limit state points',...
            'evaluation points','performance lines','importance direction');
        legend(haxe2,[hisoprob2,hs4,hs5,hlx,hinitDirX],...
            'isodensity curves','limit state points',...
            'evaluation points','performance lines','importance direction');
    end
end
set(gca(fh1),'FontSize',14);
set(gca(fh2),'FontSize',14);
varargout{1}=fh1;
varargout{2}=fh2;