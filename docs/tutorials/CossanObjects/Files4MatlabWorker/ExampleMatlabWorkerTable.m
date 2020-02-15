function TableOutput = ExampleMioTable(TableInput)
% Example of Mio Function. 
%
% Input and output passed as Matlab Table 
% Required Inputs RV_1, RV_2
% Outputs: Out1, Out2

Out1   = TableInput.RV_2;
Out2   = TableInput.RV_1;

TableOutput=array2table([Out1 Out2],'VariableNames',{'Out1' 'Out2'});
