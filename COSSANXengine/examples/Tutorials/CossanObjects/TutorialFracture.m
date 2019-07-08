%*********************************************************************
%
%   Example on how to use Fatigue and Fracture objects
%   Fracture is a subclass of Mio and shares various attributes and methods
%   with the mother class
%
%
%   This tutorial shows the usage of the methods in the class Fracture. 
%
%
%**************************************************************************

%% Data related to Fracture object

% Definition of the Fracture object. It takes as an inpout the outputs
% of the evaluator which determines the stress intensity factor, The
% outputs of this is <0 if fracture does not occur, and >0 if fracture has
% occured
Xf = Fracture('Liomatrix',false,...
    'Cinputnames',{'sif','Kic'},... % Define the inputs
    'Spath','./',...
    'Sscript','for j=1:length(Tinput), Toutput(j).fract= Tinput(j).sif-Tinput(j).Kic; end', ...
    'Coutputnames',{'fract'},...
    'Liostructure',true,...
    'Lfunction',false);


%% evaluate
% creation of a structure

Tstruct(1).sif = 30e6;
Tstruct(1).Kic = 20e6;
% 
Tstruct(2).sif = 30e6;
Tstruct(2).Kic = 40e6;

% evaluate
resu = Xf.evaluate(Tstruct);
