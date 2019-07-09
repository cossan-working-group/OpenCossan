function Toutput = evaluate(Xobj,Tinput)
% Evalueate  Evaluation of NeuralNetwork
%
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria$
%
%

%%  Check that NeuralNetwork has been trained
assert(Xobj.Lcalibrated,'openCOSSAN:NeuralNetwork:evaluate',...
    'NeuralNetwork has not been calibrated')

% Use only required inputs. 
Tinput=Tinput(:,Xobj.Cinputnames);

Minputs=table2array(Tinput);


Nsamples=size(Minputs,1);


% Normalize Minputs  between Xnn.Vnormminmax(1) and Xnn.Vnormminmax(2)
MnormInput = Xobj.Vnormminmax(1)+ ...
    (Xobj.Vnormminmax(2)- Xobj.Vnormminmax(1))*(Minputs-repmat(Xobj.MboundsInput(1,:),Nsamples,1))./...
    (repmat(Xobj.MboundsInput(2,:),Nsamples,1)-repmat(Xobj.MboundsInput(1,:),Nsamples,1));

%%  Evaluate NeuralNetwork
MnormOutput = testFann(Xobj.TFannStruct, MnormInput);

% Denormalize
Mnn = repmat(Xobj.MboundsOutput(1,:),Nsamples,1) + 1/(Xobj.Vnormminmax(2)-Xobj.Vnormminmax(1))*...
    (repmat(Xobj.MboundsOutput(2,:),Nsamples,1)-repmat(Xobj.MboundsOutput(1,:),Nsamples,1)).*(MnormOutput - Xobj.Vnormminmax(1));


Toutput=array2table(Mnn,'VariableNames',Xobj.Coutputnames);


return
