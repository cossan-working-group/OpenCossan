function [XsimData] = apply(Xobj,Pinput)
%apply
%
%   This method applies the PolyharmonicSplines over an Input object
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/apply@PolyharmonicSplines
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

%%  Evaluate splines

% auxiliary variables
Nsamples = size(Minputs,1);
Ndim = size(Xobj.Mcenters,2);
Ncenters = size(Xobj.Mcenters,1);

XSimDataInput=SimulationData('Sdescription','Simulation Output from ResponseSurface',...
    'Tvalues',Tinput);

% initialize the matrix that will contain the estimated outputs
Moutput=zeros(length(Tinput),length(Xobj.Coutputnames));

for iresponse = 1:length(Xobj.Coutputnames)
    % compute the relative distance between the evaluation points and each center
    Mdist = zeros(Nsamples,Ncenters);
    for idim = 1:Ndim
        Mdist = Mdist + bsxfun(@minus,Minputs(:,idim),Xobj.Mcenters(:,idim)').^2;
    end
    Mdist = sqrt(Mdist);
    
    % apply the desired polyharmonic base function
    if bitget(double(Xobj.Nexponent), 1) %very fast check if integer is odd or even
        Mdist = Mdist.^Xobj.Nexponent;
    else
        % if there are points coincidents with the centers, the distance
        % will be zero. The logarithm will return NaN as an output, but we 
        % know that the output we want is 0)
        Mdist = Mdist.^Xobj.Nexponent.*log(Mdist);
        % put a zero instead of the NaNs (all the points with identical
        % coordinates)
        Mdist(isnan(Mdist)) = 0; 
    end
    
    Moutput(:,iresponse) =sum(repmat(Xobj.CVsplinesCoefficients{iresponse}',Nsamples,1).*Mdist,2) +...
        x2fx(Minputs,Xobj.SextrapolationType)*Xobj.CVpolyCoefficients{iresponse};
end

XSimDataOutput=SimulationData('Mvalues',Moutput,'Cnames',Xobj.Coutputnames);

XsimData = XSimDataInput.merge(XSimDataOutput);

return
