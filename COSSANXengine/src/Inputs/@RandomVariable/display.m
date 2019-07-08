function display(Xobj)
%DISPLAY   Displays the information related to random variable
%  DISPLAY(rv1) prints the name, distribution type, mean value, standart
%               deviation and coefficient of variation for the specified
%               random variable
%
%  Usage:       display(Xobj)
%
% =========================================================================
% COSSAN - Computational Stochastic Simulation Analysis
% University of Innsbruck, Austria, European Union
% Copyright 1993-2010
% =========================================================================

%  Revised by EP

%%   Output to Screen
%  Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([' RandomVariable Object - Description: ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',2);

if strcmp(Xobj.Sdistribution,'null') || isempty(Xobj.Sdistribution)
    OpenCossan.cossanDisp('* Empty object ',1);
    return
end
OpenCossan.cossanDisp(['     Distribution: ' Xobj.Sdistribution],1);
if ~isnan(Xobj.mean) && ~isinf(Xobj.mean)
    OpenCossan.cossanDisp(['     Mean = ' num2str(Xobj.mean)],2);
end

if ~isnan(Xobj.std) && ~isinf(Xobj.std)
    OpenCossan.cossanDisp(['     Std = '     num2str(Xobj.std)],2);
end

if ~isnan(Xobj.CoV)
    OpenCossan.cossanDisp(['     CoV = '    num2str(Xobj.CoV)],2);
end

for i=1:size(Xobj.Cpar,1)
    if ~isempty(Xobj.Cpar{i,1})
        OpenCossan.cossanDisp(['     ' Xobj.Cpar{i,1} ' = ' num2str(Xobj.Cpar{i,2})],2);
    end
end

if ~isempty(Xobj.lowerBound)
    OpenCossan.cossanDisp(['     Lower limit = ' num2str(Xobj.lowerBound)],2);
end
if ~isempty(Xobj.upperBound)
    OpenCossan.cossanDisp(['     Upper limit = ' num2str(Xobj.upperBound)],2);
end

end

