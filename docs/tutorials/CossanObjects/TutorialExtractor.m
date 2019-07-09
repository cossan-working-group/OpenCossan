%% Tutorial Extractor
% This tutorial shows how to create an Extractor object and to use the
% extract method. For this purpose, a dummy textfile called 'outputfile.txt'
% is used.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Extractor
%

%  Copyright 1993-2015, COSSAN Working Group
%  University of Liverpool, UK

clear;
close all
clc;
%% Create extractor
SpathName=fullfile(opencossan.OpenCossan.getRoot,'examples','Tutorials','CossanObjects','Connector','NASTRAN');

% This response reads two output from the row number 3 and column 1
% The field Nrepear is used to describe the number of repetitions. 
Xresp1 = opencossan.workers.ascii.Response('Sname', 'Out1','Sfieldformat', '%d%*', ...
             'Ncolnum',1,'Nrownum',3,'Nrepeat',2);

Xe=opencossan.workers.ascii.Extractor('Sdescription','Extractor for the tutorial', ...
             'Sworkingdirectory',SpathName, ...
             'Srelativepath','./', ... % this is the directory where the input and output are contained
             'Sfile','outputfile.txt',...
             'Xresponse',Xresp1);
           
%% Add responses 
% The second response extracts 4 numbers from the line that is 2 rows below
% the last extracted number of the previus response. 
Xresp2 = opencossan.workers.ascii.Response('Sname','Out2','Sfieldformat','%3f%3f%3f%3f%*','Svarname','Out1','Nrownum',2);
Xresp3 = opencossan.workers.ascii.Response('Sname','Out3','Sfieldformat','%3f','Nrownum',53);
Xe=add(Xe,'Xresponse',Xresp2);      
Xe=add(Xe,'Xresponse',Xresp3);   

display(Xe)

%% use REMOVE method to remove unnecessary responses
Xe=remove(Xe,'Out3'); 
display(Xe)

%% now the extractor contains only 1 response.
Tout=extract(Xe) %#ok<*NOPTS>

% Validate output
Vreference= [10 11 12 13];
assert(max(abs(Tout.Out2.Vdata-Vreference))<eps,...
    'CossanX:Tutorials:TutorialEvaluator','Reference Solution does not match.')


%% access to the properties to edit response
Xe.Xresponse(2).Sfieldformat = '%3f';
Tout2=extract(Xe)

% Validate output
Vreference= 10;
assert(abs(Tout2.Out2-Vreference)<eps,...
    'CossanX:Tutorials:TutorialEvaluator','Reference Solution does not match.')


