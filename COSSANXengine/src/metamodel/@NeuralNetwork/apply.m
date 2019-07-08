function XsimData = apply(Xnn,Pinput)
%APPLY  Evaluation of NeuralNetwork
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Apply@NeuralNetwork
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria$
%
%

%%  Check that NeuralNetwork has been trained
assert(Xnn.Lcalibrated,'openCOSSAN:NeuralNetwork:apply',...
    'NeuralNetwork has not been calibrated')


%%  Process input
switch class(Pinput)
    case 'Input'
        Tinput  = getStructure(Pinput);
        Minputs=Pinput.getValues('Cnames',Xnn.Cinputnames);
    case 'Samples'
        Tinput = Pinput.Tsamples;
    case 'struct'
        Tinput  = Pinput;
    otherwise
        error('openCOSSAN:NeuralNetworl:apply',...
            ['Cannot execute apply method. Input file of class  ' class(Pinput) ' not allowed.'])
end

Nsamples=length(Tinput);
% Construct Minput from the Tinput
if ~exist('Minputs','var')
    Minputs = cell2mat(squeeze(struct2cell(Tinput)))';
end


XSimDataInput=SimulationData('Sdescription','Simulation Output from NeuralNetwork',...
    'Tvalues',Tinput);


% Normalize Minputs  between Xnn.Vnormminmax(1) and Xnn.Vnormminmax(2)
MnormInput = Xnn.Vnormminmax(1)+ ...
    (Xnn.Vnormminmax(2)- Xnn.Vnormminmax(1))*(Minputs-repmat(Xnn.MboundsInput(1,:),Nsamples,1))./...
    (repmat(Xnn.MboundsInput(2,:),Nsamples,1)-repmat(Xnn.MboundsInput(1,:),Nsamples,1));

%%  Evaluate NeuralNetwork
MnormOutput = testFann(Xnn.TFannStruct, MnormInput);

% Denormalize
Mnn = repmat(Xnn.MboundsOutput(1,:),Nsamples,1) + 1/(Xnn.Vnormminmax(2)-Xnn.Vnormminmax(1))*...
    (repmat(Xnn.MboundsOutput(2,:),Nsamples,1)-repmat(Xnn.MboundsOutput(1,:),Nsamples,1)).*(MnormOutput - Xnn.Vnormminmax(1));


XSimDataOutput=SimulationData('Mvalues',Mnn,'Cnames',Xnn.Coutputnames);

XsimData = XSimDataInput.merge(XSimDataOutput);

return
