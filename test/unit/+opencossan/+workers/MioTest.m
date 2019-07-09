classdef MioTest < matlab.unittest.TestCase
    % MIOTEST Unit tests for the class
    % opencossan.workers.Mio
    % see http://cossan.co.uk/wiki/index.php/@Mio
    %
    % @author Jasper Behrensdorf<behrensdorf@irz.uni-hannover.de>
    % @author Edoardo Patelli<edoardo.patelli@liverpool.ac.uk>
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
    
    properties
        Xin;
        workingDirectoryFunctions = fullfile(opencossan.OpenCossan.getRoot,'test','data','workers','Mio','functions');
        workingDirectoryFunctionsDeployed = fullfile(opencossan.OpenCossan.getRoot,'test','data','workers','Mio','functionsDeployed');
        workingDirectoryScripts = fullfile(opencossan.OpenCossan.getRoot,'test','data','workers','Mio','scripts');
        isdeployedDirectory = fullfile(opencossan.OpenCossan.getRoot,'test','data','workers','Mio','isdeployed');
    end
    
    methods (TestClassSetup)
        function skip(testCase)
            testCase.assumeFail();
        end
    end
    
    methods (TestMethodSetup)
        function createInput(testCase)
            Xrv1 = opencossan.common.inputs.RandomVariable('Sdistribution','uniform','par1',9,'par2',11);
            Xrv2 = opencossan.common.inputs.RandomVariable('Sdistribution','uniform','par1',14,'par2',16);
            Xrvs = opencossan.common.inputs.RandomVariableSet('CSMembers',{'Xrv1','Xrv2'},'CXmembers',{Xrv1,Xrv2});
            testCase.Xin = opencossan.common.inputs.Input('CXmembers',{Xrvs},'CSmembers',{'Xrvs'});
        end
    end
    
    methods (Test)
        %% constructor
        function constructorMinimal(testCase)
            Xm = opencossan.workers.Mio('InputNames',{'x1','x2'},'OutputNames',{'out1','out2'},...
                'Script','Toutput.out1=Tinput.x1;Toutput.out2=-Tinput.x2;');
            
            testCase.assertEqual(Xm.InputNames,{'x1','x2'});
            testCase.assertEqual(Xm.OutputNames,{'out1','out2'});
            testCase.assertEqual(Xm.Script,'Toutput.out1=Tinput.x1;Toutput.out2=-Tinput.x2;');
        end
        
        function constructorFile(testCase)
            Xm = opencossan.workers.Mio('Description','Unit Test Mio',...
                'OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'Path',testCase.workingDirectoryFunctions,...
                'FullFileName','differenceStructure.m',...
                'Format','structure');
            
            testCase.assertEqual(Xm.Description,'Unit Test Mio');
            testCase.assertEqual(Xm.Format,'structure');
            testCase.assertEqual(Xm.Path,testCase.workingDirectoryFunctions);
            testCase.assertEqual(Xm.File,'differenceStructure.m');
        end
        
        function WrongInputsToConstructor(testCase)  % Checks that the command fails when the wrong input is passed to the constructor
            testCase.verifyError(@() opencossan.workers.Mio('Sunexistingproperty',':-)'),...
                'OpenCossan:workers:Mio')
        end
        
        function GiveNonExistingFileToConstructor(testCase) % Checks that the command fails due to incorrect file specified to be passed to the constructor
            testCase.verifyError(@() opencossan.workers.Mio('FullFileName','thisfiledoesntexist.m', ...
                'Format','structure'),'OpenCossan:workers:Mio:NonExistingFunction')
        end
        
        function GiveNonUniqueInputNames(testCase) % Checks that the command fails due to incorrect file specified to be passed to the constructor
            testCase.verifyError(@() opencossan.workers.Mio('Inputnames',{'Xrv1';'Xrv1'}),...
                'OpenCossan:workers:Mio:NonUniqueName')
        end
        
        %% run
        function runMioWithStructurePassingInput(testCase)
            Xm = opencossan.workers.Mio('Outputnames',{'diff1';'diff2'},...
                'Inputnames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceStructure.m'),...
                'IsFunction',true,'Format','structure');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithStructurePassingSamples(testCase)
            Xm = opencossan.workers.Mio('Outputnames',{'diff1';'diff2'},...
                'Inputnames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceStructure.m'),...
                'IsFunction',true,'Format','structure');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithStructurePassingStructure(testCase)
            Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'OuputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceStructure.m'),...
                'IsFunction',true,'format','structure');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.getStructure());
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithStructurePassingMatrix(testCase)
            Xm = opencossan.workers.Mio('Outputnames',{'diff1';'diff2'},...
                'Inputnames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceStructure.m'),...
                'IsFunction',true,'Format','structure');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples.MsamplesPhysicalSpace);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithMatrixPassingInput(testCase)
            Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),...
                'IsFunction',true,'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithMatrixPassingSamples(testCase)
            Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),...
                'IsFunction',true,'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('CSnames',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithMatrixPassingMatrix(testCase)
            Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),....
                'IsFunction',true,'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples.MsamplesPhysicalSpace);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithMatrixPassingStructure(testCase)
            Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),....
                'IsFunction',true,'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.getStructure());
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        % TODO rumMioWithVector (Multiple Inputs Outputs)
        
        function runMioWithScriptAndStructurePassingInput(testCase)
            Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),....
                'IsFunction',true,'Format','structure');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithScriptAndStructurePassingSamples(testCase)
            Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),....
                'IsFunction',true,'Format','structure');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples);
            
            testCase.assertEqual(Pout.Names,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithScriptAndStructurePassingStructure(testCase)
            Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceStructure.m'),...
                'Format','structure');
            
            Xinput = testCase.Xin.sample('Samples',10);
            Pout = Xm.run(Xinput.getStructure());
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithScriptAndStructurePassingMatrix(testCase)
                Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceStructure.m'),...
                'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples.MsamplesPhysicalSpace);
            
            testCase.assertEqual(Pout.Names,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithScriptAndMatrixPassingInput(testCase)
                 Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'Inputnames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),...
                'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput);
            
            testCase.assertEqual(Pout.Names,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithScriptAndMatrixPassingSamples(testCase)
                 Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),...
                'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples);
            
            testCase.assertEqual(Pout.Names,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithScriptAndMatrixPassingStructure(testCase)           
            Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),...
                'Format','matrix');    
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.getStructure());
            
            testCase.assertEqual(Pout.Names,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMioWithScriptAndMatrixPassingMatrix(testCase)
            Xm = opencossan.workers.Mio('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),...
                'Format','structure');    
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples.MsamplesPhysicalSpace);
            
            testCase.assertEqual(Pout.Names,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
       
    end
end

