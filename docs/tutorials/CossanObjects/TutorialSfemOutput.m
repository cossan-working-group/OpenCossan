% Tutorial for the SfemOutput Object
% This tutorial shows how to create and use a SfemOutput object
close all
clear
clc;
%% load the previously calculated Sfem object 

load ([opencossan.OpenCossan.getRoot '/examples/Tutorials/CossanObjects/Xsfemout']);

%% using getResponse method with the SfemOutput Object 
%
% Note: SfemOutput object is created as a result of an SFEM analysis
%       it stores all the DOF info + mean & std & cov of the displacement
%       vector. One can access to these data, by asking either for specific
%       DOFs or for the max. response

Xsfemout = getResponse(Xsfemout,'Sresponse','max');
display(Xsfemout);

Xsfemout = getResponse(Xsfemout,'Sresponse','specific','MresponseDOFs',[150 3;4266 3]);
display(Xsfemout);

%% Validate results

% reference results are as follows
referenceMean = 0.8980;
referenceStd  = 0.0881;

assert(abs(Xsfemout.Vresponsemean(1)-referenceMean)<1e-4,'CossanX:Tutorials:TutorialPC', ...
      'Reference mean value does not match.')
  
assert(abs(Xsfemout.Vresponsestd(1)-referenceStd)<1e-4,'CossanX:Tutorials:TutorialPC', ...
      'Reference Std value does not match.')

%% using prepareReport method with the SfemOutput Object 
%
% Note: it is also possible to create a report (txt file) with all info
% related to the analysis using this method. But note that only the
% statistics of the responses which is inquired with the getResponse method
% will be reported in this file
%

Xsfemout.prepareReport;

% to clean up the created result file 
delete('*.txt');

