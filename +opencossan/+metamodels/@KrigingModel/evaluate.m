function [tableOutput] = evaluate(Xobj,tableInput)
%apply
%
%   This method applies the KrigingModel over an Input object
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/apply@KrigingModel
%
% Copyright~1993-2012, $

import opencossan.common.outputs.*
%%  Check that ResponseSurface has been trained
assert(Xobj.Lcalibrated,'openCOSSAN:PolyharmonicSplines:apply',...
    'PolyharmonicSplines has not been calibrated');

%%  Process input
Minputs = table2array(tableInput); 

%%  Evaluate Kriging Model

Moutput = predictor(Minputs,Xobj.TdaceModel); 

tableOutput=array2table(Moutput,'VariableNames',Xobj.Coutputnames);

return
