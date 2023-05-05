function tableOutput = evaluate(obj, inputs)
%Evaluate
%
%   This method applies the ResponseSurface over an Input object
%
%
% See Also:
% http://cossan.co.uk/wiki/index.php/apply@IntervalPredicorModel
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria$

%%  Evaluate response surface
inputs = table2array(inputs);

inputs = inputs./obj.RescaleInputs;
MD = x2fx(inputs,obj.Exponents);

assert(length(obj.OutputNames) == 1, ...
    'Currently only one output name is supported')

if strcmpi(obj.Bound,'lower')
    Mrs = 0.5*(MD+abs(MD))*obj.PLower+0.5*(MD-abs(MD))*obj.PUpper;
elseif strcmpi(obj.Bound,'upper')
    Mrs = 0.5*(MD-abs(MD))*obj.PLower+0.5*(MD+abs(MD))*obj.PUpper;
end

tableOutput = array2table(Mrs, 'VariableNames', obj.OutputNames);

return