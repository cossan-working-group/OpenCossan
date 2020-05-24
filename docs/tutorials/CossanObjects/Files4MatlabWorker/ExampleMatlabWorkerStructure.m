function Toutput = ExampleMatlabWorkerStructure(Tinput)
% Example of Mio Function
% Input and output passed as Structure
% Required Inputs RV_1, RV_2
% Outputs: Out1, Out2


% Preallocate Memory
Cpreallocate=num2cell(zeros(length(Tinput),1));
Toutput=struct('Out1',Cpreallocate,'Out2',Cpreallocate);

% Cycle over the relealizations (samples)
for i=1:length(Tinput)
    Toutput(i).Out1   = Tinput(i).RV_2;
    Toutput(i).Out2   = Tinput(i).RV_1;
end



