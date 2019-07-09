function varargout = evalpdf(Xsample,varargin)
%EVALPDF Evaluates the multidimensional pdf of a set of R at the points in
%  the Nvar-dimensional space MX, where Nvar is the # of columns of MX
%  and the # of rows of MX is the number of samples
%
%
%
%   Optional PropertyName:
%   Sspace:    string containing the name if the space in which the pdf has
%              to be return
%   Llog:          if true, the logarithm of the pdf will be return in Vpdf
%
%   OPTIONAL OUTPUT:
%   - varargout{1} = Vpdf					Vector of the pdf
%   - varargout{2} = Vpdfrv		            Vector of the pdf of each RV (see theory manual)
%
%  Usage: [Vpdf Vpdfrv] = evalpdf(Xs,'Sspace','physicalspace','Llog',false);
%
%  See also: Samples
%



%% 1.   Argument Verification

OpenCossan.validateCossanInputs(varargin{:});
Llog=false;


for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'sspace'}
            Sspace=varargin{k+1};

        case {'llog'}
            Llog=varargin{k+1};
        otherwise
            error('openCOSSAN:RandomVariableSet:evalpdf',...
                ['PropertyName ' varargin{k} ' not allowed'])
    end
end

%TODO check of space inputed

switch lower(Sspace)
    case {'x','physicalspace'}

         Vpdfrv = zeros(Xsample.Nsamples,length(Xsample.CnamesRandomVariable));
         Vpdf_tmp= zeros(Xsample.Nsamples,length(Xsample.Xrvset));
         NcurrentSample=0;
         for iRvs=1:length(Xsample.Xrvset)
             
                 Nstart=NcurrentSample+1;
                 Nend=NcurrentSample+Xsample.Xrvset(iRvs).Nrv;
                  [Vpdf_tmp(:,iRvs) Vpdfrv(:,Nstart:Nend)] = ...
                     Xsample.Xrvset(iRvs).evalpdf('mxsamples',Xsample.MsamplesPhysicalSpace(:,Nstart:Nend),'Llog',Llog);

                 NcurrentSample=Nend;
         end
         
         if Llog
             Vpdf=sum(log((Vpdf_tmp)),2);
         else
             Vpdf=prod(Vpdf_tmp,2);
         end
        
    case {'u','standardnormalspace'}
        
         Vpdfrv = zeros(Xsample.Nsamples,length(Xsample.CnamesRandomVariable));
         Vpdf_tmp= zeros(Xsample.Nsamples,length(Xsample.Xrvset));
         NcurrentSample=0;
         for iRvs=1:length(Xsample.Xrvset)
             
                 Nstart=NcurrentSample+1;
                 Nend=NcurrentSample+Xsample.Xrvset(iRvs).Nrv;
                  [Vpdf_tmp(:,iRvs) Vpdfrv(:,Nstart:Nend)] = ...
                     Xsample.Xrvset(iRvs).evalpdf('musamples',Xsample.MsamplesStandardNormalSpace(:,Nstart:Nend),'Llog',Llog);

                 NcurrentSample=Nend;
         end
         
         if Llog
             Vpdf=sum(log((Vpdf_tmp)),2);
         else
             Vpdf=prod(Vpdf_tmp,2);
         end
        
        
    case {'h','sampleshypercube'}
        
        Vpdfrv = ones(Xsample.Nsamples,length(Xsample.CnamesRandomVariable));
        Mcorrelation = eye(length(Xsample.CnamesRandomVariable));
        
        NcurrentSample=0;
        for iRvs=1:length(Xsample.Xrvset)
            
            Nstart=NcurrentSample+1;
            Nend=NcurrentSample+Xsample.Xrvset(iRvs).Nrv;
            if ~Xsample.Xrvset(iRvs).Lindependence
                Mcorrelation(Nstart:Nend,Nstart:Nend) = Xsample.Xrvset.Mcorrelation;
            end
            
            NcurrentSample=Nend;
        end
        
        Vpdf = copulapdf('Gaussian',Xsample.MsamplesHyperCube,Mcorrelation);
                 
        if Llog
            Vpdfrv=log((Vpdfrv));
        end
end


% Export results
varargout{1}=Vpdf;
varargout{2}=Vpdfrv;

