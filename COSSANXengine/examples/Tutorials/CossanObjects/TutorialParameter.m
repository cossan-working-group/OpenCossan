%% TUTORIALPARAMETER
% This tutorial shows the basics on how to define an object of the class
%   Parameter
%
% See Also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@Input
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Pierre~Beaurepaire$ 


%%  Create empty object
Xpar1     = Parameter;

% show summary of the object
display(Xpar1)

%%  Create Parameter object

Xpar2   = Parameter('Sdescription','My Parameter','value',2);

% show summary of the object
display(Xpar2)

%%   Access to the value
Val = Xpar2.value;

Nelement = Xpar2.Nelements;
