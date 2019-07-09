function tableOutput = evaluate(Xobj,Minputs)
%Evaluate
%
%   This method applies the ResponseSurface over an Input object
%
%
% See Also: http://cossan.co.uk/wiki/index.php/evaluate@ResponseSurface
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria$

%%  Check that ResponseSurface has been trained
import opencossan.common.outputs.SimulationData

%%  Evaluate response surface
Minputs=table2array(Minputs);

switch lower(Xobj.Stype),
    case {'linear'}
        MD      = x2fx(Minputs,'linear');
    case {'interaction'}
        MD      = x2fx(Minputs,'interaction');
    case {'purequadratic'}
        MD      = x2fx(Minputs,'purequadratic');
    case {'quadratic'}
        MD      = x2fx(Minputs,'quadratic');
    case {'custom'}
        MD      = x2fx(Minputs,Xobj.Mexponents);
    otherwise
        error('openCOSSAN:ResponseSurface:apply',...
            'Response surface type %s not valid', Xobj.Stype)
end

% Explanation????
Mrs=zeros(size(Minputs,1),length(Xobj.OutputNames));

for iresponse = 1:length(Xobj.OutputNames)
    Mrs(:,iresponse)     = MD * Xobj.CVCoefficients{iresponse};
end

tableOutput=array2table(Mrs,'VariableNames',Xobj.OutputNames);

return
