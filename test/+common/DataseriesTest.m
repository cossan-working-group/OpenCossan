classdef DataseriesTest < matlab.unittest.TestCase
    % DATASERIESTEST Unit tests for the class common.Dataseries
    % see http://cossan.co.uk/wiki/index.php/@Dataseries
    %
    % @author Jasper Behrensdorf<behrensdorf@irz.uni-hannover.de>
    % @date   15.08.2016
    %
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
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    methods (Test)
        
        %% Test constructor
        function constructorShouldCreateEmptyObject(testCase)
            Xobj=common.Dataseries;
            testCase.assertEqual(class(Xobj),'common.Dataseries');
        end
        
        function constructorShouldSetDescription(testCase)
            description = 'description';
            Xds = common.Dataseries('Sdescription',description);
            testCase.assertEqual(Xds.Sdescription,description);
        end
        
        function constructorShouldSetIndexName(testCase)
            indexName = 'indexName';
            Xds = common.Dataseries('SindexName',indexName);
            testCase.assertEqual(Xds.SindexName,indexName);
        end
        
        function constructorShouldSetIndexUnit(testCase)
            indexUnit = 'indexUnit';
            Xds = common.Dataseries('SindexUnit',indexUnit);
            testCase.assertEqual(Xds.SindexUnit,indexUnit);
        end
        
        function constructorShouldSetVdata(testCase)
            Vdata=rand(1,10);
            Mcoord=1:10;
            Xobj=common.Dataseries('Mcoord',Mcoord,'Vdata',Vdata);
            testCase.assertEqual(Xobj.Vdata,Vdata);
            testCase.assertEqual(Xobj.Mcoord,Mcoord);
        end
        
        function constructorShouldSetMdata(testCase)
            Mdata=rand(2,10);
            Mcoord=1:10;
            Xobj=common.Dataseries('Mcoord',Mcoord,'Mdata',Mdata);
            testCase.assertEqual(Xobj.Vdata,Mdata);
            testCase.assertEqual(Xobj.Mcoord,Mcoord);
        end
        
        function constructorShouldFailWithIncompatibleSizes(testCase)
            testCase.assertError(@()common.Dataseries('Mcoord',1:10,'Mdata',rand(2,20)),...
                'openCOSSAN:Dataseries:Dataseries');
            testCase.assertError(@()common.Dataseries('Mcoord',1:10,'Vdata',rand(1,20)),...
                'openCOSSAN:Dataseries:Dataseries');
        end
        
        %% Test addData
        
        function addDataShouldSetVdata(testCase)
            Vdata = rand(1,10);
            Xds = common.Dataseries();
            Xds = Xds.addData('Vdata',Vdata);
            testCase.assertEqual(Xds.Vdata,Vdata);
            testCase.assertEqual(Xds.Mdata,Vdata);
            testCase.assertEqual(length(Xds.Mcoord),10);
        end
        
        function addDataShouldSetMdata(testCase)
            Mdata = rand(4,10);
            Xds = common.Dataseries();
            Xds = Xds.addData('Mdata',Mdata);
            testCase.assertEqual(Xds.Mdata,Mdata);
            testCase.assertEqual(Xds.Vdata,Mdata);
            testCase.assertEqual(length(Xds.Mcoord),10);
        end
        
        function addDataShouldSetVdataOnArray(testCase)
            assumeFail(testCase); % Skip until issue is resolved
            Vdata = rand(1,10);
            Xds = [common.Dataseries() common.Dataseries()];
            Xds = Xds.addData('Vdata',Vdata);
            testCase.assertEqual(Xds(1).Vdata,Vdata);
            testCase.assertEqual(Xds(2).Vdata,Vdata);
        end
        
        function addDataShouldSetMdataOnArray(testCase)
            assumeFail(testCase); % Skip until issue is resolved
            Mdata = rand(2,10);
            Xds = [common.Dataseries() common.Dataseries()];
            Xds = Xds.addData('Mdata',Mdata);
            testCase.assertEqual(Xds(1).Vdata,Mdata);
            testCase.assertEqual(Xds(2).Vdata,Mdata);
        end
        
        function addDataShouldSetCsamplesOnArray(testCase)
            Rv1 = common.inputs.RandomVariable('Sdistribution','normal','mean',10,'std',1);
            Xds = [common.Dataseries() common.Dataseries()];
            Xds = Xds.addData('Csamples',{Rv1.sample('Nsamples',10) Rv1.sample('Nsamples',5)});
            [N1, N2] = Xds.Nsamples;
            testCase.assertEqual([N1 N2],[10 5]);
            % TODO There is an issue with subsrefDot in later Matlab
            % Versions or on Linux (e.g. on the Jenkins server). So that
            % Xds(1).Nsamples fails. Further investigation needed.
        end
        
        %% Test addSamples
        function addSamples(testCase)
            Xobj1=common.Dataseries('Mdata',rand(8,10));
            Xobj2=common.Dataseries('Mdata',rand(6,20));
            Xobj3=common.Dataseries('Mdata',rand(4,3));
            Xobj123=[Xobj1 Xobj2 Xobj3];
            
            Xobj4=common.Dataseries('Mdata',rand(4,10));
            Xobj5=common.Dataseries('Mdata',rand(4,20));
            Xobj6=common.Dataseries('Mdata',rand(4,3));
            Xobj123add=[Xobj4 Xobj5 Xobj6];
            
            Xobj123=Xobj123.addSamples('Xdataseries',Xobj123add);
            
            testCase.assertEqual([Xobj123.Nsamples],[12 10 8]);
        end
        
        function addSamplesShouldMergeDataseries(testCase)
            Xds1 = common.Dataseries('Mcoord',1:100,'Mdata',rand(2,100));
            Xds2 = common.Dataseries('Mcoord',1:100,'Mdata',rand(2,100));
            Xds1 = Xds1.addSamples('Xdataseries',Xds2);
            testCase.assertEqual(Xds1.Nsamples,4);
        end
        
        function addSamplesShouldFailWithInconsitentSampleSizes(testCase)
            Xds1 = common.Dataseries('Mcoord',1:100,'Mdata',rand(2,100));
            Xds2 = common.Dataseries('Mcoord',1:10,'Mdata',rand(2,10));
            testCase.assertError(@()Xds1.addSamples('Xdataseries',Xds2),...
                'MATLAB:catenate:dimensionMismatch');
            Xds2 = common.Dataseries('Mcoord',1:110,'Mdata',rand(2,110));
            testCase.assertError(@()Xds1.addSamples('Xdataseries',Xds2),...
                'MATLAB:catenate:dimensionMismatch');
        end
        
        %% Test cat
        
        function catShouldConcatenateDataseriesVertical(testCase)
            Mdata1=rand(8,10);
            Mdata2=rand(4,10);
            Mdata3=rand(2,10);
            Mcoord = 1:10;
            Xds1=common.Dataseries('Mcoord',Mcoord,'Mdata',Mdata1);
            Xds2=common.Dataseries('Mcoord',Mcoord,'Mdata',Mdata2);
            Xds3=common.Dataseries('Mcoord',Mcoord,'Mdata',Mdata3);
            
            Xds=cat(1,Xds1,Xds2,Xds3);
            
            testCase.assertEqual(size(Xds.Mdata),[14 10]);
            testCase.assertEqual(Xds.Mdata,[Mdata1;Mdata2;Mdata3]);
        end
        
        function catShouldConcatenateDataseriesHorizontal(testCase)
            Mdata1=rand(8,10);
            Mdata2=rand(8,10);
            Mdata3=rand(8,10);
            Mcoord = 1:10;
            Xds1=common.Dataseries('Mcoord',Mcoord,'Mdata',Mdata1);
            Xds2=common.Dataseries('Mcoord',Mcoord,'Mdata',Mdata2);
            Xds3=common.Dataseries('Mcoord',Mcoord,'Mdata',Mdata3);
            
            Xds=cat(2,Xds1,Xds2,Xds3);            
            testCase.assertEqual(size(Xds),[1 3]);
            testCase.assertEqual([Xds.Mdata],[Mdata1 Mdata2 Mdata3]);
        end
        
        function catShouldFailForInvalidDimension(testCase)
            testCase.assertError(@()cat(3,common.Dataseries(),common.Dataseries()),...
                'openCOSSAN:Dataseries:cat');
        end
        
        function catShouldFailForDifferentNumberOfRows(testCase)
            Xds1=common.Dataseries('Mcoord',1:10,'Mdata',rand(2,10));
            Xds2=common.Dataseries('Mcoord',1:10,'Mdata',rand(4,10));
            
            testCase.assertError(@()cat(2,Xds1,Xds2),'openCOSSAN:Dataseries:horzcat');
        end
        
    end
end

