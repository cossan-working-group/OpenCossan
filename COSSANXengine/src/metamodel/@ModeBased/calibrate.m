function  Xobj = calibrate(Xobj,varargin)

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'nsamples'}
            Nsamples = varargin{k+1};
        case {'vmodes'}
            Xobj.Vmodes = varargin{k+1};
        case {'vmkmodes'}
            Xobj.Vmkmodes = varargin{k+1};
        case {'mmass0'}
            Xobj.Mmass0 = varargin{k+1};
        case{'xcalibrationinput'}
            Xobj.XcalibrationInput = varargin{k+1};
        case{'xcalibrationoutput'}
            Xobj.XcalibrationOutput = varargin{k+1};
        case {'cfilenamescalibrationset'}
            Xobj.CfilenamesCalibrationSet =varargin{k+1};
        case {'cnamescalibrationinput'}
            Xobj.CnamesCalibrationInput =varargin{k+1};
        case {'cnamescalibrationoutput'}
            Xobj.CnamesCalibrationOutput =varargin{k+1};
        otherwise
            error('openCOSSAN:metamodel:calibrate',...
                ['Field name (' varargin{k} ') not allowed']);
    end
end
if isempty(Xobj.Vmkmodes)
    error('openCOSSAN:metamodel:calibrate',...
        'The number of modes Vmkmodes to be used for the approximation has to be specified');
end

if exist('Nsamples','var')
    Xobj.XcalibrationInput = sample(Xobj.XFullmodel.Xinput,'Nsamples',Nsamples);
end

if ~isempty(Xobj.SfilenamesCalibrationSet)
    if isempty(Xobj.SnamesCalibrationInput)
        error('openCOSSAN:ModeBased',...
            'The name of the Input object contained in the file are not specified');
    end
    if isempty(Xobj.SnamesCalibrationOutput)
        error('openCOSSAN:ModeBased',...
            'The names of the Mode object contained in the file are not specified');
    end
    load(Xobj.SfilenamesCalibrationSet)
    eval(['Xobj.XcalibrationInput = ' Xobj.SnamesCalibrationInput]);
    eval(['Xobj.XcalibrationOutput = ' Xobj.SnamesCalibrationOutput]);
end
            

if ~isempty(Xobj.XcalibrationInput) && isempty(Xobj.XcalibrationInput.Xsamples)
            error('openCOSSAN:metamodel:calibration',...
            'XcalibrationInput does not contain any samples');
end

if ~isempty(Xobj.XcalibrationInput)
    if Xobj.XcalibrationInput.Xsamples.Nsamples~= 0
        Nsamples = Xobj.XcalibrationInput.Xsamples.Nsamples;
    else
        error('openCOSSAN:metamodel:calibration',...
            ['Either samples (contained in the Input object) ' ...
            'or the number of calibration samples has to be provided']);
    end
else
    error('openCOSSAN:metamodel:calibration',...
        ['Either samples (contained in the Input object) ' ...
        'or the number of calibration samples has to be provided']);
end

if  isempty(Xobj.XcalibrationOutput)
    XSimOut = apply(Xobj.XFullmodel,Xobj.XcalibrationInput);
    for isim = 1:XSimOut.Nsamples
        Xmodescalibration(isim) = Modes('MPhi',XSimOut.Tvalues(isim).(Xobj.Cnamesmodalprop{2}),...
                                        'Vlambda',XSimOut.Tvalues(isim).(Xobj.Cnamesmodalprop{1}));
    end
    Xobj.XcalibrationOutput = Xmodescalibration;
end

Cindexmodes = cell(max(Xobj.Vmodes),1);
nentries = 0;
if size(Xobj.Vmodes,1)>1
    Xobj.Vmodes = Xobj.Vmodes';
end

icount = 1;
for imode=Xobj.Vmodes
    mk_lower = max(1,imode-Xobj.Vmkmodes(icount)); % min lower index = 1
    mk_upper = min(size(Xobj.Xmodes0.MPhi,2),imode+Xobj.Vmkmodes(icount)); % max upper index = number of nominal eigenvectors
    Cindexmodes{imode} = mk_lower:mk_upper;
    nentries = nentries + length(mk_lower:mk_upper)+1;
    icount = icount + 1;
end
Xobj.Cindexmodes = Cindexmodes;


Nsamples = Xobj.XcalibrationInput.Xsamples.Nsamples;

Y1 = zeros(Nsamples,nentries);
Y = [];

for isim = 1:Nsamples
    
    MProjection = Xobj.XcalibrationOutput(isim).MPhi'*Xobj.Mmass0*Xobj.Xmodes0.MPhi;

    
    [nr,nc] = size(MProjection);
    [xxx,ind] = sort(-max(abs(MProjection),[],1));
    indc = zeros(min(nr,nc),1);
    indr = zeros(min(nr,nc),1);
    ir = 1:nr;
    for i=1:min(nr,nc)
        indc(i) = ind(i);
        [xxx,ii] = max(abs(MProjection(ir,indc(i))));
        indr(i) = ir(ii);
        ir(ii)=[];
    end
    [indc,ind] = sort(indc);
    indr = indr(ind);
    

    Xobj.XcalibrationOutput(isim).MPhi = Xobj.XcalibrationOutput(isim).MPhi(:,indr);
    
    for k=Xobj.Vmodes
            if Xobj.Xmodes0.MPhi(:,k)'*Xobj.XcalibrationOutput(isim).MPhi(:,k)<0
                Xobj.XcalibrationOutput(isim).MPhi(:,k) = -Xobj.XcalibrationOutput(isim).MPhi(:,k);
            end
    end
    %
    % Important step: manipulation if there are missing modes
    %
    kpos = 1;
    for k=Xobj.Vmodes
        Mphi0k = Xobj.Xmodes0.MPhi(:,Cindexmodes{k});
        alpha = (Mphi0k'*Mphi0k)\(Mphi0k'*Xobj.XcalibrationOutput(isim).MPhi(:,k));
        [val max_pos] = max(abs(alpha));
        dak = norm(Xobj.XcalibrationOutput(isim).MPhi(:,k))/norm(Xobj.Xmodes0.MPhi(:,Cindexmodes{k}(max_pos))) - 1.0;        
        alpha = alpha(setdiff((1:length(alpha)),max_pos));
        delta_omega = (Xobj.XcalibrationOutput(isim).Vlambda(k)/Xobj.Xmodes0.Vlambda(k)-1);
        Y1(isim,kpos:kpos+length(Cindexmodes{k})) = [dak delta_omega alpha'/(1+dak)];
        kpos = kpos + length(Cindexmodes{k})+1;
    end
end
Y = [Y;Y1];

X = Xobj.XcalibrationInput.Xsamples.MsamplesStandardNormalSpace;

Xobj.MboundsInput = zeros(2,size(X,2));
for j=1:size(X,2)
    Xobj.MboundsInput(:,j) = [min(Xobj.XcalibrationInput.Xsamples.MsamplesPhysicalSpace(:,j)); 
                              max(Xobj.XcalibrationInput.Xsamples.MsamplesPhysicalSpace(:,j)) ];
end

Xobj.Mlincomb = (X\Y)';
Xobj.Lcalibrated = 1;

return;