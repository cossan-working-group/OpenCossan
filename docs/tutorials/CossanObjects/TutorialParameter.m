%% TUTORIALPARAMETER
% This tutorial shows the basics on how to define an object of the class
%   Parameter
%
% See Also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@Input
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Pierre~Beaurepaire$ 
% 
clear
close all
clc;
% Cimports=strcat(OpenCossan.CpackageNames,'.*');
% 
% %eval(['import(''' Cimports{14} ''')'])
% %PackageList=import(Cimports{14});
% 
% for i =1:length(Cimports)
%     a = sprintf('%s(%s{%d})','import','Cimports',i);
%     eval(a)
% end
import common.inputs.*

%%  Create empty object
Xpar1     = opencossan.common.inputs.Parameter;

% show summary of the object
display(Xpar1)

%%  Create Parameter object

Xpar2   = opencossan.common.inputs.Parameter('description','My Parameter','value',2);

% show summary of the object
display(Xpar2)

%%   Access to the value
Val = Xpar2.Value;

Nelement = Xpar2.Nelements;
