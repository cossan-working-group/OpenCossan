classdef MatlabWorkerTest < matlab.unittest.TestCase
    % MatlabWorkerTEST Unit tests for the class
    % opencossan.workers.MatlabWorker
    %
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
        workingDirectoryFunctions = fullfile(opencossan.OpenCossan.getRoot,'test','data','workers','MatlabWorker','functions');
        workingDirectoryFunctionsDeployed = fullfile(opencossan.OpenCossan.getRoot,'test','data','workers','MatlabWorker','functionsDeployed');
        workingDirectoryScripts = fullfile(opencossan.OpenCossan.getRoot,'test','data','workers','MatlabWorker','scripts');
        isdeployedDirectory = fullfile(opencossan.OpenCossan.getRoot,'test','data','workers','MatlabWorker','isdeployed');
    end
    
    methods (TestClassSetup)
        function skip(testCase)
            testCase.assumeFail();
        end
    end
    
    methods (TestMethodSetup)
        function createInput(testCase)
            Xrv1 = opencossan.common.inputs.random.Uniform('par1',9,'par2',11);
            Xrv2 = opencossan.common.inputs.Uniform('par1',14,'par2',16);
            Xrvs = opencossan.common.inputs.RandomVariableSet('CSMembers',{'Xrv1','Xrv2'},'CXmembers',{Xrv1,Xrv2});
            testCase.Xin = opencossan.common.inputs.Input('CXmembers',{Xrvs},'CSmembers',{'Xrvs'});
        end
    end
    
    methods (Test)
        %% constructor
        function constructorMinimal(testCase)
            Xm = opencossan.workers.MatlabWorker('InputNames',{'x1','x2'},'OutputNames',{'out1','out2'},...
                'Script','Toutput.out1=Tinput.x1;Toutput.out2=-Tinput.x2;');
            
            testCase.assertEqual(Xm.InputNames,{'x1','x2'});
            testCase.assertEqual(Xm.OutputNames,{'out1','out2'});
            testCase.assertEqual(Xm.Script,'Toutput.out1=Tinput.x1;Toutput.out2=-Tinput.x2;');
        end
        
        function constructorFile(testCase)
            Xm = opencossan.workers.MatlabWorker('Description','Unit Test MatlabWorker',...
                'OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'Path',testCase.workingDirectoryFunctions,...
                'FullFileName','differenceStructure.m',...
                'Format','structure');
            
            testCase.assertEqual(Xm.Description,'Unit Test MatlabWorker');
            testCase.assertEqual(Xm.Format,'structure');
            testCase.assertEqual(Xm.Path,testCase.workingDirectoryFunctions);
            testCase.assertEqual(Xm.File,'differenceStructure.m');
        end
        
        function WrongInputsToConstructor(testCase)  % Checks that the command fails when the wrong input is passed to the constructor
            testCase.verifyError(@() opencossan.workers.MatlabWorker('Sunexistingproperty',':-)'),...
                'OpenCossan:workers:MatlabWorker')
        end
        
        function GiveNonExistingFileToConstructor(testCase) % Checks that the command fails due to incorrect file specified to be passed to the constructor
            testCase.verifyError(@() opencossan.workers.MatlabWorker('FullFileName','thisfiledoesntexist.m', ...
                'Format','structure'),'OpenCossan:workers:MatlabWorker:NonExistingFunction')
        end
        
        function GiveNonUniqueInputNames(testCase) % Checks that the command fails due to incorrect file specified to be passed to the constructor
            testCase.verifyError(@() opencossan.workers.MatlabWorker('Inputnames',{'Xrv1';'Xrv1'}),...
                'OpenCossan:workers:MatlabWorker:NonUniqueName')
        end
        
        %% run
        function runMatlabWorkerWithStructurePassingInput(testCase)
            Xm = opencossan.workers.MatlabWorker('Outputnames',{'diff1';'diff2'},...
                'Inputnames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceStructure.m'),...
                'IsFunction',true,'Format','structure');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithStructurePassingSamples(testCase)
            Xm = opencossan.workers.MatlabWorker('Outputnames',{'diff1';'diff2'},...
                'Inputnames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceStructure.m'),...
                'IsFunction',true,'Format','structure');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithStructurePassingStructure(testCase)
            Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
                'OuputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceStructure.m'),...
                'IsFunction',true,'format','structure');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.getStructure());
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithStructurePassingMatrix(testCase)
            Xm = opencossan.workers.MatlabWorker('Outputnames',{'diff1';'diff2'},...
                'Inputnames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceStructure.m'),...
                'IsFunction',true,'Format','structure');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples.MsamplesPhysicalSpace);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithMatrixPassingInput(testCase)
            Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),...
                'IsFunction',true,'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithMatrixPassingSamples(testCase)
            Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),...
                'IsFunction',true,'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('CSnames',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithMatrixPassingMatrix(testCase)
            Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),....
                'IsFunction',true,'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples.MsamplesPhysicalSpace);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithMatrixPassingStructure(testCase)
            Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),....
                'IsFunction',true,'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.getStructure());
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        % TODO rumMatlabWorkerWithVector (Multiple Inputs Outputs)
        
        function runMatlabWorkerWithScriptAndStructurePassingInput(testCase)
            Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),....
                'IsFunction',true,'Format','structure');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput);
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithScriptAndStructurePassingSamples(testCase)
            Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),....
                'IsFunction',true,'Format','structure');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples);
            
            testCase.assertEqual(Pout.Names,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithScriptAndStructurePassingStructure(testCase)
            Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceStructure.m'),...
                'Format','structure');
            
            Xinput = testCase.Xin.sample('Samples',10);
            Pout = Xm.run(Xinput.getStructure());
            
            testCase.assertEqual(Pout.Cnames,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithScriptAndStructurePassingMatrix(testCase)
                Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceStructure.m'),...
                'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples.MsamplesPhysicalSpace);
            
            testCase.assertEqual(Pout.Names,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithScriptAndMatrixPassingInput(testCase)
                 Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
                'Inputnames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),...
                'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput);
            
            testCase.assertEqual(Pout.Names,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithScriptAndMatrixPassingSamples(testCase)
                 Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),...
                'Format','matrix');
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.Xsamples);
            
            testCase.assertEqual(Pout.Names,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithScriptAndMatrixPassingStructure(testCase)           
            Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
                'InputNames',{'Xrv1';'Xrv2'},...
                'FullFileName',fullfile(testCase.workingDirectoryFunctions,'differenceMatrix.m'),...
                'Format','matrix');    
            
            Xinput = testCase.Xin.sample(10);
            Pout = Xm.run(Xinput.getStructure());
            
            testCase.assertEqual(Pout.Names,{'diff1' 'diff2'});
            testCase.assertSize(Pout.getValues('Names',{'diff1' 'diff2'}),[10 2]);
        end
        
        function runMatlabWorkerWithScriptAndMatrixPassingMatrix(testCase)
            Xm = opencossan.workers.MatlabWorker('OutputNames',{'diff1';'diff2'},...
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

