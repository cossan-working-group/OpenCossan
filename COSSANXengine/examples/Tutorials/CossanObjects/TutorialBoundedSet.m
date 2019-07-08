%% TUTORIALBOUNDEDSET
% This tutorial shows how to define an object of the class BoundedSet
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@BoundedSet
%
% $Author: Marco-de-Angelis$ 

%%  Create Interval object
Xint1  = Interval('Sdescription','My interval variable',...
    'lowerBound',0,'upperBound',3);

% The same interval can be defined in terms of center and raidus
Xint2  = Interval('Sdescription','My interval variable',...
    'center',0,'radius',1);

% An interval can also be defined from a data set where in case of more
% than one interval correlation can be considered
Xint3 = Interval('Sdescription','Interval defined from a data set',...
    'Vdata',[0,0.1,0.5,0.7,0.97,0.95,0.96,0.74]);
%%   Create a Bounded Set of independent intervals

XbSet = BoundedSet('Sdescription','My interval set',...
    'CXmembers',{Xint1,Xint2,Xint3},...
    'CSmembers',{'Xint1','Xint2','Xint3'}); 
display(XbSet)


%% Create a Bounded Set of two correlated intervals

Xint4 = Interval('Sdescription','Interval defined from a data set',...
    'Vdata',[0,0.3,0.4,0.6,0.4,0.9,0.2,0.88]);

XbSet2 = BoundedSet('Sdescription','My set of correlated intervals',...
    'CXmembers',{Xint3,Xint4},...
    'CSmembers',{'Xint3','Xint4'},...
    'Scorrelationtype','ellipse'); 
display(XbSet2)

%% Sample from the Bounded Set

Xs=XbSet.sample('Nsamples',10);
display(Xs)
