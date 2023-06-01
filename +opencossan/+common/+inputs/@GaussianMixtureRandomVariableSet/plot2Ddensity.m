function varargout = plot2Ddensity(Xobj,varargin)
%plot2Ddensity  Plot 2D density of the GaussianRandomVariableSet
%   This function is used to display the pdf density of two selected
%   RandomVariable.

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

% Default values
Svisible='on';
Npoints=100;
Nlevels=50;

% Assign default values
assert (Xobj.Nrv>1,...
    'openCOSSAN:GaussianRandomVariableSet:plot2Ddensity',...
    'The 2D plot can not be displyed because the object contains only %i random variable.',Xobj.Nrv)

if Xobj.Nrv>1
    SxAxisVariable=Xobj.Cmembers{1};
    SyAxisVariable=Xobj.Cmembers{2};
end

%% Add fields
for k=1:2:length(varargin),
    switch lower(varargin{k}),
        case 'sxaxisvariable'
            % Define indices
            SxAxisVariable=varargin{k+1};
        case 'syaxisvariable'
            % Define indices
            SyAxisVariable=varargin{k+1};
        case 'npoints'
            % Define indices
            Npoints=varargin{k+1};
        case 'nlevels'
            % Define indices
            Nlevels=varargin{k+1};
        case 'sfigurename'
            SfigureName=varargin{k+1};
        case 'sexportformat'
            Sexportformat=varargin{k+1};
        case 'lvisible'
            if varargin{k+1}
                Svisible='on';
            else
                Svisible='off';
            end
        otherwise
            warning('openCOSSAN:GaussianRandomVariableSet:plot2Ddensity',...
                ['PropertyName ' varargin{k} ' ignored']);
    end
end



figHandle=figure('Visible',Svisible);
varargout{1}=figHandle;
hold(gca,'on')

%% Find indices of the Variables
xind=find(strcmp(Xobj.Cmembers,SxAxisVariable));
assert (~isempty(xind),...
    'openCOSSAN:GaussianRandomVariableSet:plot2Ddensity',...
    [SxAxisVariable ' not present in the object'])

yind=find(strcmp(Xobj.Cmembers,SyAxisVariable));

assert (~isempty(yind),...
    'openCOSSAN:GaussianRandomVariableSet:plot2Ddensity',...
    [SyAxisVariable ' not present in the object'])


x1=Xobj.MdataSet(:,xind);
x2=Xobj.MdataSet(:,yind);

Nloops=Xobj.Ncomponents;
s1=zeros(Nloops,1);
s2=zeros(Nloops,1);
rhoXY=zeros(Nloops,1);

if Xobj.gmDistribution.SharedCov
    Vsigma = sqrt(diag(Xobj.Mcovariance));
    Mcorr = corrcov(Xobj.Mcovariance);
%     [Vsigma Mcorr]=cov2corr(Xobj.Mcovariance);
    s1(:)=repmat(Vsigma(xind),1,Nloops);
    s2(:)=repmat(Vsigma(yind),1,Nloops);
    rhoXY(:)=repmat(Mcorr(xind,yind),1,Nloops);
else
    for iloop=1:Nloops
        Vsigma = sqrt(diag(Xobj.Mcovariance(:,:,iloop)));
        Mcorr = corrcov(Xobj.Mcovariance(:,:,iloop));        
%         [Vsigma Mcorr]=cov2corr(Xobj.Mcovariance(:,:,iloop));
        s1(iloop)=Vsigma(xind);
        s2(iloop)=Vsigma(yind);
        rhoXY(iloop)=Mcorr(xind,yind);
    end
end

deltaX=4*max(s1);
deltaY=4*max(s2);

y1 = linspace(min(x1)-deltaX, max(x1)+deltaX, Npoints);
y2 = linspace(min(x2)-deltaY, max(x2)+deltaY, Npoints);

dx1 = y1(2)-y1(1);
dx2 = y2(2)-y2(1);

[X1,X2] = meshgrid(y1,y2);

Ztot=zeros(Npoints);
N = numel(x1);
    for k=1:N
        Z = zeros(Npoints);
        x1k = x1(k);
        x1k_min = x1k-3*s1(k);
        x1k_max = x1k+3*s1(k);
        i1_min = max(1,1+floor((x1k_min-y1(1))/dx1));
        i1_max = min(Npoints,1+ceil((x1k_max-y1(1))/dx1));
        
        x2k = x2(k);
        x2k_min = x2k-3*s2(k);
        x2k_max = x2k+3*s2(k);
        i2_min = max(1,1+floor((x2k_min-y2(1))/dx2));
        i2_max = min(Npoints,1+ceil((x2k_max-y2(1))/dx2));
        
        a0 = -1/(2*(1-rhoXY(k)^2));
        for  i1=i1_min:i1_max
            a1 = exp(a0*((y1(i1)-x1k)/s1(k))^2);
            for i2=i2_min:i2_max
                a2 = exp(a0*((y2(i2)-x2k)/s2(k))^2);
                a3 = exp(-a0*2*rhoXY(k)*(y1(i1)-x1k)*(y2(i2)-x2k)/(s1(k)*s2(k)));
                Z(i2,i1) = Z(i2,i1)+a1*a2*a3;
            end
        end
        Ztot=Ztot+Z/(2*pi*s1(k)*s2(k)*sqrt(1-rhoXY(k)^2))* ...
            Xobj.gmDistribution.PComponents(k);
    end

Z_max = max(max(Ztot))/2;
Z_min = Z_max/500;

set(gca,'FontSize',16);
contour(gca,X1,X2,Ztot,linspace(Z_min,Z_max,Nlevels))

%axis square
hs=scatter(x1,x2,'o');

set(hs,'MarkerFaceColor',[0.784 0.816 0.831],'MarkerEdgeColor','k')

xlabel(SxAxisVariable);
ylabel(SyAxisVariable);
title(['2D Probability Density Function (' Xobj.Sdescription ')'])
grid on
box on
legend('PDF levels','User data','Location','Best')

%% Export Figure

if exist('SfigureName','var')
    if exist('Sexportformat','var')
        exportFigure('HfigureHandle',figHandle,'SfigureName',SfigureName,'SexportFormat',Sexportformat)
    else
        exportFigure('HfigureHandle',figHandle,'SfigureName',SfigureName)
    end
end
