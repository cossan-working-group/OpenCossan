function [XsimData] = apply(Xobj,Pinput)
%apply
%
%   This method applies the KrigingModel over an Input object
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/apply@KrigingModel
%
% Copyright~1993-2012, $

%%  Check that ResponseSurface has been trained
assert(Xobj.Lcalibrated,'openCOSSAN:PolyharmonicSplines:apply',...
    'PolyharmonicSplines has not been calibrated');

%%  Process input
switch class(Pinput)
    case 'Input'
        Tinput  = getStructure(Pinput);
        Minputs=Pinput.getValues('Cnames',Xobj.Cinputnames);
    case 'Samples'
        Tinput = Pinput.Tsamples;
    case 'struct'
        Tinput = Pinput;
    otherwise
        error('openCOSSAN:PolyharmonicSplines:apply',...
            ['Cannot execute apply method. Input file of class  ' class(Pinput) ' not allowed.'])
end

if ~exist('Minputs','var')
    Minputs = cell2mat(squeeze(struct2cell(Tinput)))';
end

%%  Evaluate Kriging Model
XSimDataInput=SimulationData('Sdescription','Simulation Output from ResponseSurface',...
    'Tvalues',Tinput);

Moutput = predictor(Minputs,Xobj.TdaceModel); 

XSimDataOutput=SimulationData('Mvalues',Moutput,'Cnames',Xobj.Coutputnames);

XsimData = XSimDataInput.merge(XSimDataOutput);

return
