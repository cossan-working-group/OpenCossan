%% Tutorial Dataseries
%
% In this tutorial it is shown how to construct a Dataseries, how to add
% data, how to add and chop samples  and how to sum up and subtract two Dataseries
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Dataseries
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Barbara~Goller$
% $revised by Edoardo Patelli 18 March 2014$
%
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

% Reset the random number generator in order to always obtain the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
clear;
close all
clc;
opencossan.OpenCossan.resetRandomNumberGenerator(51125)

%% Construct Dataseries
% Prepare data 
Vfreq = 0:0.1:0.5;
Mdata1 = randn(2,6);
Mdata2 = randn(3,6);

% Construct single Dataseries objects
Xds1 = opencossan.common.Dataseries('Mcoord',Vfreq,'Mdata',Mdata1,'Sindexname','frequency','Sindexunit','Hz');
Xds2 = opencossan.common.Dataseries('Mcoord',Vfreq,'Mdata',Mdata2,'Sindexname','frequency','Sindexunit','Hz');

% The dataseries Xds1 contains 2 realizations (samples) of teh 6 data points
% process
display(Xds1)
% The dataseries Xds2 contains 3 realizations (samples) of teh 6 data points
% process
display(Xds2)

%% Add additional data points 
% It is possible to add additional point to a Dataseries object using the
% method addData

VfreqAdd = [0.7 0.9];  % New frequencies (coordinate) 
MdataAdd = randn(2,2); % New values

Xds1 = Xds1.addData('Mcoord',VfreqAdd,'Mdata',MdataAdd);

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
disp(Xds2.Nsamples)
%Store the data
MdataCheck=Xds2.Mdata;

%% Chop samples
% The method chopsamples allowes to remove specific samples.
% Here we remove sample 2, 4, and 5

Vchopsamples = [2 4 5];
Xds2 = Xds2.chopSamples(Vchopsamples);
% Xds2 has now only 3 samples
disp(Xds2.Nsamples)

%% Validate Chop samples

assert(all(all(MdataCheck([1 3 6],:)==Xds2.Mdata)),...
    'OpenCossan:TutorialDataSeries:WrongChopSamples',...
    'The ChopSamples method has failed');

%% Create Multidimensional Dataseries
myVdata1=rand(1,10);
myVdata2=rand(1,20);
myVdata3=rand(1,5);

myCoord1=1:10;
myCoord2=1:20;
myCoord3=1:5;

Xobj1=opencossan.common.Dataseries('Sdescription','myDescription1','Mcoord',myCoord1,'Vdata',myVdata1,'Sindexname','myIndexName1','Sindexunit','myIndexUnit1');
Xobj2=opencossan.common.Dataseries('Sdescription','myDescription2','Mcoord',myCoord2,'Vdata',myVdata2,'Sindexname','myIndexName2','Sindexunit','myIndexUnit2');
Xobj3=opencossan.common.Dataseries('Sdescription','myDescription2','Mcoord',myCoord3,'Vdata',myVdata3,'Sindexname','myIndexName3','Sindexunit','myIndexUnit3');  

% Concatenate the object
XobjDS=[Xobj1 Xobj2 Xobj3];
% Display
display(XobjDS)

% Access the data of the dataseries vector
% Access the 10th point of the dataseries
XobjDS(1).Vdata(10)
XobjDS(2).Vdata(10)

% Extract the indexunit of the first dataseries
XobjDS(1,1).SindexUnit

% The following 2 commands returns the same values
XobjDS(1,1).Vdata
XobjDS(1).Vdata

% The following 2 commands returns the same values
XobjDS(1,2).Vdata
XobjDS(2).Vdata

%% Close Figures and validate results

% Close figures
close (h1)