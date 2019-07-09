classdef SolutionSequenceTest < matlab.unittest.TestCase
    % EVALUATORTEST Unit tests for the class common.MarkovChain
    % see http://cossan.co.uk/wiki/index.php/@SolutionSequence
    %
    % @author Jasper Behrensdorf<behrensdorf@irz.uni-hannover.de>
    % @date   06.09.2016
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
    
    properties
    end
    
    methods (Test)
        
        %% Constructor
        function constructorEmpty(testCase)
            Xss = workers.SolutionSequence();
            testCase.assertClass(Xss,'workers.SolutionSequence');
        end
        
        function constructorShouldFailWithoutOutputNames(testCase)
            testCase.assertError(@()workers.SolutionSequence('Sscript','Xrv = common.inputs.RandomVariable(''Sdistribution'',''normal'',''mean'',varargin{1}+varargin{2},''std'',1); COSSANoutput{1} = Xrv;',...
                'Cinputnames',{'Xdv1','Xdv2'}),'openCOSSAN:SolutionSequence');
        end
        
        %% Apply
        function applyWithFile(testCase)
            Xdv1 = optimization.DesignVariable('Vvalues',1:10,'value',5);
            Xdv2 = optimization.DesignVariable('Vvalues',1:10,'value',5);
            Xin = common.inputs.Input('CXmembers',{Xdv1 Xdv2},'CSmembers',{'Xdv1' 'Xdv2'});
            Xpar = common.inputs.Parameter('value',1);
            Xss = workers.SolutionSequence('Sfile','FileForSolutionSequence', ...
                'Spath',fullfile(OpenCossan.getCossanRoot,'test','data','workers','SolutionSequence'),...
                'Cinputnames',{'Xdv1','Xdv2'}, ...
                'Coutputnames',{'out1'}, ...
                'CprovidedObjectTypes',{'common.inputs.RandomVariable'},...
                'Cobject2output',{'.mean'},...
                'CobjectsNames',{'Xpar'},...
                'CobjectsTypes',{'common.inputs.Parameter'},...
                'CXobjects',{Xpar});
            Xout = Xss.apply(Xin.getStructure);
            testCase.assertEqual(Xout.getValues('Sname','out1'),11);
        end
        
        function applyWithScript(testCase)
            Xdv1 = optimization.DesignVariable('Vvalues',1:10,'value',5);
            Xdv2 = optimization.DesignVariable('Vvalues',1:10,'value',5);
            Xin = common.inputs.Input('CXmembers',{Xdv1 Xdv2},'CSmembers',{'Xdv1' 'Xdv2'});
            Xpar = common.inputs.Parameter('value',1);
            Xss = workers.SolutionSequence('Sfile','FileForSolutionSequence', ...
                'Sscript','Xrv = common.inputs.RandomVariable(''Sdistribution'',''normal'',''mean'',varargin{1}+varargin{2}+Xpar.Value,''std'',1); COSSANoutput{1} = Xrv;',...
                'Cinputnames',{'Xdv1','Xdv2'}, ...
                'Coutputnames',{'out1'}, ...
                'CprovidedObjectTypes',{'common.inputs.RandomVariable'},...
                'Cobject2output',{'.mean'},...
                'CobjectsNames',{'Xpar'},...
                'CobjectsTypes',{'common.inputs.Parameter'},...
                'CXobjects',{Xpar});
            Xout = Xss.apply(Xin.getStructure);
            testCase.assertEqual(Xout.getValues('Sname','out1'),11);
        end
        
        function applyShouldFailWithIncorrectInputType(testCase)
            Xdv1 = optimization.DesignVariable('Vvalues',1:10,'value',5);
            Xdv2 = optimization.DesignVariable('Vvalues',1:10,'value',5);
            Xin = common.inputs.Input('CXmembers',{Xdv1 Xdv2},'CSmembers',{'Xdv1' 'Xdv2'});
            Xpar = common.inputs.Parameter('value',1);
            Xss = workers.SolutionSequence('Sfile','FileForSolutionSequence', ...
                'Sscript','Xrv = common.inputs.RandomVariable(''Sdistribution'',''normal'',''mean'',varargin{1}+varargin{2}+Xpar.Value,''std'',1); COSSANoutput{1} = Xrv;',...
                'Cinputnames',{'Xdv1','Xdv2'}, ...
                'Coutputnames',{'out1'}, ...
                'CprovidedObjectTypes',{'common.inputs.Input'},...
                'Cobject2output',{'.mean'},...
                'CobjectsNames',{'Xpar'},...
                'CobjectsTypes',{'common.inputs.Parameter'},...
                'CXobjects',{Xpar});

            testCase.assertError(@()Xss.apply(Xin.getStructure),...
                'openCOSSAN:SolutionSequence:runScript');
        end
        
        function applyOutputWithInvalidObject2OutputShouldBeEmpty(testCase)
            Xdv1 = optimization.DesignVariable('Vvalues',1:10,'value',5);
            Xdv2 = optimization.DesignVariable('Vvalues',1:10,'value',5);
            Xin = common.inputs.Input('CXmembers',{Xdv1 Xdv2},'CSmembers',{'Xdv1' 'Xdv2'});
            Xpar = common.inputs.Parameter('value',1);
            Xss = workers.SolutionSequence('Sfile','FileForSolutionSequence', ...
                'Sscript','Xrv = common.inputs.RandomVariable(''Sdistribution'',''normal'',''mean'',varargin{1}+varargin{2}+Xpar.Value,''std'',1); COSSANoutput{1} = Xrv;',...
                'Cinputnames',{'Xdv1','Xdv2'}, ...
                'Coutputnames',{'out1'}, ...
                'CprovidedObjectTypes',{'common.inputs.RandomVariable'},...
                'Cobject2output',{'.Cpar{1,1}'},...
                'CobjectsNames',{'Xpar'},...
                'CobjectsTypes',{'common.inputs.Parameter'},...
                'CXobjects',{Xpar});

            Xout = Xss.apply(Xin.getStructure);
            testCase.assertEqual(Xout.getValues('Sname','out1'),[]);
        end
        
        function applyShouldWorkWithoutTypes(testCase)
            Xdv1 = optimization.DesignVariable('Vvalues',1:10,'value',5);
            Xdv2 = optimization.DesignVariable('Vvalues',1:10,'value',5);
            Xin = common.inputs.Input('CXmembers',{Xdv1 Xdv2},'CSmembers',{'Xdv1' 'Xdv2'});
            Xpar = common.inputs.Parameter('value',1);
            Xss = workers.SolutionSequence('Sfile','FileForSolutionSequence', ...
                'Sscript','Xrv = common.inputs.RandomVariable(''Sdistribution'',''normal'',''mean'',varargin{1}+varargin{2}+Xpar.Value,''std'',1); COSSANoutput{1} = Xrv;',...
                'Cinputnames',{'Xdv1','Xdv2'}, ...
                'Coutputnames',{'out1'}, ...
                'Cobject2output',{'.mean'},...
                'CobjectsNames',{'Xpar'},...
                'CXobjects',{Xpar});

            Xout = Xss.apply(Xin.getStructure);
            testCase.assertEqual(Xout.getValues('Sname','out1'),11);
        end
        
        % TODO Test apply with Jobmanager(Interface)
    end
    
end

