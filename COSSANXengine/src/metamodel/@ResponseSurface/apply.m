function [XsimData] = apply(Xrs,Pinput)
%apply
%
%   This method applies the ResponseSurface over an Input object
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/apply@ResponseSurface
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria$

%%  Check that ResponseSurface has been trained
assert(Xrs.Lcalibrated,'openCOSSAN:ResponseSurface:apply',...
    'ResponseSurface has not been calibrated');

%%  Process input
switch class(Pinput)
    case 'Input'
        Tinput  = getStructure(Pinput);
        Minputs=Pinput.getValues('Cnames',Xrs.Cinputnames);
    case 'Samples'
        Tinput = Pinput.Tsamples;
    case 'struct'
        Tinput = Pinput;
    otherwise
        error('openCOSSAN:ResponseSurface:apply',...
            ['Cannot execute apply method. Input file of class  ' class(Pinput) ' not allowed.'])
end

if ~exist('Minputs','var')
    Minputs = cell2mat(squeeze(struct2cell(Tinput)))';
end

%%  Evaluate response surface
switch lower(Xrs.Stype),
    case {'linear'}
        MD      = x2fx(Minputs,'linear');
    case {'interaction'}
        MD      = x2fx(Minputs,'interaction');
    case {'purequadratic'}
        MD      = x2fx(Minputs,'purequadratic');
    case {'quadratic'}
        MD      = x2fx(Minputs,'quadratic');
    case {'custom'}
        MD      = x2fx(Minputs,Xrs.Mexponents);
    otherwise
        error('openCOSSAN:ResponseSurface:apply',...
            'Response surface type %s not valid', Xrs.Stype)
end

XSimDataInput=SimulationData('Sdescription','Simulation Output from ResponseSurface',...
    'Tvalues',Tinput);


% Explanation????
Mrs=zeros(length(Tinput),length(Xrs.Coutputnames));

for iresponse = 1:length(Xrs.Coutputnames)
    Mrs(:,iresponse)     = MD * Xrs.CVCoefficients{iresponse};
end

XSimDataOutput=SimulationData('Mvalues',Mrs,'Cnames',Xrs.Coutputnames);

XsimData = XSimDataInput.merge(XSimDataOutput);

return
