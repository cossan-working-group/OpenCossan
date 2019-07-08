%*********************************************************************
%
%   Example on how to use CrackGrowth objects
%   CrackGrowth is a subclass of Mio and shares various attributes and methods
%   with the mother class
%   This tutorial shows the usage of the methods in the class CrackGrowth. 
%
%**************************************************************************

% Definition of the CrackGrowth object. It takes as an inpout the outputs
% of the evaluator which determines the stress intensity factor, The
% outputs of this objects are the variations of the crack length over one
% cycle

Sscript2 = [...
'Cdummy=num2cell(zeros(length(Tinput),1));'...
'Toutput=struct(''dadn'',Cdummy);'...
'for i=1:length(Tinput),   Toutput(i).dadn = Tinput.C*(Tinput(i).sif)^ Tinput(i).m;end'...
];

Xcg = CrackGrowth('Liostructure',true,'Liomatrix',false,...
    'Cinputnames',{'sif','m','C'},... % Define the inputs
    'Sscript',Sscript2,... % external file
    'Coutputnames',{'dadn'});

%% evaluate
% creation of a structure
Tstruct = struct;
Tstruct.sif =30e6;
Tstruct.m =2;
Tstruct.C =2e-23;
% evaluate
resu = Xcg.evaluate(Tstruct);

%% reference solution
OpenCossan.cossanDisp(['Error in the approximation: ' num2str(100*(resu-1.8000e-08)/1.8000e-08) '%'])



