%% TUTORIALINTERVAL
% This tutorial shows how to use an object of class Interval
% The intervals are used to characterise epistemic uncertainty. They are a
% subclass of Parameter 
%
% See Also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@Interval
%
% $Copyright~1993-2015,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author:~Edoardo Patelli$ 
clear
close all
clc;

%%  Create empty object
Xint1     = opencossan.intervals.Interval;
% show summary of the object
display(Xint1)

%%  Create Parameter object
% The Interval Objects are defined by their bounds or providing the central
% value and the radius. 

Xint2   = opencossan.intervals.Interval('description','My Interval','lowerBound',2,'upperBound',5);
% show summary of the object
display(Xint2)
%   Access to the value
Val = Xint2.Value
Nelement = Xint2.Nelements

%% Using radius and centre
Xint3   = opencossan.intervals.Interval('description','My Interval','radius',2,'centre',3);
% show summary of the object
display(Xint3)
radius=Xint3.radius
centre=Xint3.centre