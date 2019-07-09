function [XsimData] = apply(Xobj,Pinput)
%apply
%
%   This method applies the NeuralNetwork over an Input object
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/apply@NeuralNetwork
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria$

import opencossan.common.outputs.SimulationData

%%  Check that ResponseSurface has been trained
assert(Xobj.Lcalibrated,'openCOSSAN:NeuralNetwork:apply',...
    'NeuralNetwork has not been calibrated');

%%  Process input
[~,Tinput]=Xobj.prepareInput(Pinput); 

Toutput = evaluate(Xobj,Tinput);

XSimDataInput=SimulationData('Sdescription','Simulation Input from NeuralNetwork',...
    'Tvalues',Tinput);
XSimDataOutput=SimulationData('Sdescription','Simulation Output from NeuralNetwork',...
    'Tvalues',Toutput);

XsimData = XSimDataInput.merge(XSimDataOutput);

return
