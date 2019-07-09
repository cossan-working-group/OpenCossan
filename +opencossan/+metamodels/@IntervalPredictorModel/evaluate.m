function tableOutput = evaluate(Xobj,Minputs)
%Evaluate
%
%   This method applies the ResponseSurface over an Input object
%
%
% See Also:
% http://cossan.co.uk/wiki/index.php/apply@IntervalPredicorModel
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria$

%%  Check that ResponseSurface has been trained
import opencossan.common.outputs.SimulationData

%%  Evaluate response surface
Minputs=table2array(Minputs);

Minputs=Minputs./Xobj.rescaleInputs;
MD      = x2fx(Minputs,Xobj.Mexponents);

Mrs=zeros(size(Minputs,1),length(Xobj.OutputNames));

assert(length(Xobj.OutputNames)==1,'Currently only one output name is supported')

MrsUpper=0.5*(MD-abs(MD))*Xobj.PLower+0.5*(MD+abs(MD))*Xobj.PUpper;
MrsLower=0.5*(MD+abs(MD))*Xobj.PLower+0.5*(MD-abs(MD))*Xobj.PUpper;

if strcmpi(Xobj.Bound,'lower')
    Mrs=MrsLower;
elseif strcmpi(Xobj.Bound,'upper')
    Mrs=MrsUpper;
else
    error('Unknown Bound Error')
end

tableOutput=array2table(Mrs,'VariableNames',Xobj.OutputNames);

return
