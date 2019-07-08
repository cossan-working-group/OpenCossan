function Xobj=validateConstructor(Xobj)
%VALIDATECONSTRUCTOR Thism private method is used for validate the constructors
%of the subclass.
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@MetaModel
%
% Copyright 1993-2011, COSSAN Working Group, University~of~Innsbruck, Austria

% if XcalibrationOutput is defined, then retrieve the input
% from it to define XcalibrationInput

if ~isempty(Xobj.XcalibrationOutput)
    if isempty(Xobj.XcalibrationInput)
        Minputs = zeros(Nsamples,length(Xobj.Cinputnames));
        for j=1:length(Xobj.Cinputnames)
            Minputs(:,j) = Xobj.XcalibrationOutput.getValues('Sname',Xobj.Cinputnames{j});
        end
        Xs = Samples('Xinput',Xobj.Xinput,'MsamplesPhysicalSpace',Minputs);
        Xobj.XcalibrationInput = Xobj.Xinput;
        Xobj.XcalibrationInput.Xsamples = Xs;
    end
end

% check that the selected response is present in the model
if ~isempty(Xobj.XFullmodel)
    Calloutputnames = Xobj.XFullmodel.Coutputnames;
elseif ~isempty(Xobj.XcalibrationOutput)
    Calloutputnames = Xobj.XcalibrationOutput.Cnames;
else
    error('openCOSSAN:ResponseSurface:ResponseSurface',...
        'Either the full model or XcalibrationInput and XcalibrationOutput have to be defined');
end

if isempty(Xobj.Coutputnames)
    Xobj.Coutputnames=Calloutputnames;
else
    
    assert(all(ismember(Xobj.Coutputnames,Calloutputnames)),...
        'openCOSSAN:ResponseSurface',...
        strcat('Not all members of Coutputnames are present in the Model',...
        '\n Model outputs: %s\n Required outputs: %s\n'),...
        sprintf('"%s" ',Calloutputnames{:}),sprintf('"%s" ',Xobj.Coutputnames{:}));
end

% check that the selected response is present in the model
if ~isempty(Xobj.XFullmodel)
    
    assert(isa(Xobj.XFullmodel,'Model'), ...
        'openCOSSAN:ResponseSurface',...
        'Full model of class %s not valid ',class(Xobj.XFullmodel));
    
    Callinputnames = Xobj.XFullmodel.Cinputnames;
elseif ~isempty(Xobj.XcalibrationInput)
    Callinputnames = Xobj.XcalibrationInput.Cnames;
else
    error('openCOSSAN:ResponseSurface',...
        'Either the full model or XcalibrationInput have to be defined');
end

if isempty(Xobj.Cinputnames)
    Xobj.Cinputnames=Callinputnames;
else
    assert(all(ismember(Xobj.Cinputnames,Callinputnames)),...
        'openCOSSAN:ResponseSurface',...
        strcat('Not all the required inputs factors are present in the ',...
        'Model or in the calibration point\n Model inputs: %s\n Required inputs: \s'),...
        sprintf('"%s" ',Callinputnames{:}),sprintf('"%s" ',Xobj.Cinputnames{:}));
end

if ~isempty(Xobj.XvalidationOutput)
    if isempty(Xobj.XvalidationInput)
        Minputs = zeros(Nsamples,length(Xobj.Cinputnames));
        for j=1:length(Xobj.Cinputnames)
            Minputs(:,j) = Xobj.XvalidationOutput.getValues('Sname',Xobj.Cinputnames{j});
        end
        Xs = Samples('Xinput',Xobj.Xinput,'MsamplesPhysicalSpace',Minputs);
        Xobj.XvalidationInput = Xobj.Xinput;
        Xobj.XvalidationInput.Xsamples = Xs;
    end
end
