function Toutput = ExampleMioStructure(Tinput)
% Example of Mio Function
% Input and output passed as Structure
% Required Inputs RV1, RV2
% Outputs: Out1, Out2


% Preallocate Memory
Cpreallocate=num2cell(zeros(length(Tinput),1));
Toutput=struct('Out1',Cpreallocate,'Out2',Cpreallocate);

% Cycle over the relealizations (samples)
for i=1:length(Tinput)
    Toutput(i).Load   = Tinput(i).Xpar_Radius*Tinput(i).Xpar_Length;

end



