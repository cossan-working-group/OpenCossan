%{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.
    
    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}
%
%% Tutorial Dataseries
%
% In this tutorial it is shown how to construct a Dataseries, how to add
% data, how to add and chop samples  and how to sum up and subtract two Dataseries
%
% For more information, see <a href="https://cossan.co.uk">COSSAN website</a> 
% Copyright (C) 2006-2018 COSSAN WORKING GROUP 
% 
% See also: https://cossan.co.uk/wiki/index.php/@Dataseries


% Reset the random number generator in order to always obtain the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)

%% Construct Dataseries
% Prepare data 
Vfreq = 0:0.1:0.5;
Mdata1 = randn(2,6);
Mdata2 = randn(3,6);

% Construct single Dataseries objects
Xds1 = Dataseries('Mcoord',Vfreq,'Mdata',Mdata1,'Sindexname','frequency','Sindexunit','Hz');
Xds2 = Dataseries('Mcoord',Vfreq,'Mdata',Mdata2,'Sindexname','frequency','Sindexunit','Hz');

% The dataseries Xds1 contains 2 realizations (samples) of the 6 data points
% process
display(Xds1)
% The dataseries Xds2 contains 3 realizations (samples) of the 6 data points
% process
display(Xds2)

%% Add additional data points 
% It is possible to add additional point to a Dataseries object using the
% method addData

VfreqAdd = [0.7 0.9];  % New frequencies (coordinate) 
MdataAdd = randn(2,2); % New values

Xds1 = addData(Xds1,'Mcoord',VfreqAdd,'Mdata',MdataAdd);

% The resulting Dataseries should have 8 data points and 2 samples
display(Xds1)

% Plot figure
h1=Xds1.plot;

%% Add samples to dataseries
% It is possible to add samples to a dataseries object using the method
% addSamples. The added samples need to have the same length of the
% original points

% Add 3 samples to Xds2
MsamplesAdd = randn(3,6);
Xds2 = Xds2.addSamples('Mdata',MsamplesAdd);

% Dataseries Xds2 has now 6 samples
disp(size(Xds2,1))
%Store the data
MdataCheck=vertcat(Xds2.Vdata);

%% Chop samples
% The method chopsamples allowes to remove specific samples.
% Here we remove sample 2, 4, and 5

Vchopsamples = [2 4 5];
Xds2 = Xds2.chopSamples(Vchopsamples);
% Xds2 has now only 3 samples
disp(size(Xds2,1))

%% Validate Chop samples

assert(all(all(MdataCheck([1 3 6],:)==vertcat(Xds2(:).Vdata))),...
    'OpenCossan:TutorialDataSeries:WrongChopSamples',...
    'The ChopSamples method has failed');

%% Create Multidimensional Dataseries (column)
myVdata1=rand(1,10);
myVdata2=rand(1,20);
myVdata3=rand(1,5);

myCoord1=1:10;
myCoord2=1:20;
myCoord3=1:5;

Xobj1=Dataseries('Sdescription','myDescription1','Mcoord',myCoord1,...
    'Vdata',myVdata1,'Sindexname','myIndexName1','Sindexunit','myIndexUnit1');
Xobj2=Dataseries('Sdescription','myDescription2','Mcoord',myCoord2,...
    'Vdata',myVdata2,'Sindexname','myIndexName2','Sindexunit','myIndexUnit2');
Xobj3=Dataseries('Sdescription','myDescription2','Mcoord',myCoord3,...
    'Vdata',myVdata3,'Sindexname','myIndexName3','Sindexunit','myIndexUnit3');  

% Concatenate the object
XobjDS=[Xobj1 Xobj2 Xobj3];
% Display
display(XobjDS)

% Access the data of the dataseries vector
% Access the 10th point of the dataseries
XobjDS(1).Vdata(10)
XobjDS(2).Vdata(10)

% Extract the indexunit of the first dataseries
XobjDS(1).Xcoord.CSindexUnit

% The following 2 commands returns the same values
XobjDS(1,1).Vdata
XobjDS(1).Vdata

% The following 2 commands returns the same values
XobjDS(1,2).Vdata
XobjDS(2).Vdata

%% Create Multidimensional Dataseries (row)
myCoord1=1:100;
T = whos('myCoord1');
byte_coord = T.bytes;
myVdata1=rand(1,100);
T = whos('myVdata1');
byte_data = T.bytes;

% Row Dataseries array, not sharing the coordinate object
for i=1:1000
    myCoord1=1:100;
    myVdata1=rand(1,100);
    Xds_nonSharedCoord(i)=Dataseries('Sdescription','myDescription1','Mcoord',myCoord1,...
        'Vdata',myVdata1,'Sindexname','myIndexName1','Sindexunit','myIndexUnit1');
end
T_nonShared = whos('Xds_nonSharedCoord');

% coordinate is an handle object, a pointer to the original coordinate 
% object is added to every Dataseries
Xcoord = Coordinates('Mcoord',myCoord1,...
    'Sindexname','myIndexName1','Sindexunit','myIndexUnit1');
for i=1:1000
    myCoord1=1:100;
    myVdata1=rand(1,100);
    Xds_sharedCoord(i)=Dataseries('Sdescription','myDescription1','Xcoord',Xcoord,'Vdata',myVdata1);
end
T_shared = whos('Xds_sharedCoord');

% change one entry in coordinate
Xds_nonSharedCoord(1).Xcoord.Mcoord(end) = 200;
all(cellfun(@(x)x.Mcoord(end), {Xds_nonSharedCoord(:).Xcoord})==200)
Xds_sharedCoord(1).Xcoord.Mcoord(end) = 200;
all(cellfun(@(x)x.Mcoord(end), {Xds_sharedCoord(:).Xcoord})==200)

%% Check vertcat and horzcat




%% Close Figures and validate results

% Close figures
close (h1)