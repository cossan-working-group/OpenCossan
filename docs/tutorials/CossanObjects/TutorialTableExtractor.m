%% Tutorial for the TableExtractor
%
% This tutorial shows how a time- or frequency dependent output (i.e.
% table-valued output) is extracted from a ASCII result file
% 
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@TableExtractor
%
%
% $Copyright~2006-2016,~COSSAN~Working~Group$
% $Author: Edoardo-Patelli$ 
close all
clear
clc;
% Reset the random number generator in order to always obtain the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(51125)

%% Construct an empty object
Xte=opencossan.workers.ascii.TableExtractor;
% show summary of the object
display(Xte)

%% Construct a TableObject with Output names 
% Define a output name
Xte=opencossan.workers.ascii.TableExtractor('Soutputname','test','Sfile','dummyFileName'); 
display(Xte)
% Define output names
Xte=opencossan.workers.ascii.TableExtractor('Coutputnames',{'test1', 'test2'},'Sfile','dummyFileName');
display(Xte)

% The following exames are using a table stored in Connector CATHENA
SrelativePath=fullfile('Connector','CATHENA');

% It is possible to skip a predifined number of lines (for the headers)
% using the "Nheaderlines" or skip all the first lines starting with a
% predifined identifier "Sheaderidentifier"

Xte=opencossan.workers.ascii.TableExtractor('Coutputnames',{'OutCol5'}, ...
    'Srelativepath',SrelativePath, ... % relative path to the Sworkingdirectory where the input file is 
    'Sfile','edwards_press.dat',...  
    'CcolumnPosition',{5}, ...
    'Sheaderidentifier','#'); 
display(Xte)

%% Test extractor
% The extract method returns a structure with the extracted quantities
% stored in a Dataseries object
[Tout, LsuccessfullExtract]=Xte.extract;

assert(LsuccessfullExtract,'OpenCOSSAN:TutorialTableExtractor:WrongFlag',...
    'LsuccessfullExtract should be TRUE')
disp('LsuccessfullExtract: TRUE')
Tout.OutCol5

XteNofile=TableExtractor('Coutputnames',{'OutCol5'}, ...
    'Srelativepath',SrelativePath, ... % relative path to the Sworkingdirectory where the input file is 
    'Sfile','NoFile.dat',...  
    'CcolumnPosition',{5}, ...
    'Sheaderidentifier','#'); 

% If the file does not exist the extract method returns NaN
[Tout, LsuccessfullExtract]=XteNofile.extract;

assert(~LsuccessfullExtract,'OpenCOSSAN:TutorialTableExtractor:WrongFlag',...
    'LsuccessfullExtract should be false')
disp(['LsuccessfullExtract: FALSE, Tout.OutCol5=',sprintf('%f',Tout.OutCol5)])


%% Extract 2 variables from specified columns 
Xte=TableExtractor('Coutputnames',{'OutCol5' 'OutCol3'}, ...
    'Srelativepath',SrelativePath, ... % relative path to the Sworkingdirectory where the input file is 
    'Sfile','edwards_press.dat',...  
    'CcolumnPosition',{5 3}, ...
    'Sheaderidentifier','#'); 

[Tout, ~]=Xte.extract;

% Plot the extracted results
f1=figure,
plot(Tout.OutCol5.Mcoord,[Tout.OutCol5.Vdata; Tout.OutCol3.Vdata])

%
close(f1)

%% Extract 1 variable spanning multiple columns 
Xte=TableExtractor('Coutputnames',{'OutColMultiColumns'}, ...
    'Srelativepath',SrelativePath, ... % relative path to the Sworkingdirectory where the input file is 
    'Sfile','edwards_press.dat',...  
    'CcolumnPosition',{[2 5]}, ...
    'Sheaderidentifier','#'); 

[Tout, LsuccessfullExtract]=Xte.extract;

disp(LsuccessfullExtract)
Tout.OutColMultiColumns

%% Extract 1 variable spanning multiple columns with coordinate
Xte=TableExtractor('Coutputnames',{'OutColMultiColumns'}, ...
    'NcoordinateColumn',1, ... % Define the column containing the coordinate 
    'Srelativepath',SrelativePath, ... % relative path to the Sworkingdirectory where the input file is 
    'Sfile','edwards_press.dat',...  
    'CcolumnPosition',{[2 5]}, ...
    'Sheaderidentifier','#'); 

[Tout, LsuccessfullExtract]=Xte.extract;
disp(LsuccessfullExtract)
Tout.OutColMultiColumns

%% Extract 1 variable spanning multiple columns and specified lines with coordinate
Xte=TableExtractor('Coutputnames',{'OutColMultiColumns','OutCol4'}, ...
    'NcoordinateColumn',1, ... % Define the column containing the coordinate 
    'Srelativepath',SrelativePath, ... % relative path to the Sworkingdirectory where the input file is 
    'Sfile','edwards_press.dat',...  
    'CcolumnPosition',{[2 5], 4}, ...
    'ClinePosition',{[1:10], [11:15]}, ...
    'Sheaderidentifier','#'); 

[Tout, LsuccessfullExtract]=Xte.extract;
disp(LsuccessfullExtract)
Tout.OutColMultiColumns.Mdata
Tout.OutCol4.Mdata
Tout.OutCol4.Mcoord

