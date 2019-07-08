%% Tutorial for the TableExtractor
%
% This tutorial shows how a time- or frequency dependent output (i.e.
% table-valued output) is extracted from a ASCII result file.
% 
% The files needs to have one of the following extension 
%
%   .txt, .dat, .csv:  for delimited text file.
%
%   .xls, .xlsx, .xlsb, .xlsm, .xltm, .xltx, .ods:  for Spreadsheet file.
% 
% See Also: http://cossan.co.uk/wiki/index.php/@TableExtractor
%
%
% $Copyright~2006-2018,~COSSAN~Working~Group$
% $Author: Edoardo-Patelli$ 

% Reset the random number generator in order to always obtain the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)


if verLessThan('matlab','R2016a')
     Tver=ver('matlab');
     error('OpenCOSSAN:TutorialTableExtractor:OlderMatlabVersion',...
     'A Matlab version greater than R2016a is require. Your Matlab version is %s',Tver.Release);
end

%% Construct an empty object
Xte=TableExtractor;
% show summary of the object
display(Xte)

%% Construct a TableObject with Output names 
% Define a output name
Xte=TableExtractor('Soutputname','test','Sfile','dummyFileName'); 
display(Xte)
% Define output names
Xte=TableExtractor('Coutputnames',{'test1', 'test2'},'Sfile','dummyFileName');
display(Xte)

% The following exames are using a table stored in Connector CATHENA
SrelativePath=fullfile(fileparts(which('TutorialTableExtractor')),'Connector','CATHENA');

% It is possible to skip a predifined number of lines (for the headers)
% using the "Nheaderlines" or skip all the first lines starting with a
% predifined identifier "Sheaderidentifier"

Xte=TableExtractor('Coutputnames',{'OutCol5'}, ...
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

[Tout, LsuccessfullExtract]=Xte.extract;

assert(LsuccessfullExtract,'OpenCOSSAN:TutorialTableExtractor:WrongFlag',...
    'LsuccessfullExtract should be true')

% Plot the extracted results
f1=figure,
plot(Tout.OutCol5.Mcoord,[Tout.OutCol5.Vdata; Tout.OutCol3.Vdata])

%
close(f1)

%% Extract 1 variable spanning multiple columns 

% This should fail! Data can only be stored in a vector form. Coordinates
% can also be multidimensionals. 
Xte=TableExtractor('Coutputnames',{'MultiColumns'}, ...
    'Srelativepath',SrelativePath, ... % relative path to the Sworkingdirectory where the input file is 
    'Sfile','edwards_press.dat',...  
    'CcolumnPosition',{[2 5]}, ...
    'Sheaderidentifier','#'); 

[Tout, LsuccessfullExtract]=Xte.extract;

disp(LsuccessfullExtract)
Tout.MultiColumns

assert(~LsuccessfullExtract,'OpenCOSSAN:TutorialTableExtractor:WrongFlag',...
    'LsuccessfullExtract should be false')

%% Extract 1 variable with coordinate
Xte=TableExtractor('Coutputnames',{'OutColMultiColumns'}, ...
    'NcoordinateColumn',1, ... % Define the column containing the coordinate 
    'Srelativepath',SrelativePath, ... % relative path to the Sworkingdirectory where the input file is 
    'Sfile','edwards_press.dat',...  
    'CcolumnPosition',{[2]}, ...
    'Sheaderidentifier','#'); 

[Tout, LsuccessfullExtract]=Xte.extract;
disp(LsuccessfullExtract)
Tout.OutColMultiColumns

assert(LsuccessfullExtract,'OpenCOSSAN:TutorialTableExtractor:WrongFlag',...
    'LsuccessfullExtract should be true')

%% Extract 2 variables spanning specified lines with coordinate
Xte=TableExtractor('Coutputnames',{'OutColMultiColumns','OutCol4'}, ...
    'NcoordinateColumn',1, ... % Define the column containing the coordinate 
    'Srelativepath',SrelativePath, ... % relative path to the Sworkingdirectory where the input file is 
    'Sfile','edwards_press.dat',...  
    'CcolumnPosition',{5, 4}, ...
    'ClinePosition',{[1:10], [11:15]}, ...
    'Sheaderidentifier','#'); 

[Tout, LsuccessfullExtract]=Xte.extract;
disp(LsuccessfullExtract)
Tout.OutColMultiColumns.Vdata
Tout.OutCol4.Vdata
Tout.OutCol4.Mcoord

%% Example using OpenSees results

%% Extract 1 variable spanning multiple columns and specified lines with coordinate
SrelativePath=fullfile(fileparts(which('TutorialTableExtractor')),'Connector','OpenSees');

Xte1=TableExtractor('Coutputnames',{'disp_history1','disp_history2','disp_history3'}, ...
    'NcoordinateColumn',1, ... % Define the column containing the coordinate 
    'Srelativepath',SrelativePath, ... % relative path to the Sworkingdirectory where the input file is 
    'Sfile','th_Node_DefoShape_Dsp.out.txt',...  
    'CcolumnPosition',{2,3,4}, ...
    'Sdelimiter',' '); 

[Tout, LsuccessfullExtract]=Xte1.extract;

% Additional example
Xte2=TableExtractor('Coutputnames',{'damper_force_history1','damper_force_history2','damper_force_history3'}, ...
    'NcoordinateColumn',1, ... % Define the column containing the coordinate 
    'Srelativepath',SrelativePath, ... % relative path to the Sworkingdirectory where the input file is 
    'Sfile','Truss_Forc.out.txt',...  
    'CcolumnPosition',{2,3,4}); 

[Tout, LsuccessfullExtract]=Xte2.extract;

Tout.damper_force_history1.plot

%% Advanced features
% It is possible to pass some advanced feautures but usually they are not
% required
% When reading delimited text files, you can specify any of the name-value
% pair arguments listed here: Sformat, Sdelimiter,  Also, if you specify the 'Format' name-value
% pair argument, you can specify any of the name-value pair arguments
% accepted by the textscan function.   
%
%  Format of the columns in the file, specified as the comma-separated pair
%  consisting of 'Format' and a string of one or more conversion
%  specifiers. The conversion specifiers are the same as the specifiers
%  accepted by the textscan function.  
%
% Specifying the format can significantly improve speed for some large
% files. If you do not specify a value for Format, then readtable uses %q
% to interpret nonnumeric columns. The %q specifier reads a string and
% omits double quotation marks (") if appropriate.   
% By default, the variables created are either double or cell array of
% strings, depending on the data. If the entire column is numeric,
% variables are imported asdouble. If any element in a column is not
% numeric, the variables are imported as cell arrays of strings.   

Xte2=TableExtractor('Coutputnames',{'damper_force_history1','damper_force_history2','damper_force_history3'}, ...
    'NcoordinateColumn',1, ... % Define the column containing the coordinate 
    'Srelativepath',SrelativePath, ... % relative path to the Sworkingdirectory where the input file is 
    'Sfile','Truss_Forc.out.txt',...  
    'CcolumnPosition',{2,3,4}, ...
    'Sdelimiter',' ');

[Tout, LsuccessfullExtract]=Xte2.extract;
